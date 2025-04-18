import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/comment.dart';
import 'package:mangadive/models/reply.dart';
import 'package:uuid/uuid.dart';

class CommentController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Tạo comment mới
  Future<void> createComment({
    required String userId,
    required String content,
    required CommentSource source,
    bool isSpoiler = false,
    List<String> mentions = const [],
  }) async {
    final DateTime now = DateTime.now();
    final Map<String, dynamic> commentData = {
      'id': _firestore.collection('comments').doc().id,
      'userId': userId,
      'content': content,
      'source': source.toMap(),
      'isSpoiler': isSpoiler,
      'mentions': mentions,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'likes': 0,
      'repliesCount': 0,
      'status': 'active',
    };

    // Thêm trường chapterPath nếu đây là comment cho chapter
    if (source.chapterId != null && source.mangaId != null) {
      commentData['chapterPath'] = '${source.mangaId}:${source.chapterId}';
    }

    final comment = Comment.fromMap(commentData);

    await _firestore.collection('comments').doc(comment.id).set(commentData);

    // Update comments count
    if (source.postId != null) {
      await _firestore.collection('posts').doc(source.postId).update({
        'commentsCount': FieldValue.increment(1),
        'lastActivityAt': Timestamp.fromDate(now),
      });
    } else if (source.chapterId != null) {
      await _firestore.collection('chapters').doc(source.chapterId).update({
        'commentsCount': FieldValue.increment(1),
        'lastActivityAt': Timestamp.fromDate(now),
      });
    }
  }

  // Tạo reply cho comment
  Future<Reply> createReply({
    required String userId,
    required String commentId,
    required String content,
    required ReplyTo replyTo,
    List<String> mentions = const [],
  }) async {
    final DateTime now = DateTime.now();
    final Map<String, dynamic> replyData = {
      'id': _firestore.collection('replies').doc().id,
      'userId': userId,
      'content': content,
      'replyTo': replyTo.toMap(),
      'mentions': mentions,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
      'likes': 0,
      'status': 'active',
    };

    final reply = Reply.fromMap(replyData);

    await _firestore.collection('replies').doc(reply.id).set(replyData);

    // Update replies count
    await _firestore.collection('comments').doc(commentId).update({
      'repliesCount': FieldValue.increment(1),
      'lastActivityAt': Timestamp.fromDate(now),
    });

    return reply;
  }

  // Like/Unlike comment
  Future<void> toggleLikeComment({
    required String commentId,
    required String userId,
  }) async {
    final batch = _firestore.batch();
    final commentRef = _firestore.collection('comments').doc(commentId);
    final likeRef = _firestore
        .collection('comments')
        .doc(commentId)
        .collection('likes')
        .doc(userId);

    final likeDoc = await likeRef.get();
    if (likeDoc.exists) {
      batch.delete(likeRef);
      batch.update(commentRef, {
        'likes': FieldValue.increment(-1),
      });
    } else {
      batch.set(likeRef, {
        'userId': userId,
        'createdAt': DateTime.now(),
      });
      batch.update(commentRef, {
        'likes': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }

  // Like/Unlike reply
  Future<void> toggleLikeReply({
    required String commentId,
    required String replyId,
    required String userId,
  }) async {
    final batch = _firestore.batch();
    final replyRef = _firestore.collection('replies').doc(replyId);
    final likeRef = _firestore
        .collection('replies')
        .doc(replyId)
        .collection('likes')
        .doc(userId);

    final likeDoc = await likeRef.get();
    if (likeDoc.exists) {
      batch.delete(likeRef);
      batch.update(replyRef, {
        'likes': FieldValue.increment(-1),
      });
    } else {
      batch.set(likeRef, {
        'userId': userId,
        'createdAt': DateTime.now(),
      });
      batch.update(replyRef, {
        'likes': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }

  // Lấy comments theo source
  Stream<List<Comment>> getComments({required CommentSource source}) {
    Query query = _firestore.collection('comments').where('status', isEqualTo: 'active');
    
    if (source.postId != null) {
      query = query.where('source.postId', isEqualTo: source.postId);
    } else {
      // Tạo một trường tổng hợp trong Firestore giúp tìm kiếm không cần index phức tạp
      final String chapterPath = '${source.mangaId}:${source.chapterId}';
      query = query.where('chapterPath', isEqualTo: chapterPath);
    }
    
    // Không sử dụng orderBy trong truy vấn để tránh cần index composite
    return query
      .snapshots()
      .map((snapshot) {
        final docs = snapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            data['id'] = doc.id; // Thêm id vào data
            return Comment.fromMap(data);
          })
          .toList();
        
        // Sắp xếp dữ liệu trên client thay vì trong truy vấn
        docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return docs;
      });
  }

  // Lấy replies của comment
  Stream<List<Reply>> getReplies({
    required String commentId,
    String status = 'active',
  }) {
    return _firestore
        .collection('replies')
        .where('replyTo.id', isEqualTo: commentId)
        .where('status', isEqualTo: status)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Reply.fromMap(data);
      }).toList();
    });
  }
} 