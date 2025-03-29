import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/chapter.dart';
import 'package:mangadive/services/firebase_service.dart';
import 'package:mangadive/constants/app_constants.dart';
import 'package:logging/logging.dart';

class MangaController {
  final FirebaseService _firebaseService = FirebaseService();
  final _logger = Logger('MangaController');

  Future<List<Manga>> getAllMangas() async {
    try {
      _logger.info('Bắt đầu lấy danh sách manga');
      final mangas = await _firebaseService.getCollectionMangas();
      _logger.info('Đã lấy được ${mangas.length} manga');
      return mangas;
    } catch (e, stackTrace) {
      _logger.severe('Lỗi khi lấy danh sách manga: $e');
      _logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Manga?> getManga(String id) async {
    try {
      _logger.info('Bắt đầu lấy thông tin manga với ID: $id');
      final manga = await _firebaseService.getManga(id);
      if (manga != null) {
        _logger.info('Đã lấy được thông tin manga: ${manga.name}');
      } else {
        _logger.warning('Không tìm thấy manga với ID: $id');
      }
      return manga;
    } catch (e, stackTrace) {
      _logger.severe('Lỗi khi lấy thông tin manga: $e');
      _logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Chapter?> getChapter(String mangaId, String chapterId) async {
    try {
      _logger
          .info('Bắt đầu lấy thông tin chapter $chapterId của manga $mangaId');
      final chapter =
          await _firebaseService.getMangaChapter(mangaId, chapterId);
      if (chapter != null) {
        _logger.info('Đã lấy được thông tin chapter: ${chapter.chapterNumber}');
      } else {
        _logger.warning('Không tìm thấy chapter với ID: $chapterId');
      }
      return chapter;
    } catch (e, stackTrace) {
      _logger.severe('Lỗi khi lấy thông tin chapter: $e');
      _logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<Chapter>> getMangaChapters(String mangaId) async {
    try {
      _logger.info('Bắt đầu lấy danh sách chapters của manga: $mangaId');
      final chapters = await _firebaseService.getMangaChapters(mangaId);
      _logger.info('Đã lấy được ${chapters.length} chapters');
      return chapters;
    } catch (e, stackTrace) {
      _logger.severe('Lỗi khi lấy danh sách chapters: $e');
      _logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> incrementMangaView(String mangaId) async {
    try {
      _logger.info('Bắt đầu tăng lượt xem cho manga: $mangaId');
      await _firebaseService.updateManga(mangaId, {
        'views': FieldValue.increment(1),
      });
      _logger.info('Đã tăng lượt xem thành công');
    } catch (e, stackTrace) {
      _logger.severe('Lỗi khi tăng lượt xem manga: $e');
      _logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> incrementChapterView(String mangaId, String chapterId) async {
    try {
      _logger.info('Bắt đầu tăng lượt xem cho chapter: $chapterId');
      await _firebaseService.updateDocument(
        '${AppConstants.mangasCollection}/$mangaId/${AppConstants.chaptersCollection}',
        chapterId,
        {'views': FieldValue.increment(1)},
      );
      _logger.info('Đã tăng lượt xem thành công');
    } catch (e, stackTrace) {
      _logger.severe('Lỗi khi tăng lượt xem chapter: $e');
      _logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> toggleMangaLike(String mangaId, String userId) async {
    try {
      _logger.info('Bắt đầu toggle like cho manga: $mangaId');
      final manga = await getManga(mangaId);
      if (manga != null) {
        final likes = manga.follows;
        await _firebaseService.updateManga(mangaId, {
          'follows': likes + 1,
        });
        _logger.info('Đã toggle like thành công');
      }
    } catch (e, stackTrace) {
      _logger.severe('Lỗi khi toggle like manga: $e');
      _logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> toggleChapterLike(
      String mangaId, String chapterId, String userId) async {
    try {
      _logger.info('Bắt đầu toggle like cho chapter: $chapterId');
      final chapter = await getChapter(mangaId, chapterId);
      if (chapter != null) {
        final likes = chapter.likes;
        await _firebaseService.updateDocument(
          '${AppConstants.mangasCollection}/$mangaId/${AppConstants.chaptersCollection}',
          chapterId,
          {'likes': likes + 1},
        );
        _logger.info('Đã toggle like thành công');
      }
    } catch (e, stackTrace) {
      _logger.severe('Lỗi khi toggle like chapter: $e');
      _logger.severe('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
