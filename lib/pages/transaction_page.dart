import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/transaction_service.dart';
import '../services/wallet_service.dart';
import '../widgets/gradient_scaffold.dart';
import 'add_transaction_page.dart';

class TransactionPage extends StatefulWidget {
  final Future<void> Function(BuildContext context)? onAdd;

  const TransactionPage({super.key, this.onAdd});

  @override
  State<TransactionPage> createState() => TransactionPageState();
}

class TransactionPageState extends State<TransactionPage> {
  final _currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  List<dynamic> _wallets = [];
  int? _selectedWalletId;
  String _selectedType = "all"; // "all", "chi", "thu"
  String _sortOrder = "desc"; // "asc", "desc"
  List<dynamic> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWallets();
    _loadTransactions();
  }

  Future<void> _fetchWallets() async {
    try {
      final wallets = await WalletService.getWallets();
      setState(() => _wallets = wallets);
    } catch (e) {
      debugPrint("Error fetching wallets: $e");
    }
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    try {
      final transactions = await TransactionService.getTransactions(
        walletId: _selectedWalletId,
      );
      setState(() {
        _transactions = transactions;
        _sortTransactions();
      });
    } catch (e) {
      debugPrint("Error fetching transactions: $e");
      setState(() => _transactions = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _sortTransactions() {
    _transactions.sort((a, b) {
      final dateA = DateTime.parse(a['transaction_date']);
      final dateB = DateTime.parse(b['transaction_date']);
      return _sortOrder == "desc"
          ? dateB.compareTo(dateA)
          : dateA.compareTo(dateB);
    });
  }

  Future<void> _deleteTransaction(int id) async {
    setState(() => _isLoading = true);
    try {
      await TransactionService.deleteTransaction(id);
      await _loadTransactions();
    } catch (e) {
      debugPrint("Error deleting transaction: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void reload() {
    _loadTransactions();
  }

  Future<void> openAddTransaction(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionPage()),
    );
    if (result == true) {
      _loadTransactions(); // reload khi thêm thành công
    }
  }

  @override
  Widget build(BuildContext context) {
    // lọc theo loại
    final filteredTransactions = _transactions.where((tx) {
      if (_selectedType == "all") return true;
      return _selectedType == "thu"
          ? tx['category']['type'] == "thu"
          : tx['category']['type'] == "chi";
    }).toList();

    // nhóm theo ngày
    final grouped = <String, List<dynamic>>{};
    for (var tx in filteredTransactions) {
      final dateStr = DateFormat(
        "dd/MM/yyyy",
      ).format(DateTime.parse(tx['transaction_date']));
      grouped.putIfAbsent(dateStr, () => []).add(tx);
    }

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Sổ giao dịch"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadTransactions,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Filter Row
            TransactionFilterRow(
              selectedType: _selectedType,
              selectedWalletId: _selectedWalletId,
              sortOrder: _sortOrder,
              wallets: _wallets,
              onTypeChanged: (val) {
                if (val != null) setState(() => _selectedType = val);
              },
              onWalletChanged: (val) {
                setState(() => _selectedWalletId = val);
                _loadTransactions();
              },
              onSortOrderChanged: (val) {
                setState(() {
                  _sortOrder = val;
                  _sortTransactions();
                });
              },
            ),
            const SizedBox(height: 12),
            // Summary Card
            SummaryCard(
              transactions: _transactions,
              selectedType: _selectedType,
              formatter: _currencyFormatter,
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (grouped.isEmpty)
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
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                ...entry.value.map(
                  (tx) => TransactionItem(
                    title: tx['category']['category_name'],
                    note: tx['note'],
                    amount: double.parse(tx['amount']),
                    isIncome: tx['category']['type'] == "thu",
                    formatter: _currencyFormatter,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddTransactionPage(transaction: tx),
                        ),
                      );
                      if (result == true) _loadTransactions();
                    },
                    onDelete: () => _deleteTransaction(tx['id']),
                  ),
                ),
              ],
          ],
        ),
      ),
    );
  }
}

// Filter Row
class TransactionFilterRow extends StatelessWidget {
  final String selectedType;
  final int? selectedWalletId;
  final String sortOrder;
  final List<dynamic> wallets;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<int?> onWalletChanged;
  final ValueChanged<String> onSortOrderChanged;

  const TransactionFilterRow({
    super.key,
    required this.selectedType,
    required this.selectedWalletId,
    required this.sortOrder,
    required this.wallets,
    required this.onTypeChanged,
    required this.onWalletChanged,
    required this.onSortOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: selectedType,
            items: const [
              DropdownMenuItem(value: "all", child: Text("Tất cả")),
              DropdownMenuItem(value: "chi", child: Text("Chi")),
              DropdownMenuItem(value: "thu", child: Text("Thu")),
            ],
            onChanged: onTypeChanged,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<int?>(
            initialValue: selectedWalletId,
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text("Tất cả ví"),
              ),
              ...wallets.map(
                (w) => DropdownMenuItem<int?>(
                  value: w['id'] as int,
                  child: Text(w['wallet_name']),
                ),
              ),
            ],
            onChanged: onWalletChanged,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<String>(
            initialValue: sortOrder,
            items: const [
              DropdownMenuItem(value: "desc", child: Text("Mới nhất")),
              DropdownMenuItem(value: "asc", child: Text("Cũ nhất")),
            ],
            onChanged: (val) {
              if (val != null) onSortOrderChanged(val);
            },
          ),
        ),
      ],
    );
  }
}

// Summary Card
class SummaryCard extends StatelessWidget {
  final List<dynamic> transactions;
  final String selectedType;
  final NumberFormat formatter;

  const SummaryCard({
    super.key,
    required this.transactions,
    required this.selectedType,
    required this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    final filtered = transactions.where((tx) {
      if (selectedType == "all") return true;
      return selectedType == "thu"
          ? tx['category']['type'] == "thu"
          : tx['category']['type'] == "chi";
    }).toList();

    final totalIncome = filtered
        .where((tx) => tx['category']['type'] == "thu")
        .fold<double>(0, (sum, tx) => sum + double.parse(tx['amount']));
    final totalExpense = filtered
        .where((tx) => tx['category']['type'] == "chi")
        .fold<double>(0, (sum, tx) => sum + double.parse(tx['amount']));

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                const Text(
                  "Thu nhập",
                  style: TextStyle(color: Colors.green, fontSize: 20),
                ),
                Text(
                  "+${formatter.format(totalIncome)}",
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                const Text(
                  "Chi tiêu",
                  style: TextStyle(color: Colors.red, fontSize: 20),
                ),
                Text(
                  "-${formatter.format(totalExpense)}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Transaction Item
class TransactionItem extends StatelessWidget {
  final String title;
  final String? note;
  final double amount;
  final bool isIncome;
  final NumberFormat formatter;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionItem({
    super.key,
    required this.title,
    this.note,
    required this.amount,
    required this.isIncome,
    required this.formatter,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        title: Padding(
          padding: const EdgeInsets.fromLTRB(15, 0, 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                note ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
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
