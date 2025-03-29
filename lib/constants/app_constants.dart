class AppConstants {
  // App info
  static const String appName = 'MangaDive';
  static const String appVersion = '1.0.0';

  // Collection paths
  static const String mangasCollection = 'mangas';
  static const String chaptersCollection = 'chapters';
  static const String usersCollection = 'users';

  // Status
  static const String statusOngoing = 'Đang tiến hành';
  static const String statusCompleted = 'Đã hoàn thành';
  static const String statusDropped = 'Đã drop';

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

  // Image paths
  static const String cloudinaryBaseUrl =
      'https://res.cloudinary.com/dbmua87fp/image/upload';
  static const String mangaImagePath = '$cloudinaryBaseUrl/manga';
}
