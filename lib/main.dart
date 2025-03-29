import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mangadive/routes/app_routes.dart';
import 'package:mangadive/constants/app_constants.dart';

import 'package:mangadive/view/screens/user/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:mangadive/controllers/auth_controller.dart'; // Import AuthController
import 'package:mangadive/view/screens/admin/admin_screen.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
