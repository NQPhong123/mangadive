import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String email;
  final String username;
  final int experience;
  final int totalReadChapters;
  final bool premium;
  final int mangaCoin; // ✅ Thêm mới
  final DateTime createdAt;
  final DateTime lastLogin;
  final UserSettings settings;

  const User({
    required this.id,
    required this.email,
    required this.username,
    this.experience = 0,
    this.totalReadChapters = 0,
    this.premium = false,
    this.mangaCoin = 0, // ✅ Mặc định 0
    required this.createdAt,
    required this.lastLogin,
    required this.settings,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      experience: map['experience'] as int? ?? 0,
      totalReadChapters: map['totalReadChapters'] as int? ?? 0,
      premium: map['premium'] as bool? ?? false,
      mangaCoin: map['mangaCoin'] as int? ?? 0, // ✅ Lấy từ map, fallback 0
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(
              map['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastLogin: map['lastLogin'] is Timestamp
          ? (map['lastLogin'] as Timestamp).toDate()
          : DateTime.parse(
              map['lastLogin'] as String? ?? DateTime.now().toIso8601String()),
      settings:
          UserSettings.fromMap(map['settings'] as Map<String, dynamic>? ?? {}),
    );
  }
  factory User.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id;
    return User.fromMap(data);
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'experience': experience,
      'totalReadChapters': totalReadChapters,
      'premium': premium,
      'mangaCoin': mangaCoin, // ✅ Lưu vào Firestore
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
      'settings': settings.toMap(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    int? experience,
    int? totalReadChapters,
    bool? premium,
    int? mangaCoin, // ✅ Thêm vào copyWith
    DateTime? createdAt,
    DateTime? lastLogin,
    UserSettings? settings,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      experience: experience ?? this.experience,
      totalReadChapters: totalReadChapters ?? this.totalReadChapters,
      premium: premium ?? this.premium,
      mangaCoin: mangaCoin ?? this.mangaCoin,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      settings: settings ?? this.settings,
    );
  }
}

class UserSettings {
  final String theme;
  final String language;
  final NotificationSettings notification;
  final ReadingSettings reading;

  UserSettings({
    required this.theme,
    required this.language,
    required this.notification,
    required this.reading,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      theme: map['theme'] as String? ?? 'light',
      language: map['language'] as String? ?? 'vi',
      notification: NotificationSettings.fromMap(
          map['notification'] as Map<String, dynamic>? ?? {}),
      reading: ReadingSettings.fromMap(
          map['reading'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'theme': theme,
      'language': language,
      'notification': notification.toMap(),
      'reading': reading.toMap(),
    };
  }

  UserSettings copyWith({
    String? theme,
    String? language,
    NotificationSettings? notification,
    ReadingSettings? reading,
  }) {
    return UserSettings(
      theme: theme ?? this.theme,
      language: language ?? this.language,
      notification: notification ?? this.notification,
      reading: reading ?? this.reading,
    );
  }
}

class NotificationSettings {
  final bool newChapter;
  final bool system;

  NotificationSettings({
    required this.newChapter,
    required this.system,
  });

  factory NotificationSettings.fromMap(Map<String, dynamic> map) {
    return NotificationSettings(
      newChapter: map['newChapter'] as bool? ?? true,
      system: map['system'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'newChapter': newChapter,
      'system': system,
    };
  }
}

class ReadingSettings {
  final String defaultQuality;
  final String defaultDirection;

  ReadingSettings({
    required this.defaultQuality,
    required this.defaultDirection,
  });

  factory ReadingSettings.fromMap(Map<String, dynamic> map) {
    return ReadingSettings(
      defaultQuality: map['defaultQuality'] as String? ?? 'high',
      defaultDirection: map['defaultDirection'] as String? ?? 'vertical',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'defaultQuality': defaultQuality,
      'defaultDirection': defaultDirection,
    };
  }
}
