import 'package:flutter/material.dart';

import 'package:mangadive/view/screens/user/login_screen.dart';
import 'package:mangadive/view/screens/home/home_screen.dart';
import 'package:mangadive/view/screens/user/forgot_password_screen.dart';
import 'package:mangadive/view/screens/user/account_screen.dart';
import 'package:mangadive/view/screens/user/register_screen.dart';
import 'package:mangadive/view/screens/main_screen.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';
import 'package:mangadive/view/screens/manga/manga_read_screen.dart';
import 'package:mangadive/view/screens/discover/discover_screen.dart';
import 'package:mangadive/view/screens/user/notification_screen.dart';

// Quản lý tất cả routes tại đây
class AppRoutes {
  // Main routes
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String mangaDetail = '/manga/detail';
  static const String mangaRead = '/manga/read';
  static const String mainScreen = '/main-screen';
  static const String discover = '/discover';
  static const String bookmark = '/bookmark';
  static const String account = '/account';
  static const String library = '/library';
  static const String notification = '/notification';


  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case initial:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );

      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          fullscreenDialog: true,
        );

      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
          fullscreenDialog: true,
        );

      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
          fullscreenDialog: true,
        );

      case mangaDetail:
        if (args == null || args['mangaId'] == null) {
          return _errorRoute('Thiếu thông tin manga');
        }
        return MaterialPageRoute(
          builder: (_) => MangaDetailScreen(mangaId: args['mangaId']),
          fullscreenDialog: true,
        );

      case mangaRead:
        if (args == null || args['mangaId'] == null || args['chapterId'] == null) {
          return _errorRoute('Thiếu thông tin chapter');
        }
        return MaterialPageRoute(
          builder: (_) => MangaReadScreen(
            mangaId: args['mangaId'],
            chapterId: args['chapterId'],
          ),
          fullscreenDialog: true,
        );

      case mainScreen:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );

      case discover:
        return MaterialPageRoute(builder: (_) => const DiscoverScreen());
      // case bookmark:
      //   return MaterialPageRoute(builder: (_) => const BookmarkScreen());
      case account:
        return MaterialPageRoute(builder: (_) => AccountScreen());

      default:
        return _errorRoute('Không tìm thấy trang ${settings.name}');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
