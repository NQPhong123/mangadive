import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/controllers/notification_controller.dart';
import 'package:mangadive/models/notification.dart';

class NotificationTestScreen extends StatelessWidget {
  const NotificationTestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Thông báo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildTestButton(
            context,
            'Test Thông báo Chapter Mới',
            'Tạo thông báo khi có chapter mới của truyện One Piece',
            () => _testNewChapterNotification(context),
          ),
          const SizedBox(height: 16),
          _buildTestButton(
            context,
            'Test Thông báo Cập nhật',
            'Tạo thông báo khi truyện đang theo dõi có cập nhật',
            () => _testFollowUpdateNotification(context),
          ),
          const SizedBox(height: 16),
          _buildTestButton(
            context,
            'Test Thông báo Hệ thống',
            'Tạo thông báo hệ thống',
            () => _testSystemNotification(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(
    BuildContext context,
    String title,
    String subtitle,
    VoidCallback onPressed,
  ) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.notifications),
        onTap: onPressed,
      ),
    );
  }

  Future<void> _testNewChapterNotification(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để test')),
        );
        return;
      }

      final controller = NotificationController();
      await controller.createNewChapterNotification(
        user.uid,
        'one-piece',
        'One Piece',
        1085,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo thông báo chapter mới')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _testFollowUpdateNotification(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để test')),
        );
        return;
      }

      final controller = NotificationController();
      await controller.createFollowUpdateNotification(
        user.uid,
        'one-piece',
        'One Piece',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo thông báo cập nhật')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  Future<void> _testSystemNotification(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để test')),
        );
        return;
      }

      final controller = NotificationController();
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final notificationsRef = userRef.collection('notifications');
      
      await notificationsRef.add({
        'userId': user.uid,
        'type': 'system',
        'data': {
          'message': 'Hệ thống đã được cập nhật phiên bản mới!',
        },
        'read': false,
        'createdAt': DateTime.now(),
        'expiresAt': DateTime.now().add(const Duration(days: 30)),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã tạo thông báo hệ thống')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }
} 