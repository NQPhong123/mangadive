import 'package:flutter/material.dart';
import 'package:mangadive/routes/app_routes.dart';
import 'package:mangadive/services/auth_service.dart';
import 'package:logging/logging.dart';
import 'package:mangadive/utils/validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mangadive/models/user.dart' as models;

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _logger = Logger('AuthController');
  models.User? _userProfile;
  bool _isLoading = false;

  // Getters
  User? get currentUser => _auth.currentUser;
  models.User? get userProfile => _userProfile;
  bool get isLoading => _isLoading;

  AuthController() {
    _init();
  }

  void _init() {
    _auth.authStateChanges().listen((User? user) {
      if (user != null) {
        _loadUserProfile();
      } else {
        _userProfile = null;
      }
      notifyListeners();
    });
  }

  Future<void> _loadUserProfile() async {
    if (currentUser != null) {
      _userProfile = await _authService.getUserById(currentUser!.uid);
      notifyListeners();
    }
  }

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

    _isLoading = true;
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
            AppRoutes.account,
            arguments: {'initialIndex': 0},
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
      _isLoading = false;
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

    _isLoading = true;
    notifyListeners();

    try {
      await _authService.resetPassword(email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email đặt lại mật khẩu đã được gửi")),
        );
        Navigator.pop(context); // Quay lại màn hình đăng nhập
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // đăng xuất tài khoản
  Future<void> signOut(BuildContext context) async {
    await _authService.signOut();
    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Đã đăng xuất thành công")));
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false, // Xóa tất cả màn hình trước đó
      );
    }
    notifyListeners();
  }

  Future<void> signIn(
      String email, String password, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signIn(email, password);
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String username,
      BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signUpUser(email, password, username);
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(models.User updatedUser) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.updateUser(updatedUser);
      _userProfile = updatedUser;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.changePassword(currentPassword, newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> reloadUserProfile() async {
    _logger.info('Reload user profile...');
    await _loadUserProfile();
  }
}
