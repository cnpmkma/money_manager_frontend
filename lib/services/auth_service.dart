import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';

class AuthService {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password
  }) async {
    final url = Uri.parse("$baseUrl/register");

    try {
      final Response response = await post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password
        })
      );

      if (response.statusCode == 201) {
        return {"success": true, "data": jsonDecode(response.body)};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)['message'] ?? "Đăng ký thất bại"
        };
      }
    }
    catch (e) {
      return {"success": false, "message": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> login({required String username, required String password}) async {
    final response = await post(
      Uri.parse("$baseUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'username': username,
        'password': password
      })
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Đăng nhập thất bại: ${response.body}");
    }
  }
}