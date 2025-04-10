class AppConstants {
  // App info
  static const String appName = 'MangaDive';
  static const String appVersion = '1.0.0';

  // Collection paths
  static const String usersCollection = 'users';
  static const String mangasCollection = 'mangas';
  static const String categoriesCollection = 'categories';
  static const String cacheCollection = 'cache';

  // Sub-collection paths
  static const String chaptersCollection = 'chapters';
  static const String ratingsCollection = 'ratings';
  static const String readingHistoryCollection = 'reading_history';
  static const String followsCollection = 'follows';
  static const String notificationsCollection = 'notifications';
  static const String purchasesCollection = 'purchases';

  // Manga status
  static const String statusOngoing = 'ongoing';
  static const String statusCompleted = 'completed';
  static const String statusHiatus = 'hiatus';

  // Reading directions
  static const String directionVertical = 'vertical';
  static const String directionHorizontal = 'horizontal';
  static const String directionRightToLeft = 'right_to_left';

  // Image quality
  static const String qualityHigh = 'high';
  static const String qualityMedium = 'medium';
  static const String qualityLow = 'low';

  // Notification types
  static const String notifTypeNewChapter = 'new_chapter';
  static const String notifTypeFollowUpdate = 'follow_update';
  static const String notifTypeSystem = 'system';

  // Error messages
  static const String errorLoadingManga = 'Không thể tải thông tin manga';
  static const String errorLoadingChapter = 'Không thể tải chapter';
  static const String errorNoChapters = 'Chưa có chapter nào';
  static const String errorLoadingImage = 'Không thể tải ảnh';
  static const String errorNetwork = 'Lỗi kết nối mạng';
  static const String errorUnknown = 'Đã xảy ra lỗi';

  // UI text
  static const String noImage = 'Không có ảnh';
  static const String chapterList = 'Danh sách chapter';
  static const String loading = 'Đang tải...';
  static const String readFromStart = 'Đọc từ đầu';
  static const String continueReading = 'Tiếp tục đọc';
  static const String addToFavorites = 'Thêm vào yêu thích';
  static const String removeFromFavorites = 'Xóa khỏi yêu thích';

  // Payment status
  static const String paymentStatusPending = 'pending';
  static const String paymentStatusCompleted = 'completed';
  static const String paymentStatusFailed = 'failed';

  // Image paths
  static const String cloudinaryBaseUrl =
      'https://res.cloudinary.com/dbmua87fp/image/upload';
  static const String mangaImagePath = '$cloudinaryBaseUrl/manga';
}
