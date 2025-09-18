import 'package:flutter/material.dart';
import 'package:money_manager_frontend/pages/login_page.dart';
import 'package:money_manager_frontend/pages/register_page.dart';
import 'package:money_manager_frontend/pages/main_layout.dart';

class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const main = '/main';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      login: (context) => Login(),
      register: (context) => Register(),
      main: (context) => MainLayout(),
    };
  }
}
