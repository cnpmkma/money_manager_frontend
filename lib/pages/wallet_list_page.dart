// wallet_list_page.dart
import 'package:flutter/material.dart';
import 'package:money_manager_frontend/services/wallet_service.dart';
import 'package:intl/intl.dart';
import 'add_wallet_page.dart';

class WalletListPage extends StatefulWidget {
  final VoidCallback onBack;
  const WalletListPage({super.key, required this.onBack});

  @override
  State<WalletListPage> createState() => _WalletListPageState();
}

class _WalletListPageState extends State<WalletListPage> {
  List<dynamic> _wallets = [];
  bool _loading = true;
  final _formatter = NumberFormat("#,##0", "vi_VN");

  @override
  void initState() {
    super.initState();
    _fetchWallets();
  }

  Future<void> _fetchWallets() async {
    try {
      final wallets = await WalletService.getWallets();
      setState(() {
        _wallets = wallets;
        _loading = false;
      });
    } catch (e) {
      print("Error fetching wallets: $e");
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tất cả ví"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack, // <-- dùng widget.onBack
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _wallets.length + 1,
              itemBuilder: (context, index) {
                if (index == _wallets.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) => AddWalletPage(
                            onWalletAdded: () {
                              _fetchWallets(); // reload danh sách ví
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text("Thêm ví mới"),
                    ),
                  );
                }

                final wallet = _wallets[index];
                final balance = double.tryParse(wallet['balance'].toString()) ?? 0;

                return Column(
                  children: [
                    ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.account_balance_wallet, color: Colors.brown),
                      ),
                      title: Text(wallet['wallet_name']),
                      trailing: Text(
                        "${_formatter.format(balance)}₫",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(height: 1),
                  ],
                );
              },
            ),
    );
  }
}
