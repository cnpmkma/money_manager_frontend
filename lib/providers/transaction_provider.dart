import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionProvider with ChangeNotifier {
  final TransactionRepository _repo = TransactionRepository();

  List<Transaction> _transactions = [];
  bool _loading = false;

  List<Transaction> get transactions => _transactions;
  bool get isLoading => _loading;

  Future<void> loadTransactions({int? walletId}) async {
    _loading = true;
    notifyListeners();
    try {
      _transactions = await _repo.getTransactions(walletId: walletId);
    } catch (e) {
      _transactions = [];
      debugPrint("❌ loadTransactions error: $e");
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> addTransaction({
    required double amount,
    String? note,
    required int walletId,
    required int categoryId,
    DateTime? transactionDate,
  }) async {
    try {
      final tx = await _repo.addTransaction(
        amount: amount,
        note: note,
        walletId: walletId,
        categoryId: categoryId,
        transactionDate: transactionDate,
      );
      _transactions.insert(0, tx);
      notifyListeners();
    } catch (e) {
      debugPrint("❌ addTransaction error: $e");
      rethrow;
    }
  }

  Future<void> deleteTransaction(int id) async {
    _transactions.removeWhere((t) => t.id == id);
    notifyListeners();
    // khi có API thì gọi: await _repo.deleteTransaction(id);
  }
}
