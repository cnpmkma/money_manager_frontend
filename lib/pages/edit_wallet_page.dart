import 'package:flutter/material.dart';
import 'package:money_manager_frontend/services/wallet_service.dart';

class EditWalletPage extends StatefulWidget {
  final int walletId;
  final String initialName;
  final int initialSkin;
  final VoidCallback onWalletUpdated;

  const EditWalletPage({
    super.key,
    required this.walletId,
    required this.initialName,
    required this.initialSkin,
    required this.onWalletUpdated,
  });

  @override
  State<EditWalletPage> createState() => _EditWalletPageState();
}

class _EditWalletPageState extends State<EditWalletPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  bool _loading = false;
  late int _selectedSkin;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _selectedSkin = widget.initialSkin;
  }

  Future<void> _updateWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await WalletService.updateWallet(
        widget.walletId,
        _nameController.text,
        skinIndex: _selectedSkin, // chỉ cập nhật tên + skin
      );
      widget.onWalletUpdated();
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi cập nhật ví: $e")),
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
        title: const Text("Sửa ví"),
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
                  onPressed: _loading ? null : _updateWallet,
                  child: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text("Lưu thay đổi"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
