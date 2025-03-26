import 'package:flutter/material.dart';
import 'package:mangadive/routes/app_routes.dart';
import 'package:mangadive/services/auth_service.dart';
import 'package:logging/logging.dart';
import 'package:mangadive/utils/validators.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final _logger = Logger('AuthController');
  bool isLoading = false;

  // xử lý đăng nhập
  Future<void> login(
    BuildContext context,
    String email,
    String password,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đầy đủ')));
      return;
    }

    isLoading = true;
    notifyListeners(); // Cập nhật UI

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        _logger.info('Đăng nhập thành công: ${user.email}');
        if (context.mounted) {
          Navigator.pushReplacementNamed(
            context,
            user.isAdmin ? '/admin' : '/main-screen',
          );
        }
      } else {
        _logger.warning('Email hoặc mật khẩu không đúng');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email hoặc mật khẩu không đúng')),
          );
        }
      }
    } catch (e) {
      _logger.severe('Lỗi đăng nhập: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // xử lý reset Password
  Future<void> sendPasswordResetEmail(
    BuildContext context,
    String email,
  ) async {
    String? message = await Validators.validateEmail(email);
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email đặt lại mật khẩu đã được gửi")),
      );
      Navigator.pop(context); // Quay lại màn hình đăng nhập
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    }

    isLoading = false;
    notifyListeners();
  }

  // đăng xuất tài khoản
  Future<void> sigOut(BuildContext context) async {
    await AuthService().signOut();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Đã đăng xuất thành công")));
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false, // Xóa tất cả màn hình trước đó
    );
    notifyListeners();
  }
}
