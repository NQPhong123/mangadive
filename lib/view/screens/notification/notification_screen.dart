import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mangadive/controllers/notification_controller.dart';
import 'package:mangadive/models/notification.dart';
import 'package:intl/intl.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationController _notificationController = NotificationController();
  List<UserNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      setState(() => _isLoading = true);
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
        return;
      }

      final notifications = await _notificationController.getUserNotifications(user.uid);
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi load thông báo: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              // TODO: Xóa tất cả thông báo
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text('Không có thông báo nào'),
                )
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationItem(UserNotification notification) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final isNew = !notification.read;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      onDismissed: (direction) {
        // TODO: Xóa thông báo
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        color: isNew ? Colors.blue.shade50 : null,
        child: ListTile(
          leading: _getNotificationIcon(notification.type),
          title: _getNotificationTitle(notification),
          subtitle: Text(
            dateFormat.format(notification.createdAt),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
          trailing: isNew
              ? const Icon(
                  Icons.circle,
                  color: Colors.blue,
                  size: 12,
                )
              : null,
          onTap: () {
            _handleNotificationTap(notification);
          },
        ),
      ),
    );
  }

  Widget _getNotificationIcon(String type) {
    switch (type) {
      case 'new_chapter':
        return const Icon(Icons.menu_book, color: Colors.blue);
      case 'follow_update':
        return const Icon(Icons.favorite, color: Colors.red);
      case 'system':
        return const Icon(Icons.info, color: Colors.orange);
      default:
        return const Icon(Icons.notifications, color: Colors.grey);
    }
  }

  Widget _getNotificationTitle(UserNotification notification) {
    switch (notification.type) {
      case 'new_chapter':
        return Text(
          'Chapter ${notification.data['chapterNumber']} của ${notification.data['title']} đã được cập nhật',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case 'follow_update':
        return Text(
          '${notification.data['title']} đã có cập nhật mới',
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      case 'system':
        return Text(
          notification.data['message'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        );
      default:
        return const Text('Thông báo mới');
    }
  }

  Future<void> _handleNotificationTap(UserNotification notification) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Đánh dấu thông báo đã đọc
      await _notificationController.markNotificationAsRead(user.uid, notification.id);

      // Cập nhật UI
      setState(() {
        final index = _notifications.indexOf(notification);
        if (index != -1) {
          _notifications[index] = notification.markAsRead();
        }
      });

      // Xử lý navigation dựa vào loại thông báo
      switch (notification.type) {
        case 'new_chapter':
        case 'follow_update':
          // TODO: Navigate to manga detail
          break;
        case 'system':
          // TODO: Show system message
          break;
      }
    } catch (e) {
      print('Lỗi khi xử lý thông báo: $e');
    }
  }
} 