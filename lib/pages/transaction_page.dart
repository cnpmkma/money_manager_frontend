import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/transaction_service.dart';
import '../services/wallet_service.dart';
import '../widgets/gradient_scaffold.dart';
import 'transaction_add_page.dart';
import '../constants/category_icons.dart';

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
  if (!mounted) return;
  setState(() => _isLoading = true);

  try {
    final transactions = await TransactionService.getTransactions(
      walletId: _selectedWalletId,
    );
    if (!mounted) return; // check lần nữa sau await

    setState(() {
      _transactions = transactions;
      _sortTransactions();
    });
  } catch (e) {
    debugPrint("Error fetching transactions: $e");
    if (!mounted) return;
    setState(() => _transactions = []);
  } finally {
    if (!mounted) return;
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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.deepPurple, width: 1),
    );

    return Row(
      children: [
        Flexible(
          flex: 2,
          child: DropdownButtonFormField<String>(
            value: selectedType,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              filled: true,
              fillColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
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
            value: selectedWalletId,
            isExpanded: true, // <--- thêm dòng này
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              filled: true,
              fillColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text("Tất cả ví", overflow: TextOverflow.ellipsis),
              ),
              ...wallets.map(
                (w) => DropdownMenuItem<int?>(
                  value: w['id'] as int,
                  child: Text(
                    w['wallet_name'],
                    overflow: TextOverflow.ellipsis,
                  ),
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
            value: sortOrder,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border,
              filled: true,
              fillColor: Colors.white,
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
            style: const TextStyle(fontSize: 14, color: Colors.black87),
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

class SummaryCard extends StatefulWidget {
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
  State<SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<SummaryCard> {
  double totalIncome = 0;
  double totalExpense = 0;

  @override
  void didUpdateWidget(covariant SummaryCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactions != widget.transactions ||
        oldWidget.selectedType != widget.selectedType) {
      _calculateTotals();
    }
  }

  @override
  void initState() {
    super.initState();
    _calculateTotals();
  }

  void _calculateTotals() {
    final filtered = widget.transactions.where((tx) {
      if (widget.selectedType == "all") return true;
      return widget.selectedType == "thu"
          ? tx['category']['type'] == "thu"
          : tx['category']['type'] == "chi";
    }).toList();

    setState(() {
      totalIncome = filtered
          .where((tx) => tx['category']['type'] == "thu")
          .fold<double>(0, (sum, tx) => sum + double.parse(tx['amount']));
      totalExpense = filtered
          .where((tx) => tx['category']['type'] == "chi")
          .fold<double>(0, (sum, tx) => sum + double.parse(tx['amount']));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildCard(
            label: "Thu nhập",
            amount: totalIncome,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildCard(
            label: "Chi tiêu",
            amount: totalExpense,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({
    required String label,
    required double amount,
    required Color color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: amount),
              duration: const Duration(milliseconds: 500),
              builder: (context, value, child) {
                return Text(
                  "${amount >= 0 ? "+" : "-"} ${widget.formatter.format(value)}",
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
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

  String truncateNote(String? note, {int charLimit = 20}) {
    if (note == null) return '';
    return note.length <= charLimit
        ? note
        : note.substring(0, charLimit) + '...';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome
              ? Colors.green.shade100
              : Colors.red.shade100,
          child: Icon(
            categoryIcons[title] ?? Icons.category,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              truncateNote(note),
              style: const TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
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
