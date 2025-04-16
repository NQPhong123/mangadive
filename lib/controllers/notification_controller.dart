import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/notification.dart';
import 'package:logging/logging.dart';

class NotificationController {
  final _logger = Logger('NotificationController');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy danh sách thông báo của user
  Future<List<UserNotification>> getUserNotifications(String userId) async {
    try {
      _logger.info('Bắt đầu lấy thông báo cho user: $userId');
      
      final userRef = _firestore.collection('users').doc(userId);
      final notificationsRef = userRef.collection('notifications');
      
      final querySnapshot = await notificationsRef
          .where('expiresAt', isGreaterThan: Timestamp.now())
          .orderBy('expiresAt', descending: true)
          .get();
      
      _logger.info('Số lượng thông báo: ${querySnapshot.docs.length}');
      
      final notifications = querySnapshot.docs.map((doc) {
        try {
          return UserNotification.fromFirestore(doc);
        } catch (e) {
          _logger.severe('Lỗi khi chuyển đổi thông báo: $e');
          _logger.severe('Dữ liệu gốc: ${doc.data()}');
          rethrow;
        }
      }).toList();
      
      _logger.info('Đã lấy được ${notifications.length} thông báo');
      return notifications;
    } catch (e) {
      _logger.severe('Lỗi khi lấy thông báo: $e');
      rethrow;
    }
  }

  // Tạo thông báo chapter mới
  Future<void> createNewChapterNotification(
    String userId,
    String mangaId,
    String title,
    int chapterNumber,
  ) async {
    try {
      _logger.info('Tạo thông báo chapter mới cho user: $userId');
      
      final userRef = _firestore.collection('users').doc(userId);
      final notificationsRef = userRef.collection('notifications');
      
      final notification = UserNotification.newChapter(
        userId: userId,
        mangaId: mangaId,
        title: title,
        chapterNumber: chapterNumber,
      );
      
      await notificationsRef.add(notification.toMap());
      _logger.info('Đã tạo thông báo chapter mới thành công');
    } catch (e) {
      _logger.severe('Lỗi khi tạo thông báo chapter mới: $e');
      rethrow;
    }
  }

  // Tạo thông báo cập nhật từ truyện đang theo dõi
  Future<void> createFollowUpdateNotification(
    String userId,
    String mangaId,
    String title,
  ) async {
    try {
      _logger.info('Tạo thông báo cập nhật cho user: $userId');
      
      final userRef = _firestore.collection('users').doc(userId);
      final notificationsRef = userRef.collection('notifications');
      
      final notification = UserNotification.followUpdate(
        userId: userId,
        mangaId: mangaId,
        title: title,
      );
      
      await notificationsRef.add(notification.toMap());
      _logger.info('Đã tạo thông báo cập nhật thành công');
    } catch (e) {
      _logger.severe('Lỗi khi tạo thông báo cập nhật: $e');
      rethrow;
    }
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markNotificationAsRead(String userId, String notificationId) async {
    try {
      _logger.info('Đánh dấu thông báo đã đọc: $notificationId');
      
      final userRef = _firestore.collection('users').doc(userId);
      final notificationRef = userRef.collection('notifications').doc(notificationId);
      
      await notificationRef.update({'read': true});
      _logger.info('Đã đánh dấu thông báo đã đọc thành công');
    } catch (e) {
      _logger.severe('Lỗi khi đánh dấu thông báo đã đọc: $e');
      rethrow;
    }
  }

  // Xóa thông báo đã hết hạn
  Future<void> deleteExpiredNotifications(String userId) async {
    try {
      _logger.info('Xóa thông báo hết hạn cho user: $userId');
      
      final userRef = _firestore.collection('users').doc(userId);
      final notificationsRef = userRef.collection('notifications');
      
      final querySnapshot = await notificationsRef
          .where('expiresAt', isLessThan: Timestamp.now())
          .get();
      
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _logger.info('Đã xóa ${querySnapshot.docs.length} thông báo hết hạn');
    } catch (e) {
      _logger.severe('Lỗi khi xóa thông báo hết hạn: $e');
      rethrow;
    }
  }

  // Xóa một thông báo
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      _logger.info('Xóa thông báo: $notificationId');
      
      final userRef = _firestore.collection('users').doc(userId);
      final notificationRef = userRef.collection('notifications').doc(notificationId);
      
      await notificationRef.delete();
      _logger.info('Đã xóa thông báo thành công');
    } catch (e) {
      _logger.severe('Lỗi khi xóa thông báo: $e');
      rethrow;
    }
  }

  // Xóa tất cả thông báo
  Future<void> deleteAllNotifications(String userId) async {
    try {
      _logger.info('Xóa tất cả thông báo cho user: $userId');
      
      final userRef = _firestore.collection('users').doc(userId);
      final notificationsRef = userRef.collection('notifications');
      
      final querySnapshot = await notificationsRef.get();
      
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      _logger.info('Đã xóa ${querySnapshot.docs.length} thông báo');
    } catch (e) {
      _logger.severe('Lỗi khi xóa tất cả thông báo: $e');
      rethrow;
    }
  }
} 