import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import '../providers/transaction_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/category_provider.dart';
import '../widgets/gradient_scaffold.dart';

class TransactionDetailPage extends StatefulWidget {
  final Transaction transaction;
  const TransactionDetailPage({super.key, required this.transaction});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  bool _isEditing = false;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  late int _selectedWalletId;
  late int _selectedCategoryId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _selectedWalletId = widget.transaction.walletId;
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedDate = widget.transaction.transactionDate;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletProvider = context.read<WalletProvider>();
      final categoryProvider = context.read<CategoryProvider>();

      if (walletProvider.wallets.isEmpty) {
        walletProvider.loadWallets();
      }

      if (categoryProvider.categories.isEmpty) {
        categoryProvider.loadCategories();
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    // Loading indicator
    if (walletProvider.loading ||
        walletProvider.wallets.isEmpty ||
        categoryProvider.isLoading ||
        categoryProvider.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Tìm wallet + category
    final wallet = walletProvider.wallets.firstWhere(
      (w) => w['id'] == _selectedWalletId,
      orElse: () => {'wallet_name': 'Không xác định'},
    );

    final category = categoryProvider.categories.firstWhere(
      (c) => c['id'] == _selectedCategoryId,
      orElse: () => {'category_name': 'Không xác định', 'type': 'thu'},
    );

    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Chi tiết giao dịch"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () async {
              if (_isEditing) {
                // Save
                try {
                  await TransactionService.updateTransaction(
                    id: widget.transaction.id,
                    amount: double.parse(_amountController.text),
                    note: _noteController.text,
                    walletId: _selectedWalletId,
                    categoryId: _selectedCategoryId,
                    transactionDate: _selectedDate,
                  );
                  context.read<TransactionProvider>().loadTransactions();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Cập nhật giao dịch thành công"),
                    ),
                  );
                  setState(() => _isEditing = false);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Xác nhận"),
                    content: const Text("Bạn có chắc muốn xóa giao dịch này?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text("Hủy"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text("Xóa"),
                      ),
                    ],
                  ),
                );
                if (confirm != true) return;

                try {
                  await TransactionService.deleteTransaction(
                    widget.transaction.id,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Xóa giao dịch thành công")),
                  );
                  context.read<TransactionProvider>().loadTransactions();
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
                }
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Card số tiền + loại
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: category['type'] == 'thu'
                    ? Colors.green[50]
                    : Colors.red[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _isEditing
                      ? DropdownButtonFormField<int>(
                          value: _selectedCategoryId,
                          items: categoryProvider.categories
                              .map(
                                (c) => DropdownMenuItem<int>(
                                  value: c['id'] as int,
                                  child: Text(c['category_name']),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedCategoryId = val!),
                          decoration: const InputDecoration(
                            labelText: "Danh mục",
                          ),
                        )
                      : Text(
                          category['category_name'],
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                  const SizedBox(height: 10),
                  _isEditing
                      ? TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Số tiền",
                          ),
                        )
                      : Text(
                          "${category['type'] == 'thu' ? '+' : '-'} ${currencyFormatter.format(widget.transaction.amount)}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: category['type'] == 'thu'
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Thông tin khác
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _isEditing
                        ? DropdownButtonFormField<int>(
                            value: _selectedWalletId,
                            items: walletProvider.wallets
                                .map(
                                  (w) => DropdownMenuItem<int>(
                                    value: w['id'] as int,
                                    child: Text(w['wallet_name']),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedWalletId = val!),
                            decoration: const InputDecoration(labelText: "Ví"),
                          )
                        : _infoRow(
                            Icons.account_balance_wallet,
                            "Ví",
                            wallet['wallet_name'],
                          ),
                    const Divider(),
                    _isEditing
                        ? ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              DateFormat('dd/MM/yyyy').format(_selectedDate),
                            ),
                            trailing: const Icon(Icons.edit_calendar),
                            onTap: _pickDate,
                          )
                        : _infoRow(
                            Icons.calendar_today,
                            "Ngày",
                            DateFormat(
                              'dd/MM/yyyy',
                            ).format(widget.transaction.transactionDate),
                          ),
                    const Divider(),
                    _isEditing
                        ? TextField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: "Ghi chú",
                            ),
                          )
                        : _infoRow(
                            Icons.note,
                            "Ghi chú",
                            widget.transaction.note ?? '-',
                          ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 12),
        Text("$label:", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}
