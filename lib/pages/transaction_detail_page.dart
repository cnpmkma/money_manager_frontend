import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';

class TransactionDetailPage extends StatefulWidget {
  final Map<String, dynamic>? transaction; // null = thêm mới
  final VoidCallback? onDelete;

  const TransactionDetailPage({super.key, this.transaction, this.onDelete});

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  int? _selectedWalletId;
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  List<dynamic> _wallets = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWallets();
    if (widget.transaction != null) {
      final tx = widget.transaction!;
      _amountController.text = (tx['amount'] as num).toString();
      _noteController.text = tx['note'] ?? '';
      _selectedWalletId = tx['wallet_id'];
      _selectedCategoryId = tx['category_id'];
      _selectedDate = DateTime.parse(tx['transaction_date']);
    }
  }

  Future<void> _fetchWallets() async {
    try {
      final wallets = await WalletService.getWallets();
      setState(() => _wallets = wallets);
    } catch (e) {
      debugPrint("Error fetching wallets: $e");
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Chọn ví và danh mục")));
      return;
    }

    setState(() => _isLoading = true);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final note = _noteController.text;

    try {
      if (widget.transaction == null) {
        // Thêm mới
        await TransactionService.addTransaction(
          amount: amount,
          note: note,
          walletId: _selectedWalletId!,
          categoryId: _selectedCategoryId!,
          transactionDate: _selectedDate,
        );
      } else {
        // Cập nhật
        await TransactionService.updateTransaction(
          id: widget.transaction!['id'],
          amount: amount,
          note: note,
          walletId: _selectedWalletId!,
          categoryId: _selectedCategoryId!,
          transactionDate: _selectedDate,
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint("Error saving transaction: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Lỗi khi lưu giao dịch")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTransaction() async {
    if (widget.transaction == null) return;
    if (widget.onDelete != null) widget.onDelete!();
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transaction == null ? "Thêm giao dịch" : "Chi tiết"),
        actions: [
          if (widget.transaction != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    // Số tiền
                    TextFormField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Số tiền"),
                      validator: (val) {
                        if (val == null || val.isEmpty) return "Nhập số tiền";
                        if (double.tryParse(val) == null) return "Số tiền không hợp lệ";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Ghi chú
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: "Ghi chú"),
                    ),
                    const SizedBox(height: 16),
                    // Chọn ví
                    DropdownButtonFormField<int>(
                      value: _selectedWalletId,
                      decoration: const InputDecoration(labelText: "Ví"),
                      items: _wallets
                          .map<DropdownMenuItem<int>>((w) => DropdownMenuItem(
                                value: w['id'],
                                child: Text(w['wallet_name']),
                              ))
                          .toList(),
                      onChanged: (val) => setState(() => _selectedWalletId = val),
                      validator: (val) => val == null ? "Chọn ví" : null,
                    ),
                    const SizedBox(height: 16),
                    // Chọn danh mục (ví dụ tạm)
                    DropdownButtonFormField<int>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(labelText: "Danh mục"),
                      items: const [
                        DropdownMenuItem(value: 1, child: Text("Ăn uống")),
                        DropdownMenuItem(value: 2, child: Text("Thu nhập khác")),
                      ],
                      onChanged: (val) => setState(() => _selectedCategoryId = val),
                      validator: (val) => val == null ? "Chọn danh mục" : null,
                    ),
                    const SizedBox(height: 16),
                    // Chọn ngày
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Ngày giao dịch"),
                      subtitle: Text(DateFormat("dd/MM/yyyy").format(_selectedDate)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) setState(() => _selectedDate = date);
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _saveTransaction,
                      child: Text(widget.transaction == null ? "Thêm" : "Cập nhật"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
