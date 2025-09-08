import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:money_manager_frontend/pages/login_page.dart';
import 'package:money_manager_frontend/pages/register_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async{
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Money MATE",
      theme: ThemeData(
        primarySwatch: Colors.pink,
        textTheme: GoogleFonts.interTextTheme(),
      ),
      // Trang đầu tiên khi chạy
      home: Login(),
      routes: {
        '/login': (context) => Login(),
        '/register': (context) => Register()
      },
    );
  }
}
