import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mangadive/services/auth_service.dart';

class SocialLogin extends StatelessWidget {
  SocialLogin({super.key});
  final AuthService authService = AuthService();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () async {
            final user = await authService.signInWithGoogle();
            if (user != null) {
              print("Đăng nhập thành công: ${user.displayName}");
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              showErrorMessage(context, "Đăng nhập Google thất bại!");
            }
          },
          child: SvgPicture.asset('assets/icons/icons8-google.svg', height: 24),
        ),
        ElevatedButton(
          onPressed: () async {
            User? user = await authService.signInWithFacebook();
            if (user != null) {
              print("Đăng nhập Facebook thành công: ${user.displayName}");
              Navigator.pushReplacementNamed(context, '/home');
            } else {
              showErrorMessage(context, "Đăng nhập Facebook thất bại!");
            }
          },
          child: SvgPicture.asset(
            'assets/icons/icons8-facebook-logo.svg',
            height: 24,
          ),
        ),
      ],
    );
  }

  void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
