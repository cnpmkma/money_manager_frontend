import 'package:flutter/material.dart';
import 'package:money_manager_frontend/pages/login_page.dart';
import 'package:money_manager_frontend/services/auth_service.dart';
import 'package:money_manager_frontend/widgets/gradient_scaffold.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    return GradientScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text("Tài khoản"), 
        centerTitle: true
        ),
      body: ListView(
        children: [
          const SizedBox(height: 20),

          // Thông tin user
          Center(
            child: Column(
              children: const [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage(
                    "assets/avatar.png",
                  ), // TODO: đổi sang avatar user
                ),
                SizedBox(height: 10),
                Text(
                  "Nguyễn Văn A",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  "nguyenvana@example.com",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          const Divider(),

          // Các tùy chọn
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Hồ sơ cá nhân"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: mở trang profile
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Bảo mật & Đăng nhập"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: mở trang bảo mật
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Cài đặt thông báo"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: mở trang thông báo
            },
          ),
          ListTile(
            leading: const Icon(Icons.color_lens),
            title: const Text("Chủ đề"),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: đổi theme dark/light
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Đăng xuất", style: TextStyle(color: Colors.red)),
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
