import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_frontend/services/transaction_service.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';
import 'package:provider/provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/category_provider.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({super.key});

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

  @override
  void initState() {
    super.initState();
    // load wallets khi mở page
    Future.microtask(() =>
        context.read<WalletProvider>().loadWallets());
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
        const SnackBar(content: Text("Vui lòng chọn ví và danh mục")),
      );
      return;
    }

    try {
      final res = await TransactionService.addTransaction(
        amount: double.parse(_amountController.text),
        note: _noteController.text,
        walletId: _selectedWalletId!,
        categoryId: _selectedCategoryId!,
        transactionDate: _selectedDate,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm giao dịch thành công")),
      );

      Navigator.pop(context, res);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletProvider = context.watch<WalletProvider>();

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text("Thêm giao dịch"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Số tiền",
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? "Nhập số tiền" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: "Ghi chú",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(DateFormat("dd/MM/yyyy").format(_selectedDate)),
                trailing: const Icon(Icons.edit_calendar),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // 📌 Dropdown ví (dùng WalletProvider)
              walletProvider.loading
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: "Chọn ví",
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedWalletId,
                      items: walletProvider.wallets.map((w) {
                        return DropdownMenuItem(
                          value: w["id"] as int,
                          child: Text(
                              "${w["wallet_name"]} (${w["balance"]}₫)"),
                        );
                      }).toList(),
                      onChanged: (val) =>
                          setState(() => _selectedWalletId = val),
                      validator: (v) => v == null ? "Chọn ví" : null,
                    ),
              const SizedBox(height: 16),

              Consumer<CategoryProvider>(
                builder: (context, categoryProvider, _) {
                  if (categoryProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  return DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: "Chọn danh mục",
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedCategoryId,
                    items: categoryProvider.categories.map((c) {
                      return DropdownMenuItem<int>(
                        value: c["id"] as int,
                        child: Text("${c["category_name"]} (${c["type"]})"),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategoryId = val),
                    validator: (v) => v == null ? "Chọn danh mục" : null,
                  );
                },
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Lưu giao dịch"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
