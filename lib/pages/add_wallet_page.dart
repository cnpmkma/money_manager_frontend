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
  int _selectedSkin = 1; // default skin

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await WalletService.createWallet(
        _nameController.text,
        double.tryParse(_balanceController.text) ?? 0,
        skinIndex: _selectedSkin, 
      );
      widget.onWalletAdded(); 
      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error adding wallet: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thêm ví thất bại")),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skinOptions = List.generate(12, (i) => i + 1);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm ví mới"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Tên ví"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Nhập tên ví" : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _balanceController,
                decoration: const InputDecoration(labelText: "Số dư ban đầu"),
                keyboardType: TextInputType.number,
                validator: (v) =>
                    v == null || v.isEmpty ? "Nhập số dư" : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<int>(
                value: _selectedSkin,
                decoration: const InputDecoration(labelText: "Skin"),
                items: skinOptions
                    .map((skin) => DropdownMenuItem(
                          value: skin,
                          child: Row(
                            children: [
                              Image.asset(
                                "assets/skin_$skin.png",
                                width: 32,
                                height: 32,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 12),
                              Text("Skin $skin"),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSkin = val);
                },
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Thêm ví"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
