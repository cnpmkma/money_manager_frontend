import 'package:flutter/material.dart';
import 'package:money_manager_frontend/services/wallet_service.dart';
import 'package:intl/intl.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';
import 'wallet_add_page.dart';
import 'wallet_edit_page.dart';

class WalletListPage extends StatefulWidget {
  const WalletListPage({super.key});

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
    return GradientScaffold(
      appBar: AppBar(
        title: const Text("Tất cả ví"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, true); // pop + trả flag
          },
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
                    child: Center(
                      child: SizedBox(
                        width: 200,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddWalletPage(
                                  onWalletAdded: () {
                                    _fetchWallets(); // reload danh sách ví
                                  },
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text("Thêm ví mới"),
                          style: ElevatedButton.styleFrom(
                            elevation: 4,
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            shadowColor: Colors.black26,
                          ),
                        ),
                      ),
                    ),
                  );
                }

                final wallet = _wallets[index];
                final balance =
                    double.tryParse(wallet['balance'].toString()) ?? 0;

                return Column(
                  children: [
                    ListTile(
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image(
                          image: AssetImage(
                            "assets/skin_${wallet['skin_index'] ?? 1}.png",
                          ),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),

                      title: Text(wallet['wallet_name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${_formatter.format(balance)}₫",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == "edit") {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditWalletPage(
                                      walletId: wallet['id'],
                                      initialName: wallet['wallet_name'],
                                      initialSkin: wallet['skin_index'] ?? 1,
                                      onWalletUpdated: () {
                                        _fetchWallets();
                                      },
                                    ),
                                  ),
                                );
                              } else if (value == "delete") {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text("Xóa ví"),
                                      content: Text(
                                        "Bạn có chắc chắn muốn xóa ví '${wallet['wallet_name']}' không?",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text("Hủy"),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () async {
                                            try {
                                              await WalletService.deleteWallet(
                                                wallet['id'],
                                              );
                                              Navigator.pop(
                                                context,
                                              ); // đóng dialog
                                              _fetchWallets(); // refresh list
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    "Xóa ví thành công",
                                                  ),
                                                  backgroundColor: Colors.green,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: EdgeInsets.all(16),
                                                ),
                                              );
                                            } catch (e) {
                                              Navigator.pop(context);
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    "Lỗi khi xóa ví: $e",
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  margin: const EdgeInsets.all(
                                                    16,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          child: const Text(
                                            "Xóa",
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'edit',
                                child: Text('Sửa'),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Text('Xóa'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    const Divider(height: 1),
                  ],
                );
              },
            ),
    );
  }
}
