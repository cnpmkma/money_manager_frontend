import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:money_manager_frontend/routes.dart';
import 'package:money_manager_frontend/services/auth_service.dart';
import 'package:money_manager_frontend/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Money Mate",
      theme: appTheme,
      routes: AppRoutes.getRoutes(),
      home: FutureBuilder(
        future: AuthService.getLoginStatus(), 
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator(),),
            );
          }
          return snapshot.data! ? AppRoutes.getRoutes()[AppRoutes.main]!(context)
                                : AppRoutes.getRoutes()[AppRoutes.login]!(context);
        }
      ),
    );
  }
}
