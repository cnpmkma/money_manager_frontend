import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class BudgetService {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  // Lấy danh sách budget
  static Future<List<Map<String, dynamic>>> getBudgets() async {
    final token = await AuthService.getToken();
    final res = await _dio.get(
      "/budgets",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return List<Map<String, dynamic>>.from(res.data);
  }

  // Lấy chi tiết budget theo id
  static Future<Map<String, dynamic>> getBudget(int id) async {
    final token = await AuthService.getToken();
    final res = await _dio.get(
      "/budgets/$id",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return Map<String, dynamic>.from(res.data);
  }

  // Tạo budget mới
  static Future<Map<String, dynamic>> createBudget({
    required int userId,
    required int categoryId,
    required double maxAmount,
  }) async {
    final token = await AuthService.getToken();
    final res = await _dio.post(
      "/budgets",
      data: {
        "user_id": userId,
        "category_id": categoryId,
        "max_amount": maxAmount,
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return Map<String, dynamic>.from(res.data);
  }

  // Cập nhật budget
  static Future<Map<String, dynamic>> updateBudget({
    required int id,
    double? maxAmount,
  }) async {
    final token = await AuthService.getToken();
    final res = await _dio.put(
      "/budgets/$id",
      data: {
        if (maxAmount != null) "max_amount": maxAmount,
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
    return Map<String, dynamic>.from(res.data);
  }

  // Xóa budget
  static Future<void> deleteBudget(int id) async {
    final token = await AuthService.getToken();
    await _dio.delete(
      "/budgets/$id",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}
