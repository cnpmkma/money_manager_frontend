import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/transaction_service.dart';
import '../services/wallet_service.dart';
import '../services/category_service.dart';
import '../widgets/gradient_scaffold.dart';

class AddTransactionPage extends StatefulWidget {
  final Map<String, dynamic>? transaction;
  const AddTransactionPage({super.key, this.transaction});

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  int? _selectedWalletId;
  int? _selectedCategoryId;

  List<dynamic> _wallets = [];
  List<dynamic> _categories = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchWallets();
    _fetchCategories();

    if (widget.transaction != null) {
      final tx = widget.transaction!;
      _amountController.text = tx['amount'].toString();
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

  Future<void> _fetchCategories() async {
    try {
      final categories = await CategoryService.getCategories();
      setState(() => _categories = categories);
    } catch (e) {
      debugPrint("Error fetching categories: $e");
    }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng chọn ví và danh mục"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    final amount = double.tryParse(_amountController.text) ?? 0;
    final note = _noteController.text;

    try {
      if (widget.transaction != null) {
        await TransactionService.updateTransaction(
          id: widget.transaction!['id'],
          amount: amount,
          note: note,
          walletId: _selectedWalletId!,
          categoryId: _selectedCategoryId!,
          transactionDate: _selectedDate,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Cập nhật giao dịch thành công"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      } else {
        await TransactionService.addTransaction(
          amount: amount,
          note: note,
          walletId: _selectedWalletId!,
          categoryId: _selectedCategoryId!,
          transactionDate: _selectedDate,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Thêm giao dịch thành công"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: Text(
          widget.transaction != null ? "Chỉnh sửa giao dịch" : "Thêm giao dịch",
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    Center(
                      child: Text(
                        "Giá trị giao dịch",
                        style: TextStyle(fontSize: 22, color: Colors.grey[600]),
                      ),
                    ),
                    SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 300,
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.attach_money,
                              color: Colors.green,
                            ),
                            suffixText: "VND",
                            suffixStyle: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 18,
                              horizontal: 16,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          validator: (v) =>
                              v == null || v.isEmpty ? "Nhập số tiền" : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // chọn ví
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Chọn ví",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            initialValue: _selectedWalletId,
                            items: _wallets.map((w) {
                              return DropdownMenuItem(
                                value: w['id'] as int,
                                child: Text(
                                  "${w['wallet_name']} (${w['balance']}₫)",
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedWalletId = val),
                            validator: (v) => v == null ? "Chọn ví" : null,
                          ),

                          const SizedBox(height: 16),

                          // chọn danh mục
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              label: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Chọn danh mục",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            initialValue: _selectedCategoryId,
                            items: _categories.map((c) {
                              return DropdownMenuItem<int>(
                                value: c['id'] as int,
                                child: Text(
                                  "${c['category_name']} (${c['type']})",
                                ),
                              );
                            }).toList(),
                            onChanged: (val) =>
                                setState(() => _selectedCategoryId = val),
                            validator: (v) =>
                                v == null ? "Chọn danh mục" : null,
                          ),

                          const SizedBox(height: 16),

                          // chọn ngày
                          ListTile(
                            leading: const Icon(Icons.calendar_today),
                            title: Text(
                              DateFormat("dd/MM/yyyy").format(_selectedDate),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: const Icon(Icons.edit_calendar),
                            onTap: _pickDate,
                          ),

                          const SizedBox(height: 16),

                          // ghi chú
                          TextFormField(
                            controller: _noteController,
                            decoration: const InputDecoration(
                              labelText: "Ghi chú",
                              border: OutlineInputBorder(),
                            ),
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: _submit,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: const Color(0xFF7F55B1),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            widget.transaction != null
                                ? "Cập nhật"
                                : "Lưu giao dịch",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (widget.transaction != null) ...[
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text(
                                    "Xóa giao dịch",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  content: const Text(
                                    "Bạn có chắc muốn xóa giao dịch này không?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: const Text("Hủy"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text(
                                        "Xóa",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await TransactionService.deleteTransaction(
                                    widget.transaction!['id'],
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Đã xóa giao dịch"),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(16),
                                    ),
                                  );
                                  Navigator.pop(context, true);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Lỗi: $e"),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: const EdgeInsets.all(16),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text(
                              "Xóa",
                              style: TextStyle(
                                fontWeight: FontWeight.w100,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}
