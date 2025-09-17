import 'package:dio/dio.dart';
import 'auth_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WalletService {
  static String get baseUrl => dotenv.env['API_BASE_URL']!;

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {"Accept": "application/json"},
    ),
  );

  // Lấy danh sách ví
  static Future<List<dynamic>> getWallets() async {
    final token = await AuthService.getToken();

    final res = await _dio.get(
      "/wallets",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );

    return res.data as List<dynamic>;
  }

  static Future<Map<String, dynamic>> createWallet(
  String name,
  double balance,
  {int skinIndex = 1}
) async {
  final token = await AuthService.getToken();

  final res = await _dio.post(
    "/wallets",
    data: {
      "wallet_name": name,
      "balance": balance,
      "skin_index": skinIndex, // gửi skin_index lên backend
    },
    options: Options(headers: {"Authorization": "Bearer $token"}),
  );

  return res.data as Map<String, dynamic>;
}

  // Cập nhật ví
  static Future<void> updateWallet(
    int walletId,
    String name, {
    int? skinIndex,
  }) async {
    final token = await AuthService.getToken();

    // Map kiểu rõ ràng để tránh lỗi int -> String
    final Map<String, dynamic> data = {"wallet_name": name};
    if (skinIndex != null) {
      data["skin_index"] = skinIndex;
    }

    await _dio.patch(
      "/wallets/$walletId",
      data: data,
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }

  // Xóa ví
  static Future<void> deleteWallet(int id) async {
    final token = await AuthService.getToken();

    await _dio.delete(
      "/wallets/$id",
      options: Options(headers: {"Authorization": "Bearer $token"}),
    );
  }
}
