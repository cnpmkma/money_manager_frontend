import 'package:flutter/material.dart';
import 'package:money_manager_frontend/pages/login_page.dart';
import 'package:money_manager_frontend/pages/profile_page.dart';
import 'package:money_manager_frontend/services/auth_service.dart';
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
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        elevation: 2,
        child: ListTile(
          leading: Container(
            decoration: BoxDecoration(
              color:
                  iconColor?.withOpacity(0.1) ?? Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: iconColor ?? Colors.blue),
          ),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
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
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                CircleAvatar(radius: 40, backgroundImage: AssetImage(avatar)),
                const SizedBox(height: 10),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(email, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 30),

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
            onTap: () {},
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
        ],
      ),
    );
  }
}
