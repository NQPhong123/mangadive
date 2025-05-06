import 'package:flutter/material.dart';

import 'package:mangadive/view/screens/user/login_screen.dart';

import 'package:mangadive/view/screens/user/forgot_password_screen.dart';
import 'package:mangadive/view/screens/user/account_screen.dart';
import 'package:mangadive/view/screens/user/register_screen.dart';
import 'package:mangadive/view/screens/main_screen.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';
import 'package:mangadive/view/screens/manga/manga_read_screen.dart';

import 'package:mangadive/view/screens/community/community_screen.dart';
import 'package:mangadive/view/screens/post/post_detail_screen.dart';
import 'package:mangadive/view/screens/post/create_post_screen.dart';
import 'package:mangadive/view/screens/library/library_screen.dart';


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
  static const String bookmark = '/bookmark';
  static const String account = '/account';
  static const String library = '/library';
  static const String notification = '/notification';
  static const String community = '/community';
  static const String postDetail = '/post/detail';
  static const String createPost = '/post/create';


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
            currentUserId: args['currentUserId'],
          ),
          fullscreenDialog: true,
        );

      case mainScreen:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
        );

      // case bookmark:
      //   return MaterialPageRoute(builder: (_) => const BookmarkScreen());
      case account:
        return MaterialPageRoute(builder: (_) => AccountScreen());

      case community:
        if (args == null || args['currentUserId'] == null) {
          return _errorRoute('Thiếu thông tin người dùng');
        }
        return MaterialPageRoute(
          builder: (_) => CommunityScreen(
            currentUserId: args['currentUserId'] as String,
          ),
        );

      case postDetail:
        if (args == null || args['postId'] == null || args['currentUserId'] == null) {
          return _errorRoute('Thiếu thông tin bài viết');
        }
        return MaterialPageRoute(
          builder: (_) => PostDetailScreen(
            postId: args['postId'] as String,
            currentUserId: args['currentUserId'] as String,
          ),
        );

      case createPost:
        if (args == null || args['currentUserId'] == null) {
          return _errorRoute('Thiếu thông tin người dùng');
        }
        return MaterialPageRoute(
          builder: (_) => CreatePostScreen(
            currentUserId: args['currentUserId'] as String,
          ),
        );

      case library:
        return MaterialPageRoute(builder: (_) => const LibraryScreen());

      // case profile:
      //   if (args == null || args['userId'] == null) {
      //     return _errorRoute('Thiếu thông tin người dùng');
      //   }
      //   return MaterialPageRoute(
      //     builder: (_) => ProfileScreen(
      //       userId: args['userId'] as String,
      //     ),
      //   );

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
