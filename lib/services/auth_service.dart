import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  /// Bật tắt mock data (true = dùng fake, false = gọi API thật)
  static const bool useMock = false;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"}
    )
  );

  // --------------------REGISTER------------------
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
    try {
      final res = await _dio.post(
        "/register",
        data: {
          "username": username,
          "email": email,
          "password": password
        }
      );

      if (res.statusCode == 201) {
        return {
          "success": res.data["success"],
          "message": res.data["message"],
          "user": res.data["user"]
        };
      } else {
        return {
          "success": false,
          "message": "Đăng ký thất bại"
        };
      }
    } on DioException catch(e) {
      return {
        "success": false,
        "message": "Đăng ký thất bại"
      };
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
      final res = await _dio.post(
        '/login',
        data: {
          "username": username,
          "password": password
        }
      );

      final data = res.data;

      return {
        "success": data["success"],
        "access_token": data["access_token"],
        "user": data["user"],
        "message": data["message"],
      };
    } on DioException catch (e) {
      if (e.response != null) {
        final data = e.response?.data;
        return {
          "success": false,
          "access_token": null,
          "user": null,
          "message": data?["message"] ?? "Đăng nhập thất bại"
        };
      } else {
        return {
          "success": false,
          "access_token": null,
          "user": null,
          "message": e.message ?? "Lỗi kết nối"
        };
      }
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
  }

}
