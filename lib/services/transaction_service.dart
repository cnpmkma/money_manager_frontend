import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransactionService {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Accept": "application/json"},
    ),
  );

  static Future<List<dynamic>> getTransactions({int? walletId}) async {
    final token = await AuthService.getToken();

    final res = await _dio.get(
      "/transactions",
      queryParameters: walletId != null ? {"wallet_id": walletId} : null,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    return res.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> addTransaction({
    required double amount,
    String? note,
    required int walletId,
    required int categoryId,
    DateTime? transactionDate,
  }) async {
    final token = await AuthService.getToken();

    final res = await _dio.post(
      "/transactions",
      data: {
        "amount": amount,
        "note": note,
        "wallet_id": walletId,
        "category_id": categoryId,
        "transaction_date": (transactionDate ?? DateTime.now()).toIso8601String(),
      },
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    return res.data as Map<String, dynamic>;
  }
}
