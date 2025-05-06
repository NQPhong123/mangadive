import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
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

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final logger = Logger('MyApp');

  @override
  void initState() {
    super.initState();
    _initDynamicLinks();
  }

  void _initDynamicLinks() async {
    // Bắt link khi app KHỞI ĐỘNG từ dynamic link
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    if (initialLink != null) {
      _handleDynamicLink(initialLink);
    }

    // Bắt link khi app đang MỞ (foreground)
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
      _handleDynamicLink(dynamicLinkData);
    }).onError((error) {
      logger.severe('Dynamic link error: $error');
    });
  }

  void _handleDynamicLink(PendingDynamicLinkData linkData) {
    final Uri deepLink = linkData.link;
    logger.info('Received dynamic link: $deepLink');

    // Ví dụ: nếu link là https://mangadive.page.link/mangacoin?uid=123
    final String? uid = deepLink.queryParameters['uid'];
    final String? action =
        deepLink.pathSegments.isNotEmpty ? deepLink.pathSegments[0] : null;

    if (action == 'mangacoin' && uid != null) {
      // Xử lý điều hướng tới màn hình nạp coin hoặc hiển thị thông báo
      Navigator.pushNamed(context, '/topup', arguments: {'uid': uid});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
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
