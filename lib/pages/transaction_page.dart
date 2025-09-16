import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  List<Map<String, dynamic>> _transactions = [];
  List<dynamic> _wallets = [];
  int? _selectedWalletId = null;
  String _filter = "all"; // all, income, expense
  bool _loading = true;

  final _currencyFormatter =
      NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _fetchWallets();
  }

  Future<void> _fetchWallets() async {
    try {
      final wallets = await WalletService.getWallets();
      setState(() {
        _wallets = wallets;
        _fetchTransactions();
      });
    } catch (e) {
      print("Error fetching wallets: $e");
      setState(() => _loading = false);
    }
  }

  Future<void> _fetchTransactions() async {
    try {
      setState(() => _loading = true);
      final data =
          await TransactionService.getTransactions(walletId: _selectedWalletId);
      setState(() {
        _transactions = data.map<Map<String, dynamic>>((tx) {
          final isIncome = tx["category"]['type'] == "thu";
          return {
            "title": tx['category']['category_name'],
            "amount": double.tryParse(tx["amount"].toString()) ?? 0.0,
            "date": DateTime.parse(tx["transaction_date"]),
            "type": isIncome ? "income" : "expense",
            "icon": isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          };
        }).toList();
        _loading = false;
      });
    } catch (e) {
      print("Error fetching transactions: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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

    // Tính tổng
    final totalIncome = _transactions
        .where((tx) => tx["type"] == "income")
        .fold<double>(0, (sum, tx) => sum + tx["amount"]);
    final totalExpense = _transactions
        .where((tx) => tx["type"] == "expense")
        .fold<double>(0, (sum, tx) => sum + tx["amount"]);

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text("Sổ giao dịch"),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: "all", child: Text("Tất cả")),
              PopupMenuItem(value: "income", child: Text("Thu nhập")),
              PopupMenuItem(value: "expense", child: Text("Chi tiêu")),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchTransactions,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            SummaryCard(
              totalIncome: totalIncome,
              totalExpense: totalExpense,
              formatter: _currencyFormatter,
              selectedWalletId: _selectedWalletId,
              wallets: _wallets,
              onWalletChanged: (val) {
                setState(() {
                  _selectedWalletId = val;
                });
                _fetchTransactions();
              },
            ),
            const SizedBox(height: 20),
            if (grouped.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Chưa có giao dịch nào"),
                ),
              )
            else
              for (var entry in grouped.entries) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    entry.key,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                ...entry.value.map((tx) => TransactionItem(
                      title: tx["title"],
                      amount: tx["amount"],
                      isIncome: tx["type"] == "income",
                      icon: tx["icon"],
                      formatter: _currencyFormatter,
                    )),
              ],
          ],
        ),
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final double totalIncome;
  final double totalExpense;
  final NumberFormat formatter;
  final int? selectedWalletId;
  final List<dynamic> wallets;
  final ValueChanged<int?> onWalletChanged;

  const SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.formatter,
    required this.selectedWalletId,
    required this.wallets,
    required this.onWalletChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int?>(
                  value: selectedWalletId,
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text("Tất cả ví"),
                    ),
                    ...wallets.map<DropdownMenuItem<int?>>((wallet) {
                      return DropdownMenuItem<int?>(
                        value: wallet['id'] as int,
                        child: Text(wallet['wallet_name']),
                      );
                    }).toList(),
                  ],
                  onChanged: onWalletChanged,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text("Thu nhập", style: TextStyle(color: Colors.green)),
                    Text(
                      "+${formatter.format(totalIncome)}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text("Chi tiêu", style: TextStyle(color: Colors.red)),
                    Text(
                      "-${formatter.format(totalExpense)}",
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionItem extends StatelessWidget {
  final String title;
  final double amount;
  final bool isIncome;
  final IconData icon;
  final NumberFormat formatter;

  const TransactionItem({
    super.key,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(icon, color: isIncome ? Colors.green : Colors.red),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          (isIncome ? "+ " : "- ") + formatter.format(amount),
          style: TextStyle(
            color: isIncome ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
