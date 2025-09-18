import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static const _keyLoggedIn = 'isLoggedIn';
  static const _keyAccessToken = 'access_token';

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Content-Type": "application/json"},
    ),
  );

  // ------------------ LOGIN STATUS ------------------
  static Future<void> saveLoginStatus(bool status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, status);
  }

  static Future<bool> getLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyLoggedIn) ?? false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyAccessToken);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await saveLoginStatus(false);
    await prefs.remove(_keyAccessToken);
  }

  // ------------------ REGISTER ------------------
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        "/register",
        data: {
          "username": username,
          "email": email,
          "password": password,
        },
      );

      if (res.statusCode == 201 || res.data['success'] == true) {
        return {
          "success": true,
          "message": res.data["message"],
          "user": res.data["user"],
        };
      } else {
        return {"success": false, "message": res.data["message"] ?? "Đăng ký thất bại"};
      }
    } on DioException catch (e) {
      final message = e.response?.data?["message"] ?? e.message ?? "Đăng ký thất bại";
      return {"success": false, "message": message};
    }
  }

  // ------------------ LOGIN ------------------
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/login',
        data: {"username": username, "password": password},
      );

      final data = res.data;
      if (data['success'] == true) {
        final token = data['access_token'] as String;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_keyAccessToken, token);
        await saveLoginStatus(true);

        return {
          "success": true,
          "access_token": token,
          "user": data['user'],
          "message": data['message'],
        };
      } else {
        return {
          "success": false,
          "access_token": null,
          "user": null,
          "message": data['message'] ?? "Đăng nhập thất bại",
        };
      }
    } on DioException catch (e) {
      final message = e.response?.data?["message"] ?? e.message ?? "Lỗi kết nối";
      return {"success": false, "access_token": null, "user": null, "message": message};
    }
  }

  // ------------------ GET CURRENT USER ------------------
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final token = await getToken();
      if (token == null) return {};

      final res = await _dio.get(
        '/profile',
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['user'];
        return {
          'id': data['id'],
          'username': data['username'],
          'email': data['email'],
        };
      }
      return {};
    } on DioException {
      return {};
    }
  }

  // ------------------ UPDATE PROFILE ------------------
  static Future<bool> updateProfile({
    required String username,
    required String email,
  }) async {
    try {
      final token = await getToken();
      if (token == null) return false;

      final res = await _dio.patch(
        '/profile',
        data: {'username': username, 'email': email},
        options: Options(headers: {"Authorization": "Bearer $token"}),
      );

      return res.statusCode == 200 && res.data['success'] == true;
    } on DioException {
      return false;
    }
  }
}
