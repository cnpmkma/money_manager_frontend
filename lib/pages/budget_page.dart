import 'package:flutter/material.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';
import 'package:money_manager_frontend/services/budget_service.dart';
import 'package:money_manager_frontend/services/transaction_service.dart';
import 'budget_edit_page.dart';
import '../constants/category_icons.dart';

class BudgetPage extends StatefulWidget {
  const BudgetPage({super.key});

  @override
  State<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends State<BudgetPage> {
  List<Map<String, dynamic>> _budgets = [];
  bool _loadingOverview = true;
  bool _loadingBudgets = true;

  @override
  void initState() {
    super.initState();
    _fetchBudgets();
  }

  Future<void> _fetchBudgets() async {
    setState(() {
      _loadingOverview = true;
      _loadingBudgets = true;
    });

    try {
      final budgetData = await BudgetService.getBudgets();
      final transactions = await TransactionService.getTransactions();

      final budgets = budgetData
          .where((item) => item['category']['type'] == 'chi')
          .map((item) {
            final categoryName = item['category']['category_name'];
            final spent = transactions
                .where(
                  (tx) =>
                      tx['category']['type'] == 'chi' &&
                      tx['category']['category_name'] == categoryName,
                )
                .fold<double>(
                  0,
                  (sum, tx) => sum + double.tryParse(tx['amount'].toString())!,
                );

            return {
              "id": item['id'],
              "category": categoryName,
              "limit": double.tryParse(item['max_amount'].toString()) ?? 0,
              "spent": spent,
              "type": item['category']['type'],
            };
          })
          .toList();

      setState(() {
        _budgets = budgets;
        _loadingOverview = false;
        _loadingBudgets = false;
      });
    } catch (e) {
      print("Error fetching budgets: $e");
      setState(() {
        _loadingOverview = false;
        _loadingBudgets = false;
      });
    }
  }

  Widget _buildOverviewItem(String label, double value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        const SizedBox(height: 4),
        Text(
          "${value.toStringAsFixed(0)} đ",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalLimit = _budgets.fold(0, (sum, b) => sum + b["limit"]);
    double totalSpent = _budgets.fold(0, (sum, b) => sum + b["spent"]);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Ngân sách"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _fetchBudgets, // gọi lại API budgets
        child: ListView(
          physics:
              const AlwaysScrollableScrollPhysics(), // để vuốt được cả khi ít dữ liệu
          padding: const EdgeInsets.all(16),
          children: [
            // Tổng quan
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 6,
              shadowColor: Colors.black26,
              child: _loadingOverview
                  ? const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Tổng quan tháng này",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildOverviewItem("Hạn mức", totalLimit),
                              _buildOverviewItem("Đã chi", totalSpent),
                              _buildOverviewItem(
                                "Còn lại",
                                totalLimit - totalSpent,
                                valueColor: (totalLimit - totalSpent) < 0
                                    ? Colors.red
                                    : Colors.green,
                              ),
                            ],
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

            // danh sách budgets
            if (_loadingBudgets)
              const Center(child: CircularProgressIndicator())
            else
              ..._budgets.map((budget) {
                double percent = budget["limit"] == 0
                    ? 0
                    : budget["spent"] / budget["limit"];
                bool overLimit = budget["spent"] > budget["limit"];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditBudgetPage(
                              budgetId: budget["id"],
                              categoryName: budget["category"],
                              initialMaxAmount: budget["limit"],
                              onBudgetUpdated: _fetchBudgets,
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: overLimit
                            ? Colors.red[100]
                            : Colors.blue[100],
                        child: Icon(
                          categoryIcons[budget["category"]] ?? Icons.category,
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
                            "${budget["spent"].toStringAsFixed(0)} / ${budget["limit"].toStringAsFixed(0)} đ",
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
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
