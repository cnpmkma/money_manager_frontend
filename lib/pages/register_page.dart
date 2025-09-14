import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formGlobalKey = GlobalKey<FormState>();

  // Thêm controller cho tất cả field
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _register() async {
    if (!_formGlobalKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] ? Colors.green : Colors.red,
      ),
    );

    if (result['success']) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0A2D6), Color(0xFFFFF8FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 100),
              Image.asset("assets/money_logo.png"),
              SizedBox(height: 12),
              Text(
                "Money Mate",
                style: GoogleFonts.aclonica(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF444B3C),
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formGlobalKey,
                child: Column(
                  children: [
                    // Username
                    _buildTextField(
                      label: "Tên đăng nhập",
                      controller: _usernameController,
                      validator: (value) => value == null || value.isEmpty
                          ? "Tên đăng nhập không được để trống."
                          : null,
                    ),
                    SizedBox(height: 16),
                    // Email
                    _buildTextField(
                      label: "Email",
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Email không được để trống.";
                        final emailRegex = RegExp(
                          r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                        );
                        if (!emailRegex.hasMatch(value))
                          return "Email không hợp lệ.";
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Password
                    _buildTextField(
                      label: "Mật khẩu",
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Mật khẩu không được để trống.";
                        if (value.length < 6)
                          return "Mật khẩu phải có ít nhất 6 ký tự.";
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Confirm password
                    _buildTextField(
                      label: "Nhập lại mật khẩu",
                      obscureText: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return "Vui lòng nhập lại mật khẩu.";
                        if (value != _passwordController.text)
                          return "Mật khẩu không khớp.";
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    _isLoading
                        ? CircularProgressIndicator()
                        : FilledButton(
                            onPressed: _register,
                            style: FilledButton.styleFrom(
                              backgroundColor: Color(0xFFF03F9C),
                              foregroundColor: Colors.white,
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            child: Text("Đăng ký"),
                          ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF03F9C),
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text("Đăng nhập"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    bool obscureText = false,
    TextEditingController? controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          label: Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          filled: true,
          fillColor: Color(0xFFFF93CC),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
        style: TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white,
        validator: validator,
      ),
    );
  }
}
