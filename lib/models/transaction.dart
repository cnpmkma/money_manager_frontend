class Transaction {
  final int id;
  final double amount;
  final String? note;
  final DateTime transactionDate;
  final int walletId;
  final int categoryId;
  final String categoryName;
  final String categoryType;

  Transaction({
    required this.id,
    required this.amount,
    this.note,
    required this.transactionDate,
    required this.walletId,
    required this.categoryId,
    required this.categoryName,
    required this.categoryType,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
  return Transaction(
    id: json['id'],
    amount: double.tryParse(json['amount'].toString()) ?? 0,
    note: json['note'],
    transactionDate: DateTime.tryParse(json['transaction_date'].toString()) ?? DateTime.now(),
    walletId: json['wallet_id'],
    categoryId: json['category_id'],
    categoryName: json['category']?['category_name'],
    categoryType: json['category']?['type'],
  );
}

}
