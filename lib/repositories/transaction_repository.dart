import '../services/transaction_service.dart';
import '../models/transaction.dart';

class TransactionRepository {

  /// Lấy danh sách giao dịch
  Future<List<Transaction>> getTransactions({int? walletId}) async {
    final data = await TransactionService.getTransactions(walletId: walletId);
    return data.map((json) => Transaction.fromJson(json)).toList().cast<Transaction>();
  }

  /// Thêm giao dịch
  Future<Transaction> addTransaction({
    required double amount,
    String? note,
    required int walletId,
    required int categoryId,
    DateTime? transactionDate,
  }) async {
    final json = await TransactionService.addTransaction(
      amount: amount,
      note: note,
      walletId: walletId,
      categoryId: categoryId,
      transactionDate: transactionDate,
    );
    return Transaction.fromJson(json);
  }

  Future<void> deleteTransaction(int id) async {
    // await TransactionService.deleteTransaction(id);
    // tạm thời chưa có BE thì bạn chỉ cần trả về void
  }
}
