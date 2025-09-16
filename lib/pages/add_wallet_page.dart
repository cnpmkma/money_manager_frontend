// add_wallet_page.dart
import 'package:flutter/material.dart';
import 'package:money_manager_frontend/services/wallet_service.dart';

class AddWalletPage extends StatefulWidget {
  final VoidCallback onWalletAdded;
  const AddWalletPage({super.key, required this.onWalletAdded});

  @override
  State<AddWalletPage> createState() => _AddWalletPageState();
}

class _AddWalletPageState extends State<AddWalletPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  bool _loading = false;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await WalletService.createWallet(
        _nameController.text,
        double.tryParse(_balanceController.text) ?? 0,
      );
      widget.onWalletAdded(); 
      Navigator.pop(context);
    } catch (e) {
      print("Error adding wallet: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Thêm ví thất bại")));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Thêm ví mới",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Tên ví"),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Nhập tên ví" : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _balanceController,
                  decoration: InputDecoration(labelText: "Số dư ban đầu"),
                  keyboardType: TextInputType.number,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Nhập số dư" : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Thêm"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
