import 'package:flutter/material.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  // Fake data demo
  final List<Map<String, dynamic>> _transactions = [
    {
      "title": "Lương tháng 9",
      "amount": 2000.0,
      "date": "2025-09-01",
      "type": "income",
      "icon": Icons.work,
    },
    {
      "title": "Mua sắm Shopee",
      "amount": -350.5,
      "date": "2025-09-03",
      "type": "expense",
      "icon": Icons.shopping_cart,
    },
    {
      "title": "Ăn uống",
      "amount": -120.0,
      "date": "2025-09-04",
      "type": "expense",
      "icon": Icons.restaurant,
    },
    {
      "title": "Bán đồ cũ",
      "amount": 500.0,
      "date": "2025-09-06",
      "type": "income",
      "icon": Icons.sell,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sổ giao dịch"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Mở filter
            },
          )
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _transactions.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final tx = _transactions[index];
          final bool isIncome = tx["amount"] > 0;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
              child: Icon(
                tx["icon"],
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
            title: Text(
              tx["title"],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(tx["date"]),
            trailing: Text(
              (isIncome ? "+ " : "- ") + tx["amount"].abs().toStringAsFixed(2),
              style: TextStyle(
                color: isIncome ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        },
      ),
    );
  }
}
