import 'package:cloud_firestore/cloud_firestore.dart';

class ReplyTo {
  final String id;
  final String userId;

  ReplyTo({
    required this.id,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
    };
  }

  factory ReplyTo.fromMap(Map<String, dynamic> map) {
    return ReplyTo(
      id: map['id'] as String,
      userId: map['user_id'] as String,
    );
  }
}

class Reply {
  final String id;
  final String userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likes;
  final String status;
  final ReplyTo replyTo;
  final List<String> mentions;

  Reply({
    required this.id,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.likes,
    required this.status,
    required this.replyTo,
    required this.mentions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'likes': likes,
      'status': status,
      'reply_to': replyTo.toMap(),
      'mentions': mentions,
    };
  }

  factory Reply.fromMap(Map<String, dynamic> map) {
    return Reply(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      content: map['content'] as String,
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
      likes: map['likes'] as int,
      status: map['status'] as String,
      replyTo: ReplyTo.fromMap(map['reply_to'] as Map<String, dynamic>),
      mentions: List<String>.from(map['mentions']),
    );
  }
} 