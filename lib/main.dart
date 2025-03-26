import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mangadive/routes/app_routes.dart';

import 'package:mangadive/view/screens/user/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:mangadive/controllers/auth_controller.dart'; // Import AuthController
import 'package:mangadive/view/screens/admin/admin_screen.dart';
import 'package:mangadive/view/screens/admin/add_manga_screen.dart';
import 'package:mangadive/view/screens/admin/edit_manga_screen.dart';
import 'package:mangadive/view/screens/admin/manage_users_screen.dart';
import 'package:mangadive/utils/admin_guard.dart';
import 'package:mangadive/models/manga.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  final _logger = Logger('main');

  try {
    await Firebase.initializeApp();
    _logger.info("✅ Firebase đã khởi tạo thành công!");
  } catch (e) {
    _logger.severe("❌ Lỗi khi khởi tạo Firebase:::: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthController(),
        ), // Cung cấp AuthController
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainScreen(),

      routes: AppRoutes.routes,
      onGenerateRoute: (settings) {
        final routeName = settings.name;
        if (routeName == null) return null;

        // Kiểm tra quyền admin trước khi cho phép truy cập các route admin
        if (routeName == '/admin' || routeName.startsWith('/admin/')) {
          return MaterialPageRoute(
            builder:
                (context) => FutureBuilder<bool>(
                  future: AdminGuard.canActivate(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (snapshot.data == true) {
                      switch (routeName) {
                        case '/admin':
                          return const AdminScreen();
                        case '/admin/add-manga':
                          return const AddMangaScreen();
                        case '/admin/edit-manga':
                          return EditMangaScreen(
                            manga: settings.arguments as Manga,
                          );
                        case '/admin/manage-users':
                          return const ManageUsersScreen();
                        default:
                          return const AdminScreen();
                      }
                    }
                    return const MainScreen();
                  },
                ),
          );
        }
        return null;
      },
    );
  }
}
