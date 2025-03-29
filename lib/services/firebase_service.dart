import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/chapter.dart';
import 'package:mangadive/constants/app_constants.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Manga Collection
  Future<Manga?> getManga(String id) async {
    try {
      print('Đang lấy thông tin manga với ID: $id');
      final doc = await _firestore
          .collection(AppConstants.mangasCollection)
          .doc(id)
          .get();

      if (!doc.exists) {
        print('Không tìm thấy manga với ID: $id');
        return null;
      }

      final data = doc.data();
      print('Dữ liệu manga: $data');

      final manga = Manga.fromMap({
        'id': doc.id,
        'name': data?['name'] ?? '',
        'description': data?['description'] ?? '',
        'genres': data?['genres'] ?? [],
        'status': data?['status'] ?? 'ongoing',
        'total_chapters': data?['total_chapters'] ?? 0,
        'latest_chapter': data?['latest_chapter'] ?? 0,
        'views': data?['views'] ?? 0,
        'follows': data?['follows'] ?? 0,
        'vote_score': data?['vote_score'] ?? 0.0,
        'vote_count': data?['vote_count'] ?? 0,
        'created_at':
            (data?['created_at'] as Timestamp).toDate().toIso8601String(),
        'updated_at':
            (data?['updated_at'] as Timestamp).toDate().toIso8601String(),
        'cover_url': data?['cover_url'] ?? '',
      });

      print('Đã chuyển đổi thành công manga: ${manga.name}');
      return manga;
    } catch (e, stackTrace) {
      print('Lỗi khi lấy thông tin manga: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Không thể lấy thông tin manga: $e');
    }
  }

  Future<List<Manga>> getAllManga() async {
    final snapshot =
        await _firestore.collection(AppConstants.mangasCollection).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Manga.fromMap({
        'id': doc.id,
        'name': data['name'] ?? '',
        'description': data['description'] ?? '',
        'genres': data['genres'] ?? [],
        'status': data['status'] ?? 'ongoing',
        'total_chapters': data['total_chapters'] ?? 0,
        'latest_chapter': data['latest_chapter'] ?? 0,
        'views': data['views'] ?? 0,
        'follows': data['follows'] ?? 0,
        'vote_score': data['vote_score'] ?? 0.0,
        'vote_count': data['vote_count'] ?? 0,
        'created_at':
            (data['created_at'] as Timestamp).toDate().toIso8601String(),
        'updated_at':
            (data['updated_at'] as Timestamp).toDate().toIso8601String(),
        'cover_url': data['cover_url'] ?? '',
      });
    }).toList();
  }

  Future<void> updateManga(String id, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.mangasCollection)
        .doc(id)
        .update(data);
  }

  // Chapter Collection
  Future<Chapter?> getMangaChapter(String mangaId, String chapterId) async {
    try {
      print('Đang tải chapter $chapterId của manga $mangaId');
      final docSnapshot = await _firestore
          .collection(AppConstants.mangasCollection)
          .doc(mangaId)
          .collection('chapters')
          .doc(chapterId)
          .get();

      if (!docSnapshot.exists) {
        print('Không tìm thấy chapter');
        return null;
      }

      final data = docSnapshot.data()!;
      print('Dữ liệu chapter: $data');

      return Chapter.fromMap({
        'id': docSnapshot.id,
        'manga_id': mangaId,
        'chapter_number': int.tryParse(docSnapshot.id) ?? 0,
        'pages': data['pages'] ?? [],
        'views': data['views'] ?? 0,
        'likes': data['likes'] ?? 0,
        'created_at': data['created_at'] is Timestamp
            ? (data['created_at'] as Timestamp).toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
        'updated_at': data['updated_at'] is Timestamp
            ? (data['updated_at'] as Timestamp).toDate().toIso8601String()
            : DateTime.now().toIso8601String(),
      });
    } catch (e, stackTrace) {
      print('Lỗi khi tải chapter: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<List<Chapter>> getMangaChapters(String mangaId) async {
    try {
      print('Đang tải chapters của manga: $mangaId');
      final snapshot = await _firestore
          .collection(AppConstants.mangasCollection)
          .doc(mangaId)
          .collection('chapters')
          .get();

      print('Số lượng chapters: ${snapshot.docs.length}');

      final chapters = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Chapter ${doc.id} data: $data');

        return Chapter.fromMap({
          'id': doc.id,
          'manga_id': mangaId,
          'chapter_number': int.tryParse(doc.id) ?? 0,
          'pages': data['pages'] ?? [],
          'views': data['views'] ?? 0,
          'likes': data['likes'] ?? 0,
          'created_at': data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
          'updated_at': data['updated_at'] is Timestamp
              ? (data['updated_at'] as Timestamp).toDate().toIso8601String()
              : DateTime.now().toIso8601String(),
        });
      }).toList();

      // Sắp xếp chapters theo số chapter giảm dần
      chapters.sort((a, b) => b.chapterNumber.compareTo(a.chapterNumber));

      print('Đã tải ${chapters.length} chapters');
      return chapters;
    } catch (e, stackTrace) {
      print('Lỗi khi tải chapters: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // User Collection
  Future<void> addToFavorites(String mangaId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).set({
      'favorites': FieldValue.arrayUnion([mangaId]),
    }, SetOptions(merge: true));
  }

  Future<void> removeFromFavorites(String mangaId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore.collection('users').doc(userId).update({
      'favorites': FieldValue.arrayRemove([mangaId]),
    });
  }

  Future<void> updateReadingHistory(String mangaId, String chapterId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final history = {
      'mangaId': mangaId,
      'chapterId': chapterId,
      'lastRead': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('users').doc(userId).set({
      'readingHistory': FieldValue.arrayUnion([history]),
    }, SetOptions(merge: true));
  }

  Future<List<String>> getUserFavorites() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return [];
    return List<String>.from(doc.data()?['favorites'] ?? []);
  }

  Future<List<Manga>> getCollectionMangas() async {
    try {
      print('Bắt đầu lấy dữ liệu từ collection mangas');
      final snapshot =
          await _firestore.collection(AppConstants.mangasCollection).get();
      print('Số lượng documents: ${snapshot.docs.length}');

      if (snapshot.docs.isEmpty) {
        print('Không tìm thấy manga nào trong collection');
        return [];
      }

      final mangas = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Document ID: ${doc.id}');
        print('Document data: $data');

        try {
          final manga = Manga.fromMap({
            'id': doc.id,
            'name': data['name'] ?? '',
            'description': data['description'] ?? '',
            'genres': data['genres'] ?? [],
            'status': data['status'] ?? 'ongoing',
            'total_chapters': data['total_chapters'] ?? 0,
            'latest_chapter': data['latest_chapter'] ?? 0,
            'views': data['views'] ?? 0,
            'follows': data['follows'] ?? 0,
            'vote_score': data['vote_score'] ?? 0.0,
            'vote_count': data['vote_count'] ?? 0,
            'created_at':
                (data['created_at'] as Timestamp).toDate().toIso8601String(),
            'updated_at':
                (data['updated_at'] as Timestamp).toDate().toIso8601String(),
            'cover_url': data['cover_url'] ?? '',
          });
          print('Đã chuyển đổi thành công manga: ${manga.name}');
          return manga;
        } catch (e) {
          print('Lỗi khi chuyển đổi document ${doc.id}: $e');
          rethrow;
        }
      }).toList();

      print('Đã chuyển đổi thành công ${mangas.length} manga');
      return mangas;
    } catch (e, stackTrace) {
      print('Lỗi khi lấy dữ liệu manga: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Không thể lấy danh sách manga: $e');
    }
  }

  Future<void> incrementMangaView(String mangaId) async {
    try {
      print('Đang cập nhật lượt xem cho manga: $mangaId');
      await _firestore
          .collection(AppConstants.mangasCollection)
          .doc(mangaId)
          .update({
        'views': FieldValue.increment(1),
      });
      print('Đã cập nhật lượt xem thành công');
    } catch (e) {
      print('Lỗi khi cập nhật lượt xem: $e');
    }
  }

  Future<Map<String, dynamic>?> getDocument(
      String collection, String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (doc.exists) {
        return {'id': doc.id, ...doc.data()!};
      }
      return null;
    } catch (e) {
      print('Error getting document: $e');
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getCollection(String collection) async {
    try {
      final snapshot = await _firestore.collection(collection).get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting collection: $e');
      rethrow;
    }
  }

  Future<void> updateDocument(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(id).update(data);
    } catch (e) {
      print('Error updating document: $e');
      rethrow;
    }
  }

  Future<String> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      final doc = await _firestore.collection(collection).add(data);
      return doc.id;
    } catch (e) {
      print('Error adding document: $e');
      rethrow;
    }
  }

  Future<void> deleteDocument(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      print('Error deleting document: $e');
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getCollectionWhere(
    String collection,
    String field,
    dynamic value,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting collection with where clause: $e');
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getCollectionOrdered(
    String collection,
    String field, {
    bool descending = false,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection(collection)
          .orderBy(field, descending: descending);

      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting ordered collection: $e');
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> searchCollection(
    String collection,
    String field,
    String searchTerm,
  ) async {
    try {
      final snapshot = await _firestore
          .collection(collection)
          .where(field, isGreaterThanOrEqualTo: searchTerm)
          .where(field, isLessThan: searchTerm + 'z')
          .get();
      return snapshot.docs;
    } catch (e) {
      print('Error searching collection: $e');
      rethrow;
    }
  }

  Stream<DocumentSnapshot> streamDocument(String collection, String id) {
    return _firestore.collection(collection).doc(id).snapshots();
  }

  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  Future<void> batchWrite(List<Map<String, dynamic>> operations) async {
    try {
      final batch = _firestore.batch();

      for (final operation in operations) {
        final type = operation['type'] as String;
        final collection = operation['collection'] as String;
        final id = operation['id'] as String;
        final data = operation['data'] as Map<String, dynamic>?;

        final docRef = _firestore.collection(collection).doc(id);

        switch (type) {
          case 'set':
            if (data != null) batch.set(docRef, data);
            break;
          case 'update':
            if (data != null) batch.update(docRef, data);
            break;
          case 'delete':
            batch.delete(docRef);
            break;
        }
      }

      await batch.commit();
    } catch (e) {
      print('Error in batch write: $e');
      rethrow;
    }
  }

  Future<List<QueryDocumentSnapshot>> getCollectionGroup(
      String collectionId) async {
    try {
      final snapshot = await _firestore.collectionGroup(collectionId).get();
      return snapshot.docs;
    } catch (e) {
      print('Error getting collection group: $e');
      rethrow;
    }
  }
}
