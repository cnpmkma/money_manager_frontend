import 'package:flutter/material.dart';
import 'package:money_manager_frontend/services/wallet_service.dart';

class EditWalletPage extends StatefulWidget {
  final int walletId;
  final String initialName;
  final double initialBalance;
  final VoidCallback onWalletUpdated;

  const EditWalletPage({
    super.key,
    required this.walletId,
    required this.initialName,
    required this.initialBalance,
    required this.onWalletUpdated,
  });

  @override
  State<EditWalletPage> createState() => _EditWalletPageState();
}

class _EditWalletPageState extends State<EditWalletPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _balanceController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _balanceController = TextEditingController(
      text: widget.initialBalance.toString(),
    );
  }

  Future<void> _updateWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await WalletService.updateWallet(
        widget.walletId,
        _nameController.text,
        double.tryParse(_balanceController.text) ?? 0,
      );
      widget.onWalletUpdated();
      Navigator.pop(context); // đóng modal
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi cập nhật ví: $e")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets, // tránh bàn phím che
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Sửa ví", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Tên ví"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Nhập tên ví" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _balanceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Số dư"),
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                    ? "Nhập số dư hợp lệ"
                    : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _updateWallet,
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Lưu thay đổi"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
