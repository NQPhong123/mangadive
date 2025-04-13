import 'package:flutter/material.dart';

import 'package:mangadive/view/screens/user/screens/login_screen.dart';
import 'package:mangadive/view/screens/home/home_screen.dart';
import 'package:mangadive/view/screens/user/screens/forgot_password_screen.dart';
import 'package:mangadive/view/screens/user/screens/account_screen.dart';
import 'package:mangadive/view/screens/user/screens/register_screen.dart';
import 'package:mangadive/view/screens/user/main_screen.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';
import 'package:mangadive/view/screens/manga/manga_read_screen.dart';
import 'package:mangadive/view/screens/discover/discover_screen.dart';

// Quản lý tất cả routes tại đây
class AppRoutes {
  static const String home = '/';
  static const String mangaDetail = '/manga/detail';
  static const String mangaRead = '/manga/read';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String mainScreen = '/main-screen';
  static const String discover = '/discover';
  static const String bookmark = '/bookmark';
  static const String account = '/account';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case mangaDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MangaDetailScreen(mangaId: args['mangaId']),
        );

      case mangaRead:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => MangaReadScreen(
            mangaId: args['mangaId'],
            chapterId: args['chapterId'],
          ),
        );

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case AppRoutes.mainScreen:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(initialIndex: 0), // tab Home
        );

      case discover:
        return MaterialPageRoute(builder: (_) => const DiscoverScreen());
      // case bookmark:
      //   return MaterialPageRoute(builder: (_) => const BookmarkScreen());
      case account:
        return MaterialPageRoute(builder: (_) => AccountScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy trang ${settings.name}'),
            ),
          ),
        );
    }
  }
}
