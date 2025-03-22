import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:mangadive/view/screens/home_sceen.dart';
import 'package:mangadive/view/screens/login_screen.dart.dart';
import 'package:mangadive/view/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    print("✅ Firebase đã khởi tạo thành công!");
  } catch (e) {
    print("❌ Lỗi khi khởi tạo Firebase:::: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
      routes: {
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => HomeScreen(),
      },
    );
  }
}
