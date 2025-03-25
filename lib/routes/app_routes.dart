import 'package:flutter/material.dart';

import 'package:mangadive/view/screens/admin/admin_screen.dart';
import 'package:mangadive/view/screens/user/home_screen.dart';
import 'package:mangadive/view/screens/user/login_logout/forgot_password_screen.dart';
import 'package:mangadive/view/screens/user/login_logout/login_screen.dart.dart';
import 'package:mangadive/view/screens/user/login_logout/register_screen.dart';

// Quản lý tất cả routes tại đây
class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String forgotPassword = '/forgot-password';
  static const String admin = '/admin';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => const LoginScreen(),
    register: (context) => const RegisterScreen(),
    home: (context) => const HomeScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    admin: (context) => const AdminScreen(),
  };
}
