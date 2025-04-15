import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';
import 'package:mangadive/routes/app_routes.dart';
import 'package:mangadive/constants/app_constants.dart';
import 'package:mangadive/controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  final logger = Logger('Main');

  try {
    // Initialize Firebase
    await Firebase.initializeApp();

    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );

    logger.info('Firebase initialized successfully');
  } catch (e) {
    logger.severe('Failed to initialize Firebase: $e');
  }

  // Disable Provider debug checks in production
  // Provider.debugCheckInvalidValueType = null;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        onGenerateRoute: AppRoutes.generateRoute,
        initialRoute: AppRoutes.initial,
      ),
    );
  }
}
