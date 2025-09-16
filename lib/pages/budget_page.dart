import 'package:flutter/material.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  // Fake data demo
  final List<Map<String, dynamic>> _budgets = [
    {
      "category": "Ăn uống",
      "limit": 1000.0,
      "spent": 650.0,
      "icon": Icons.restaurant,
    },
    {
      "category": "Mua sắm",
      "limit": 1500.0,
      "spent": 1200.0,
      "icon": Icons.shopping_bag,
    },
    {
      "category": "Đi lại",
      "limit": 500.0,
      "spent": 200.0,
      "icon": Icons.directions_car,
    },
    {
      "category": "Giải trí",
      "limit": 800.0,
      "spent": 400.0,
      "icon": Icons.movie,
    },
  ];

  @override
  Widget build(BuildContext context) {
    double totalLimit = _budgets.fold(0, (sum, b) => sum + b["limit"]);
    double totalSpent = _budgets.fold(0, (sum, b) => sum + b["spent"]);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text("Ngân sách"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng quan
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Tổng quan tháng này",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Hạn mức: ${totalLimit.toStringAsFixed(0)} đ"),
                    Text("Đã chi: ${totalSpent.toStringAsFixed(0)} đ"),
                    Text(
                      "Còn lại: ${(totalLimit - totalSpent).toStringAsFixed(0)} đ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: (totalLimit - totalSpent) < 0
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Ngân sách theo hạng mục",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Danh sách ngân sách
            Expanded(
              child: ListView.separated(
                itemCount: _budgets.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final budget = _budgets[index];
                  double percent = budget["spent"] / budget["limit"];
                  bool overLimit = budget["spent"] > budget["limit"];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: overLimit
                            ? Colors.red[100]
                            : Colors.blue[100],
                        child: Icon(
                          budget["icon"],
                          color: overLimit ? Colors.red : Colors.blue,
                        ),
                      ),
                      title: Text(
                        budget["category"],
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LinearProgressIndicator(
                            value: percent > 1 ? 1 : percent,
                            backgroundColor: Colors.grey[200],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              overLimit ? Colors.red : Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${budget["spent"]} / ${budget["limit"]} đ",
                            style: TextStyle(
                              color: overLimit ? Colors.red : Colors.black87,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: Text(
                        overLimit
                            ? "Vượt hạn mức"
                            : "${(budget["limit"] - budget["spent"]).toStringAsFixed(0)} đ còn lại",
                        style: TextStyle(
                          color: overLimit ? Colors.red : Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
