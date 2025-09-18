import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CategoryService {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  static Future<List<Map<String, dynamic>>> getCategories() async {
    final token = await AuthService.getToken();

    final res = await _dio.get(
      "/categories",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    return List<Map<String, dynamic>>.from(res.data);
  }
}
