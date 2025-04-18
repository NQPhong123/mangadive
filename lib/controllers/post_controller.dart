import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/post.dart';

class PostController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo post mới
  Future<void> createPost({
    required String userId,
    required String title,
    required String content,
    List<String> tags = const [],
    MangaRef? mangaRef,
  }) async {
    final DateTime now = DateTime.now();
    final postId = _firestore.collection('posts').doc().id;
    
    final Map<String, dynamic> postData = {
      'id': postId,
      'user_id': userId,
      'title': title,
      'content': content,
      'tags': tags,
      'manga_ref': mangaRef?.toMap(),
      'created_at': Timestamp.fromDate(now),
      'updated_at': Timestamp.fromDate(now),
      'likes': 0,
      'comments_count': 0,
      'last_activity_at': Timestamp.fromDate(now),
      'status': 'active',
    };

    await _firestore.collection('posts').doc(postId).set(postData);

    // Thêm vào danh sách posts của user
    await _firestore.collection('users').doc(userId).collection('posts').doc(postId).set({
      'post_id': postId,
      'created_at': Timestamp.fromDate(now),
      'last_activity_at': Timestamp.fromDate(now),
      'status': 'active',
    });
  }

  // Lấy một post
  Stream<Post> getPost(String postId) {
    return _firestore
        .collection('posts')
        .doc(postId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.data() as Map<String, dynamic>;
      return Post.fromMap(data);
    });
  }

  // Cập nhật post
  Future<void> updatePost({
    required String postId,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    await _firestore.collection('posts').doc(postId).update({
      'title': title,
      'content': content,
      'tags': tags,
      'updated_at': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Xóa post (soft delete)
  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).update({
      'status': 'deleted',
      'updated_at': Timestamp.fromDate(DateTime.now()),
    });
  }

  // Like/Unlike post
  Future<void> toggleLikePost({
    required String postId,
    required String userId,
  }) async {
    final batch = _firestore.batch();
    final postRef = _firestore.collection('posts').doc(postId);
    final likeRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userId);

    final likeDoc = await likeRef.get();
    if (likeDoc.exists) {
      batch.delete(likeRef);
      batch.update(postRef, {
        'likes': FieldValue.increment(-1),
      });
    } else {
      batch.set(likeRef, {
        'user_id': userId,
        'created_at': Timestamp.fromDate(DateTime.now()),
      });
      batch.update(postRef, {
        'likes': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }

  Stream<List<Post>> getAllPosts({
    int limit = 20,
    String? lastPostId,
  }) async* {
    Query query = _firestore
        .collection('posts')
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (lastPostId != null) {
      final lastDoc = await _firestore.collection('posts').doc(lastPostId).get();
      query = query.startAfterDocument(lastDoc);
    }

    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromMap(data);
      }).toList();
    });
  }

  Stream<List<Post>> getAllPostsStream({String? mangaId}) {
    Query query = _firestore
        .collection('posts')
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true);

    if (mangaId != null) {
      query = query.where('manga_ref.manga_id', isEqualTo: mangaId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromMap(data);
      }).toList();
    });
  }

  // Lấy posts của một user
  Stream<List<Post>> getUserPosts({
    required String userId,
    int limit = 20,
    String? lastPostId,
  }) async* {
    Query query = _firestore
        .collection('posts')
        .where('user_id', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (lastPostId != null) {
      final lastDoc = await _firestore.collection('posts').doc(lastPostId).get();
      query = query.startAfterDocument(lastDoc);
    }

    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromMap(data);
      }).toList();
    });
  }

  // Lấy posts liên quan đến một manga
  Stream<List<Post>> getMangaPosts({
    required String mangaId,
    int limit = 20,
    String? lastPostId,
  }) async* {
    Query query = _firestore
        .collection('posts')
        .where('manga_ref.manga_id', isEqualTo: mangaId)
        .where('status', isEqualTo: 'active')
        .orderBy('created_at', descending: true)
        .limit(limit);

    if (lastPostId != null) {
      final lastDoc = await _firestore.collection('posts').doc(lastPostId).get();
      query = query.startAfterDocument(lastDoc);
    }

    yield* query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromMap(data);
      }).toList();
    });
  }

  // Tìm kiếm posts
  Stream<List<Post>> searchPosts(String searchTerm) {
    return _firestore
        .collection('posts')
        .where('status', isEqualTo: 'active')
        .where('title', isGreaterThanOrEqualTo: searchTerm)
        .where('title', isLessThanOrEqualTo: searchTerm + '\uf8ff')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromMap(data);
      }).toList();
    });
  }
} 