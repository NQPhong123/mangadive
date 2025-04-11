import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/chapter.dart';
import 'package:mangadive/constants/app_constants.dart';
import 'package:mangadive/models/category.dart';

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
        'title': data?['title'] ?? '',
        'title_lowercase': data?['title_lowercase'] ?? '',
        'description': data?['description'] ?? '',
        'coverImage': data?['coverImage'] ?? '',
        'author': data?['author'] ?? '',
        'artist': data?['artist'] ?? '',
        'genres': data?['genres'] ?? [],
        'status': data?['status'] ?? 'ongoing',
        'totalViews': data?['totalViews'] ?? 0,
        'totalFollowers': data?['totalFollowers'] ?? 0,
        'averageRating': data?['averageRating'] ?? 0.0,
        'isPremium': data?['isPremium'] ?? false,
        'price': data?['price'] ?? 0.0,
        'lastChapterNumber': data?['lastChapterNumber'] ?? 0,
        'popularity_score': data?['popularity_score'] ?? 0,
        'search_keywords': data?['search_keywords'] ?? [],
        'createdAt': data?['createdAt'] ?? Timestamp.now(),
        'updatedAt': data?['updatedAt'] ?? Timestamp.now(),
      });

      print('Đã chuyển đổi thành công manga: ${manga.title}');
      return manga;
    } catch (e, stackTrace) {
      print('Lỗi khi lấy thông tin manga: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Không thể lấy thông tin manga: $e');
    }
  }

  Future<bool> isUserPremium() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      final doc = await _firestore.collection('users').doc(userId).get();
      if (!doc.exists) return false;

      return doc.data()?['isPremium'] == true;
    } catch (e) {
      print('Lỗi khi kiểm tra trạng thái premium: $e');
      return false;
    }
  }

  Future<List<Category>> getAllCategories() async {
    try {
      // Kiểm tra collection có tồn tại không
      final collectionRef = FirebaseFirestore.instance.collection('categories');
      final snapshot = await collectionRef.get();

      print("Raw categories data: ${snapshot.docs.length} documents");

      if (snapshot.docs.isEmpty) {
        print("Không có thể loại nào trong collection");
        return [];
      }

      final categories = snapshot.docs.map((doc) {
        try {
          print("Processing category document: ${doc.id}");
          print("Document data: ${doc.data()}");
          return Category.fromFirestore(doc);
        } catch (e) {
          print("Lỗi khi chuyển đổi document ${doc.id}: $e");
          return null;
        }
      }).whereType<Category>().toList();

      print("Đã chuyển đổi thành công ${categories.length} thể loại");
      return categories;
    } catch (e) {
      print('Lỗi khi lấy danh sách thể loại: $e');
      print('Stack trace: ${StackTrace.current}');
      return [];
    }
  }


    Future<List<Manga>> getAllManga() async {
    try {
      final snapshot =
          await _firestore.collection(AppConstants.mangasCollection).get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Manga.fromMap({
          'id': doc.id,
          'title': data['title'] ?? '',
          'title_lowercase': data['title_lowercase'] ?? '',
          'description': data['description'] ?? '',
          'coverImage': data['coverImage'] ?? '',
          'author': data['author'] ?? '',
          'artist': data['artist'] ?? '',
          'genres': data['genres'] ?? [],
          'status': data['status'] ?? 'ongoing',
          'totalViews': data['totalViews'] ?? 0,
          'totalFollowers': data['totalFollowers'] ?? 0,
          'averageRating': data['averageRating'] ?? 0.0,
          'isPremium': data['isPremium'] ?? false,
          'price': data['price'] ?? 0.0,
          'lastChapterNumber': data['lastChapterNumber'] ?? 0,
          'popularity_score': data['popularity_score'] ?? 0,
          'search_keywords': data['search_keywords'] ?? [],
          'createdAt': data['createdAt'] ?? Timestamp.now(),
          'updatedAt': data['updatedAt'] ?? Timestamp.now(),
        });
      }).toList();
    } catch (e, stackTrace) {
      print('Lỗi khi lấy danh sách manga: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
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

      final pagesData = (data['pages'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
      final pages = pagesData.map((pageData) => 
        ChapterPage(
          imageUrl: pageData['image_url'] ?? '',
          pageNumber: pageData['page_number'] ?? 0,
        )
      ).toList();

      return Chapter(
        id: docSnapshot.id,
        mangaId: mangaId,
        chapterNumber: int.tryParse(docSnapshot.id) ?? 0,
        likes: data['likes'] ?? 0,
        createdAt: data['created_at'] is Timestamp
            ? (data['created_at'] as Timestamp).toDate()
            : DateTime.now(),
        pages: pages,
      );
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

        final pagesData = (data['pages'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
        final pages = pagesData.map((pageData) => 
          ChapterPage(
            imageUrl: pageData['image_url'] ?? '',
            pageNumber: pageData['page_number'] ?? 0,
          )
        ).toList();

        return Chapter(
          id: doc.id,
          mangaId: mangaId,
          chapterNumber: int.tryParse(doc.id) ?? 0,
          likes: data['likes'] ?? 0,
          createdAt: data['created_at'] is Timestamp
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.now(),
          pages: pages,
        );
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

  Future<void> incrementMangaView(String mangaId) async {
    try {
      print('Đang cập nhật lượt xem cho manga: $mangaId');
      await _firestore
          .collection(AppConstants.mangasCollection)
          .doc(mangaId)
          .update({
        'totalViews': FieldValue.increment(1),
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
