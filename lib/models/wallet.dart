class WalletModel {
  final String id;
  final String name;
  final double balance;
  final String userId;

  WalletModel({
    required this.id,
    required this.name,
    required this.balance,
    required this.userId,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'],
      name: json['wallet_name'],
      balance: (json['balance'] as num).toDouble(),
      userId: json['user_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_name': name,
      'balance': balance,
      'user_id': userId,
    };
  }
}
