import 'package:flutter/material.dart';
import 'package:money_manager_frontend/pages/login_page.dart';
import 'package:money_manager_frontend/pages/profile_page.dart';
import 'package:money_manager_frontend/services/auth_service.dart';
import 'package:money_manager_frontend/services/export_service.dart'
    as ExportService;
import 'package:money_manager_frontend/services/transaction_service.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  Map<String, dynamic> user = {};

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final data = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      user = data;
    });
  }

  Widget buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          leading: Container(
            decoration: BoxDecoration(
              color: (iconColor ?? Colors.blue).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: iconColor ?? Colors.blue, size: 28),
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
          onTap: onTap,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final username = user['username'] ?? '';
    final email = user['email'] ?? '';
    final avatar = user['avatar'] ?? 'assets/avatar.png';

    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        title: const Text("Tài khoản"),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 30),
          Center(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.deepPurple.shade200,
                        Colors.deepPurple.shade400,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4), // độ dày viền
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage(avatar),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),

          // Menu items
          buildMenuItem(
            icon: Icons.person,
            title: "Account",
            iconColor: Colors.purple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              ).then((_) => loadUser());
            },
          ),
          buildMenuItem(
            icon: Icons.settings,
            title: "Settings",
            iconColor: Colors.indigo,
            onTap: () {},
          ),
          buildMenuItem(
            icon: Icons.upload_file,
            title: "Export Data",
            iconColor: Colors.pink,
            onTap: () async {
              try {
                final transactions = await TransactionService.getTransactions();
                await ExportService.exportTransactionsToExcel(transactions);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Xuất Excel thành công!"),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Lỗi khi xuất Excel: $e"),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
          ),
          buildMenuItem(
            icon: Icons.logout,
            title: "Logout",
            iconColor: Colors.red,
            onTap: () async {
              await AuthService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const Login()),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
