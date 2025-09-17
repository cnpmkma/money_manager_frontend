// profile_page.dart
import 'package:flutter/material.dart';
import 'package:money_manager_frontend/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic> user = {};
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    final data = await AuthService.getCurrentUser();
    setState(() {
      user = data;
      _usernameController.text = user['username'] ?? '';
      _emailController.text = user['email'] ?? '';
    });
  }

  void updateProfile() async {
    final success = await AuthService.updateProfile(
      username: _usernameController.text,
      email: _emailController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "Cập nhật thành công" : "Cập nhật thất bại")),
    );

    if (success) loadUser(); // reload dữ liệu sau khi update
  }

  @override
  Widget build(BuildContext context) {
    final avatar = user['avatar'] ?? 'assets/avatar.png';

    return Scaffold(
      appBar: AppBar(title: const Text("Hồ sơ cá nhân")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(radius: 50, backgroundImage: AssetImage(avatar)),
            const SizedBox(height: 20),
            TextField(controller: _usernameController, decoration: const InputDecoration(labelText: "Tên hiển thị")),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Email")),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: updateProfile, child: const Text("Cập nhật")),
          ],
        ),
      ),
    );
  }
}
