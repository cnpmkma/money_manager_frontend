import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formGlobalKey = GlobalKey<FormState>();

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _username = "";
  String _email = "";

  @override
  void dispose() {
    // giải phóng controller khi widget bị huỷ
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
                    // username
                    _buildTextField(
                      label: "Tên đăng nhập",
                      validator: (value) =>
                      value == null || value.isEmpty
                          ? "Tên đăng nhập không được để trống."
                          : null,
                      onSaved: (value) => _username = value!,
                    ),
                    SizedBox(height: 16),
                    // email
                    _buildTextField(
                      label: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email không được để trống.";
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return "Email không hợp lệ.";
                        }
                        return null;
                      },
                      onSaved: (value) => _email = value!,
                    ),
                    SizedBox(height: 16),
                    // password
                    _buildTextField(
                      label: "Mật khẩu",
                      obscureText: true,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Mật khẩu không được để trống.";
                        }
                        if (value.length < 6) {
                          return "Mật khẩu phải có ít nhất 6 ký tự.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // confirm password
                    _buildTextField(
                      label: "Nhập lại mật khẩu",
                      obscureText: true,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Vui lòng nhập lại mật khẩu.";
                        }
                        if (value != _passwordController.text) {
                          return "Mật khẩu không khớp.";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    FilledButton(
                      onPressed: () {
                        if (_formGlobalKey.currentState!.validate()) {
                          _formGlobalKey.currentState!.save();

                          print("Username: $_username");
                          print("Email: $_email");
                          print("Password: ${_passwordController.text}");
                          print("Confirm: ${_confirmPasswordController.text}");

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Đăng ký thành công!"),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            )
                          );
                          
                          // Quay lai login
                          Navigator.pop(context);
                        }
                      },
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
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF03F9C),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      child: Text("Đăng nhập"),
                    )
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
    void Function(String?)? onSaved,
  }) {
    return SizedBox(
      width: 300,
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          label: Text(label, style: TextStyle(color: Colors.white, fontSize: 16)),
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
        onSaved: onSaved,
      ),
    );
  }
}
