import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/user.dart';

class UserController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache để tối ưu hiệu suất
  final Map<String, User> _userCache = {};

  Future<User> getUserById(String userId) async {
    // Kiểm tra cache trước
    if (_userCache.containsKey(userId)) {
      return _userCache[userId]!;
    }

    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      
      if (docSnapshot.exists) {
        final user = User.fromFirestore(docSnapshot);
        // Lưu vào cache
        _userCache[userId] = user;
        return user;
      }
      
      // Nếu không tìm thấy user, tạo một đối tượng User mặc định
      final unknownUser = User(
        id: userId,
        email: '',
        username: 'Người dùng',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        settings: UserSettings(
          theme: 'light',
          language: 'vi',
          notification: NotificationSettings(newChapter: true, system: true),
          reading: ReadingSettings(defaultQuality: 'high', defaultDirection: 'vertical'),
        ),
      );
      _userCache[userId] = unknownUser;
      return unknownUser;
    } catch (e) {
      print('Lỗi khi lấy thông tin user: $e');
      // Trả về user mặc định
      final unknownUser = User(
        id: userId,
        email: '',
        username: 'Người dùng',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        settings: UserSettings(
          theme: 'light',
          language: 'vi',
          notification: NotificationSettings(newChapter: true, system: true),
          reading: ReadingSettings(defaultQuality: 'high', defaultDirection: 'vertical'),
        ),
      );
      _userCache[userId] = unknownUser;
      return unknownUser;
    }
  }
  
  // Lấy thông tin user theo stream để cập nhật tự động
  Stream<User> getUserStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final user = User.fromFirestore(snapshot);
        _userCache[userId] = user; // Cập nhật cache
        return user;
      }
      // Trả về user mặc định
      return User(
        id: userId,
        email: '',
        username: 'Người dùng',
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
        settings: UserSettings(
          theme: 'light',
          language: 'vi',
          notification: NotificationSettings(newChapter: true, system: true),
          reading: ReadingSettings(defaultQuality: 'high', defaultDirection: 'vertical'),
        ),
      );
    });
  }
} 