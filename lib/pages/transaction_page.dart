import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../services/wallet_service.dart';
import '../widgets/gradient_scaffold.dart';
import 'transaction_detail_page.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  List<dynamic> _wallets = [];
  int? _selectedWalletId;
  String _filter = "all"; // all, income, expense

  @override
  void initState() {
    super.initState();
    _fetchWallets();
    // fetch transactions lần đầu
    Future.microtask(() {
      context.read<TransactionProvider>().loadTransactions();
    });
  }

  Future<void> _fetchWallets() async {
    try {
      final wallets = await WalletService.getWallets();
      setState(() => _wallets = wallets);
    } catch (e) {
      debugPrint("Error fetching wallets: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transactions = provider.transactions;

    // lọc theo loại
    final filtered = transactions.where((tx) {
      if (_filter == "all") return true;
      return _filter == "income"
          ? tx.categoryType == "thu"
          : tx.categoryType == "chi";
    }).toList();

    // nhóm theo ngày
    final grouped = <String, List<Transaction>>{};
    for (var tx in filtered) {
      final dateStr = DateFormat("dd/MM/yyyy").format(tx.transactionDate);
      grouped.putIfAbsent(dateStr, () => []).add(tx);
    }

    // tính tổng
    final totalIncome = transactions
        .where((tx) => tx.categoryType == "thu")
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final totalExpense = transactions
        .where((tx) => tx.categoryType == "chi")
        .fold<double>(0, (sum, tx) => sum + tx.amount);

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
        onRefresh: () => context.read<TransactionProvider>().loadTransactions(
          walletId: _selectedWalletId,
        ),
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
                context.read<TransactionProvider>().loadTransactions(
                  walletId: val,
                );
              },
              isLoading: provider.isLoading,
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
                ...entry.value.map(
                  (tx) => TransactionItem(
                    title: tx.categoryName,
                    amount: tx.amount,
                    isIncome: tx.categoryType == "thu",
                    icon: tx.categoryType == "thu"
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    formatter: _currencyFormatter,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TransactionDetailPage(transaction: tx),
                        ),
                      );
                    },
                  ),
                ),
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
  final bool isLoading;

  const SummaryCard({
    super.key,
    required this.totalIncome,
    required this.totalExpense,
    required this.formatter,
    required this.selectedWalletId,
    required this.wallets,
    required this.onWalletChanged,
    required this.isLoading,
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
                    const Text(
                      "Thu nhập",
                      style: TextStyle(color: Colors.green),
                    ),
                    isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
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
                    isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
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
  final VoidCallback? onTap;

  const TransactionItem({
    super.key,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.icon,
    required this.formatter,
    this.onTap,
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
        onTap: onTap,
      ),
    );
  }
}
