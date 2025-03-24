import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class AdminGuard {
  static final _logger = Logger('AdminGuard');

  static Future<bool> canActivate(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _logger.warning('Không có user đang đăng nhập');
        return false;
      }

      final userDoc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      if (!userDoc.exists) {
        _logger.warning('User document không tồn tại: ${user.uid}');
        return false;
      }

      final userData = userDoc.data();
      if (userData == null) {
        _logger.warning('User data rỗng: ${user.uid}');
        return false;
      }

      final roles = List<String>.from(userData['roles'] ?? []);
      final isAdmin = roles.contains('admin');

      _logger.info(
        'User ${user.email} ${isAdmin ? 'có' : 'không có'} quyền admin',
      );
      return isAdmin;
    } catch (e) {
      _logger.severe('Lỗi khi kiểm tra quyền admin: $e');
      return false;
    }
  }
}
