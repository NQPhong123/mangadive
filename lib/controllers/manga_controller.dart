import 'package:flutter/material.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/chapter.dart';
import 'package:mangadive/models/follow.dart';
import 'package:mangadive/models/rating.dart';
import 'package:mangadive/models/reading_history.dart';
import 'package:mangadive/models/category.dart';
import 'package:mangadive/services/firebase_service.dart';
import 'package:mangadive/constants/app_constants.dart';
import 'package:logging/logging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MangaController extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final _logger = Logger('MangaController');

  List<Manga> popularMangas = [];
  List<Manga> newestMangas = [];
  List<Category> categories = [];
  Manga? currentManga;
  Chapter? currentChapter;
  bool isLoading = false;

  // Lấy truyện phổ biến
  Future<void> loadPopularMangas() async {
    try {
      isLoading = true;
      notifyListeners();

      _logger.info('Bắt đầu lấy danh sách truyện phổ biến');
      final mangas = await _firebaseService.getAllManga();
      popularMangas = mangas
        ..sort((a, b) => b.popularityScore.compareTo(a.popularityScore));
      if (popularMangas.length > 10) {
        popularMangas = popularMangas.sublist(0, 10);
      }
      _logger.info('Đã lấy ${popularMangas.length} truyện phổ biến');
    } catch (e) {
      _logger.severe('Lỗi khi lấy danh sách truyện phổ biến: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lấy truyện mới nhất
  Future<void> loadNewestMangas() async {
    try {
      isLoading = true;
      notifyListeners();

      _logger.info('Bắt đầu lấy danh sách truyện mới nhất');
      final mangas = await _firebaseService.getAllManga();
      newestMangas = mangas..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      if (newestMangas.length > 10) {
        newestMangas = newestMangas.sublist(0, 10);
      }
      _logger.info('Đã lấy ${newestMangas.length} truyện mới nhất');
    } catch (e) {
      _logger.severe('Lỗi khi lấy danh sách truyện mới nhất: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh sách thể loại
  Future<void> loadCategories() async {
    try {
      isLoading = true;
      notifyListeners();

      _logger.info('Bắt đầu lấy danh sách thể loại');
      // Tạm thời tạo các thể loại mẫu
      categories = [
        Category(
          id: '1',
          name: 'Hành động',
          description: 'Thể loại có nhiều cảnh hành động',
          mangaCount: 10,
          createdAt: DateTime.now(),
        ),
        Category(
          id: '2',
          name: 'Phiêu lưu',
          description: 'Thể loại phiêu lưu, mạo hiểm',
          mangaCount: 8,
          createdAt: DateTime.now(),
        ),
        Category(
          id: '3',
          name: 'Tình cảm',
          description: 'Thể loại tình cảm, lãng mạn',
          mangaCount: 12,
          createdAt: DateTime.now(),
        ),
      ];
      _logger.info('Đã lấy ${categories.length} thể loại');
    } catch (e) {
      _logger.severe('Lỗi khi lấy danh sách thể loại: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lấy thông tin chi tiết truyện
  Future<Manga?> getManga(String id) async {
    try {
      isLoading = true;
      notifyListeners();

      _logger.info('Bắt đầu lấy thông tin truyện với ID: $id');
      currentManga = await _firebaseService.getManga(id);

      if (currentManga != null) {
        _logger.info('Đã lấy được thông tin truyện: ${currentManga!.title}');
      } else {
        _logger.warning('Không tìm thấy truyện với ID: $id');
      }

      return currentManga;
    } catch (e) {
      _logger.severe('Lỗi khi lấy thông tin truyện: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lấy danh sách chapter của truyện
  Future<List<Chapter>> getChapters(String mangaId) async {
    try {
      isLoading = true;
      notifyListeners();

      _logger.info('Bắt đầu lấy danh sách chapter của truyện: $mangaId');
      final chapters = await _firebaseService.getMangaChapters(mangaId);
      chapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

      _logger.info('Đã lấy được ${chapters.length} chapter');

      return chapters;
    } catch (e) {
      _logger.severe('Lỗi khi lấy danh sách chapter: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lấy thông tin chi tiết chapter
  Future<Chapter?> getChapter(String mangaId, int chapterNumber) async {
    try {
      isLoading = true;
      notifyListeners();

      _logger.info(
          'Bắt đầu lấy thông tin chapter $chapterNumber của truyện $mangaId');
      // Chuyển chapterNumber sang String vì API getMangaChapter nhận chapterId dạng String
      final chapterId = chapterNumber.toString();
      currentChapter =
          await _firebaseService.getMangaChapter(mangaId, chapterId);

      if (currentChapter != null) {
        _logger.info(
            'Đã lấy được thông tin chapter: ${currentChapter!.chapterNumber}');
      } else {
        _logger.warning('Không tìm thấy chapter $chapterNumber');
      }

      return currentChapter;
    } catch (e) {
      _logger.severe('Lỗi khi lấy thông tin chapter: $e');
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Theo dõi truyện
  Future<void> followManga(String userId, String mangaId) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final followsRef = userRef.collection('follows').doc(mangaId);

      final follow = Follow(
        mangaId: mangaId,
        lastReadChapter:
            ChapterProgress(chapterNumber: 0, readAt: DateTime.now()),
        totalReadChapters: 0,
        totalReadingTime: 0,
        lastReadAt: DateTime.now(),
        createdAt: DateTime.now(),
      );

      await followsRef.set(follow.toMap());

      // Update manga's total followers
      await FirebaseFirestore.instance
          .collection('mangas')
          .doc(mangaId)
          .update({
        'totalFollowers': FieldValue.increment(1),
      });
    } catch (e) {
      print('Error following manga: $e');
      rethrow;
    }
  }

  // Hủy theo dõi truyện
  Future<void> unfollowManga(String userId, String mangaId) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final followsRef = userRef.collection('follows').doc(mangaId);

      await followsRef.delete();

      // Update manga's total followers
      await FirebaseFirestore.instance
          .collection('mangas')
          .doc(mangaId)
          .update({
        'totalFollowers': FieldValue.increment(-1),
      });
    } catch (e) {
      print('Error unfollowing manga: $e');
      rethrow;
    }
  }

  Future<bool> isFollowingManga(String userId, String mangaId) async {
    try {
      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final followsRef = userRef.collection('follows').doc(mangaId);

      final doc = await followsRef.get();
      return doc.exists;
    } catch (e) {
      print('Error checking follow status: $e');
      rethrow;
    }
  }

  Future<List<Follow>> getUserFollows(String userId) async {
    try {
      _logger.info('Bắt đầu lấy danh sách follows cho user: $userId');

      final userRef =
          FirebaseFirestore.instance.collection('users').doc(userId);
      final followsRef = userRef.collection('follows');

      final querySnapshot = await followsRef.get();
      _logger.info('Số lượng follows: ${querySnapshot.docs.length}');

      final follows = querySnapshot.docs.map((doc) {
        try {
          return Follow.fromFirestore(doc);
        } catch (e) {
          _logger.severe('Lỗi khi chuyển đổi follow: $e');
          _logger.severe('Dữ liệu gốc: ${doc.data()}');
          rethrow;
        }
      }).toList();

      _logger.info('Đã lấy được ${follows.length} follows');
      return follows;
    } catch (e) {
      _logger.severe('Lỗi khi lấy danh sách follows: $e');
      rethrow;
    }
  }

  // Đánh giá truyện - Hiện chưa có phương thức tương ứng trong FirebaseService
  Future<void> rateManga(String userId, String mangaId, int rating,
      {String? review}) async {
    try {
      _logger.info('Bắt đầu đánh giá truyện: $mangaId với điểm $rating');
      // Tạm thời không có phương thức rateManga trong FirebaseService
      _logger.info('Đã đánh giá truyện thành công');

      // Cập nhật lại thông tin truyện hiện tại
      if (currentManga != null && currentManga!.id == mangaId) {
        await getManga(mangaId);
      }
    } catch (e) {
      _logger.severe('Lỗi khi đánh giá truyện: $e');
      rethrow;
    }
  }

  // Cập nhật lịch sử đọc
  Future<void> updateReadingHistory(
    String userId,
    String mangaId,
    int chapterNumber,
    int pageNumber,
    int readingTime,
  ) async {
    try {
      _logger.info(
          'Bắt đầu cập nhật lịch sử đọc truyện: $mangaId, chapter: $chapterNumber');
      await _firebaseService.updateReadingHistory(
          mangaId, chapterNumber.toString());
      _logger.info('Đã cập nhật lịch sử đọc thành công');
    } catch (e) {
      _logger.severe('Lỗi khi cập nhật lịch sử đọc: $e');
      rethrow;
    }
  }

  // Tìm kiếm truyện
  Future<List<Manga>> searchMangas(String query) async {
    try {
      isLoading = true;
      notifyListeners();

      _logger.info('Bắt đầu tìm kiếm truyện với từ khóa: $query');
      // Hiện chưa có phương thức tìm kiếm, tạm thời lấy tất cả và lọc
      final allMangas = await _firebaseService.getAllManga();
      final results = allMangas
          .where((manga) =>
              manga.title.toLowerCase().contains(query.toLowerCase()) ||
              manga.description.toLowerCase().contains(query.toLowerCase()))
          .toList();

      _logger.info('Đã tìm thấy ${results.length} kết quả');

      return results;
    } catch (e) {
      _logger.severe('Lỗi khi tìm kiếm truyện: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Lấy truyện theo thể loại
  Future<List<Manga>> getMangasByCategory(String categoryId) async {
    try {
      isLoading = true;
      notifyListeners();

      _logger.info('Bắt đầu lấy danh sách truyện theo thể loại: $categoryId');
      // Hiện chưa có phương thức lấy theo thể loại, tạm thời lấy tất cả và lọc
      final allMangas = await _firebaseService.getAllManga();
      final results = allMangas
          .where((manga) => manga.genres.contains(categoryId))
          .toList();

      _logger.info('Đã tìm thấy ${results.length} truyện');

      return results;
    } catch (e) {
      _logger.severe('Lỗi khi lấy truyện theo thể loại: $e');
      return [];
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
