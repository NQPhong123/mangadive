import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logging/logging.dart';

class ReadingHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Logger _logger = Logger('ReadingHistoryService');

  // Lưu lịch sử đọc truyện
  Future<void> saveReadingHistory({
    required String mangaId,
    required String chapterId,
    required int pageNumber,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.info('Không thể lưu lịch sử đọc: User chưa đăng nhập');
      return;
    }

    try {
      final now = DateTime.now();
      
      // Tham chiếu đến document trong collection reading_history
      final historyRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading_history')
          .doc(mangaId);
      
      // Lấy dữ liệu hiện tại nếu có
      final docSnapshot = await historyRef.get();
      
      final Map<String, dynamic> historyData = {
        'mangaId': mangaId,
        'lastReadChapter': {
          'chapterNumber': int.parse(chapterId),
          'readAt': Timestamp.fromDate(now),
        },
        'lastReadAt': Timestamp.fromDate(now),
        'bookmark': {
          'pageNumber': pageNumber,
          'createdAt': Timestamp.fromDate(now),
        },
      };
      
      // Nếu đã có dữ liệu, cập nhật totalReadChapters và totalReadingTime
      if (docSnapshot.exists) {
        final existingData = docSnapshot.data()!;
        
        // Chỉ tăng totalReadChapters nếu đọc chapter mới
        if (existingData['lastReadChapter'] != null && 
            existingData['lastReadChapter']['chapterNumber'] != int.parse(chapterId)) {
          historyData['totalReadChapters'] = (existingData['totalReadChapters'] ?? 0) + 1;
        } else {
          // Giữ nguyên số chương đã đọc
          historyData['totalReadChapters'] = existingData['totalReadChapters'] ?? 1;
        }
        
        // Luôn tăng thời gian đọc
        historyData['totalReadingTime'] = (existingData['totalReadingTime'] ?? 0) + 1;
      } else {
        // Nếu là lần đầu đọc
        historyData['totalReadChapters'] = 1;
        historyData['totalReadingTime'] = 1;
      }
      
      // Lưu vào Firestore
      await historyRef.set(historyData, SetOptions(merge: true));
      _logger.info('Đã lưu lịch sử đọc: Manga $mangaId, Chapter $chapterId');
      
    } catch (e) {
      _logger.severe('Lỗi khi lưu lịch sử đọc: $e');
    }
  }

  // Lấy lịch sử đọc của user
  Future<List<Map<String, dynamic>>> getReadingHistory() async {
    final user = _auth.currentUser;
    if (user == null) {
      _logger.info('Không thể lấy lịch sử đọc: User chưa đăng nhập');
      return [];
    }

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('reading_history')
          .orderBy('lastReadAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      _logger.severe('Lỗi khi lấy lịch sử đọc: $e');
      return [];
    }
  }
} 