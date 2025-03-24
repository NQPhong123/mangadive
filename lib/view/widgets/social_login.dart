import 'package:flutter/material.dart';
import 'package:mangadive/services/auth_service.dart';
import 'package:logging/logging.dart';

class SocialLogin extends StatelessWidget {
  const SocialLogin({super.key});

  static final _logger = Logger('SocialLogin');

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      final user = await AuthService().signInWithGoogle();

      if (!context.mounted) return;

      _logger.info(
        'Đăng nhập Google thành công: ${user?.email ?? 'Không có email'}',
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!context.mounted) return;
      _logger.severe('Lỗi đăng nhập Google: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi đăng nhập Google: $e')));
    }
  }

  Future<void> _handleFacebookSignIn(BuildContext context) async {
    try {
      final user = await AuthService().signInWithFacebook();

      if (!context.mounted) return;

      _logger.info(
        'Đăng nhập Facebook thành công: ${user?.email ?? 'Không có email'}',
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!context.mounted) return;
      _logger.severe('Lỗi đăng nhập Facebook: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi đăng nhập Facebook: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          onPressed: () => _handleGoogleSignIn(context),
          icon: const Icon(Icons.g_mobiledata),
          label: const Text('Google'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        ElevatedButton.icon(
          onPressed: () => _handleFacebookSignIn(context),
          icon: const Icon(Icons.facebook),
          label: const Text('Facebook'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
