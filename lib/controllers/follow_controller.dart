// import 'package:flutter/material.dart';


// class FollowController extends ChangeNotifier {
//   final FollowService _followService = FollowService();
  
//   List<FollowModel> _follows = [];
//   bool _isLoading = false;
//   String? _error;
//   bool _isFollowing = false;

//   // Getters
//   List<FollowModel> get follows => _follows;
//   bool get isLoading => _isLoading;
//   String? get error => _error;
//   bool get isFollowing => _isFollowing;

//   // Lấy danh sách follows của người dùng
//   Future<void> loadUserFollows(String userId) async {
//     _setLoading(true);

//     try {
//       _followService.getUserFollows(userId).listen(
//         (follows) {
//           _follows = follows;
//           _setLoading(false);
//         },
//         onError: (e) {
//           _setError('Không thể tải danh sách manga đã theo dõi: $e');
//         },
//       );
//     } catch (e) {
//       _setError('Đã xảy ra lỗi: $e');
//     }
//   }

//   // Kiểm tra xem người dùng đã theo dõi manga chưa
//   Future<bool> checkIfFollowing(String userId, String mangaId) async {
//     _setLoading(true);

//     try {
//       final isFollowing = await _followService.isFollowing(userId, mangaId);
//       _isFollowing = isFollowing;
//       _setLoading(false);
//       return isFollowing;
//     } catch (e) {
//       _setError('Không thể kiểm tra trạng thái theo dõi: $e');
//       return false;
//     }
//   }

//   // Theo dõi manga
//   Future<void> followManga(String userId, String mangaId) async {
//     _setLoading(true);

//     try {
//       await _followService.followManga(userId, mangaId);
//       _isFollowing = true;
//       _setLoading(false);
//     } catch (e) {
//       _setError('Không thể theo dõi manga: $e');
//     }
//   }

//   // Bỏ theo dõi manga
//   Future<void> unfollowManga(String userId, String mangaId) async {
//     _setLoading(true);

//     try {
//       await _followService.unfollowManga(userId, mangaId);
//       _isFollowing = false;
      
//       // Cập nhật lại danh sách follows
//       _follows = _follows.where((follow) => follow.mangaId != mangaId).toList();
      
//       _setLoading(false);
//     } catch (e) {
//       _setError('Không thể bỏ theo dõi manga: $e');
//     }
//   }

//   // Theo dõi hoặc bỏ theo dõi manga
//   Future<void> toggleFollow(String userId, String mangaId) async {
//     final isCurrentlyFollowing = await checkIfFollowing(userId, mangaId);
    
//     if (isCurrentlyFollowing) {
//       await unfollowManga(userId, mangaId);
//     } else {
//       await followManga(userId, mangaId);
//     }
//   }

//   // Cập nhật tiến độ đọc
//   Future<void> updateReadingProgress(
//     String userId,
//     String mangaId, 
//     int chapterNumber,
//     int readingTimeInSeconds,
//   ) async {
//     try {
//       await _followService.updateReadingProgress(
//         userId, 
//         mangaId, 
//         chapterNumber, 
//         readingTimeInSeconds,
//       );
      
//       // Cập nhật lại trạng thái following
//       _isFollowing = true;
      
//       // Nếu đang hiển thị danh sách follows, cập nhật lại
//       if (_follows.isNotEmpty) {
//         await loadUserFollows(userId);
//       }
//     } catch (e) {
//       _setError('Không thể cập nhật tiến độ đọc: $e');
//     }
//   }

//   // Thêm bookmark
//   Future<void> addBookmark(
//     String userId, 
//     String mangaId, 
//     int chapterNumber, 
//     int pageNumber,
//   ) async {
//     try {
//       await _followService.addBookmark(
//         userId, 
//         mangaId, 
//         chapterNumber, 
//         pageNumber,
//       );
      
//       // Cập nhật lại trạng thái following
//       _isFollowing = true;
      
//       // Nếu đang hiển thị danh sách follows, cập nhật lại
//       if (_follows.isNotEmpty) {
//         await loadUserFollows(userId);
//       }
//     } catch (e) {
//       _setError('Không thể thêm bookmark: $e');
//     }
//   }

//   // Xóa bookmark
//   Future<void> removeBookmark(String userId, String mangaId) async {
//     try {
//       await _followService.removeBookmark(userId, mangaId);
      
//       // Nếu đang hiển thị danh sách follows, cập nhật lại
//       if (_follows.isNotEmpty) {
//         await loadUserFollows(userId);
//       }
//     } catch (e) {
//       _setError('Không thể xóa bookmark: $e');
//     }
//   }

//   // Helper methods
//   void _setLoading(bool isLoading) {
//     _isLoading = isLoading;
//     _error = null;
//     notifyListeners();
//   }

//   void _setError(String error) {
//     _error = error;
//     _isLoading = false;
//     notifyListeners();
//   }

//   void clearError() {
//     _error = null;
//     notifyListeners();
//   }
// } 