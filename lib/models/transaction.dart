class TransactionModel {
  final int id;
  final double amount;
  final String? note;
  final DateTime? transactionDate;
  final int walletId;
  final int categoryId;
  final String categoryName;
  final String categoryType;

  TransactionModel({
    required this.id,
    required this.amount,
    this.note,
    this.transactionDate,
    required this.walletId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'],
      amount: json['amount'],
      note: json['note'],
      transactionDate: DateTime.tryParse(json['transaction_date']),
      walletId: json['wallet_id'],
      categoryId: json['category_id'],
      categoryName: json['category']['category_name'],
      categoryType: json['category']['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'transaction_date': transactionDate,
      'wallet_id': walletId,
      'category_id': categoryId,
    };
  }
}
