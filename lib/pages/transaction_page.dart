import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
      "date": DateTime(2025, 9, 1),
      "type": "income",
      "icon": Icons.work,
    },
    {
      "title": "Mua sắm Shopee",
      "amount": -350.5,
      "date": DateTime(2025, 9, 3),
      "type": "expense",
      "icon": Icons.shopping_cart,
    },
    {
      "title": "Ăn uống",
      "amount": -120.0,
      "date": DateTime(2025, 9, 3),
      "type": "expense",
      "icon": Icons.restaurant,
    },
    {
      "title": "Bán đồ cũ",
      "amount": 500.0,
      "date": DateTime(2025, 9, 6),
      "type": "income",
      "icon": Icons.sell,
    },
  ];

  String _filter = "all"; // all, income, expense

  @override
  Widget build(BuildContext context) {
    // Lọc theo loại
    final filtered = _transactions.where((tx) {
      if (_filter == "all") return true;
      return tx["type"] == _filter;
    }).toList();

    // Gom nhóm theo ngày
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (var tx in filtered) {
      final dateStr = DateFormat("dd/MM/yyyy").format(tx["date"]);
      grouped.putIfAbsent(dateStr, () => []).add(tx);
    }

    // Tính tổng kết
    final totalIncome = _transactions
        .where((tx) => tx["amount"] > 0)
        .fold<double>(0, (sum, tx) => sum + tx["amount"]);
    final totalExpense = _transactions
        .where((tx) => tx["amount"] < 0)
        .fold<double>(0, (sum, tx) => sum + tx["amount"].abs());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sổ giao dịch"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filter = value;
              });
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "all", child: Text("Tất cả")),
              PopupMenuItem(value: "income", child: Text("Thu nhập")),
              PopupMenuItem(value: "expense", child: Text("Chi tiêu")),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card tổng kết
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tổng kết tháng 9",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text("Thu nhập", style: TextStyle(color: Colors.green)),
                          Text("+\$${totalIncome.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text("Chi tiêu", style: TextStyle(color: Colors.red)),
                          Text("-\$${totalExpense.toStringAsFixed(2)}",
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Danh sách giao dịch (theo ngày)
          for (var entry in grouped.entries) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(entry.key,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
            ...entry.value.map((tx) {
              final isIncome = tx["amount"] > 0;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 2,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    isIncome ? Colors.green[100] : Colors.red[100],
                    child: Icon(tx["icon"], color: isIncome ? Colors.green : Colors.red),
                  ),
                  title: Text(tx["title"],
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  trailing: Text(
                    (isIncome ? "+ " : "- ") + tx["amount"].abs().toStringAsFixed(2),
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
