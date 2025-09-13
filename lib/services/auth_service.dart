import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class AuthService {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  /// Bật tắt mock data (true = dùng fake, false = gọi API thật)
  static const bool useMock = true;

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    if (useMock) {
      // FAKE API
      await Future.delayed(const Duration(seconds: 1)); // giả lập delay
      if (email == "test@test.com") {
        return {"success": false, "message": "Email đã tồn tại (mock)"};
      }
      return {
        "success": true,
        "data": {"id": 1, "username": username, "email": email}
      };
    }

    // API thật
    final url = Uri.parse("$baseUrl/register");
    try {
      final Response response = await post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)['message'] ?? "Đăng ký thất bại"
        };
      }
    } catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    if (useMock) {
      // FAKE API
      await Future.delayed(const Duration(seconds: 1));

      if (username == "admin" && password == "123456") {
        return {
          "success": true,
          "access_token": "mock_access_token_123",
          "user": {"id": 1, "username": username},
          "message": "Đăng nhập thành công (mock)"
        };
      }

      return {
        "success": false,
        "access_token": null,
        "user": null,
        "message": "Sai tài khoản hoặc mật khẩu (mock)"
      };
    }

    // API thật
    try {
      final response = await post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          "success": true,
          "access_token": data['access_token'],
          "user": data['user'],
          "message": "Đăng nhập thành công"
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          "success": false,
          "access_token": null,
          "user": null,
          "message": data['message'] ?? "Đăng nhập thất bại"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "access_token": null,
        "user": null,
        "message": e.toString()
      };
    }
  }

}
