import "package:firebase_auth/firebase_auth.dart" as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/user.dart' as models;
import 'package:logging/logging.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userCollection = 'users';
  final _logger = Logger('AuthService');

  // register account with email and password
  Future<models.User?> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await getUserById(userCredential.user!.uid);
    } catch (e) {
      _logger.warning("Lỗi đăng ký: $e");
      return null;
    }
  }

  //signIn account with email and password
  Future<models.User?> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await getUserById(userCredential.user!.uid);
    } catch (e) {
      _logger.warning("Lỗi đăng nhập: $e");
      return null;
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // get current user
  Future<models.User?> getCurrentUser() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) return null;
    return await getUserById(firebaseUser.uid);
  }

  // Stream để lắng nghe thay đổi trạng thái đăng nhập
  Stream<models.User?> get authStateChanges =>
      _auth.authStateChanges().asyncMap((firebaseUser) async {
        if (firebaseUser == null) return null;
        return await getUserById(firebaseUser.uid);
      });

  // Lấy user theo ID
  Future<models.User?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data()!;
      data['id'] = doc.id; // Thêm id vào data
      return models.User.fromJson(data);
    } catch (e) {
      _logger.severe('Lỗi khi lấy user by ID: $e');
      return null;
    }
  }

  // Đăng ký user mới
  Future<models.User?> signUpUser({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        final user = models.User(
          id: userCredential.user!.uid,
          email: email,
          username: username,
          roles: ['user'], // Mặc định role là user
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.id).set({
          'email': user.email,
          'username': user.username,
          'roles': user.roles,
          'createdAt': user.createdAt,
          'lastLoginAt': user.lastLoginAt,
        });

        _logger.info('Đã tạo user mới: ${user.email}');
        return user;
      }
    } catch (e) {
      _logger.severe('Lỗi khi đăng ký: $e');
      rethrow;
    }
    return null;
  }

  // Đăng nhập bằng email/password
  Future<models.User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .update({'lastLoginAt': DateTime.now()});

        return await getUserById(userCredential.user!.uid);
      }
    } catch (e) {
      _logger.severe('Lỗi khi đăng nhập: $e');
      rethrow;
    }
    return null;
  }

  // Đăng nhập bằng Google
  Future<models.User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      if (userCredential.user != null) {
        final userDoc =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (!userDoc.exists) {
          final user = models.User(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            username: userCredential.user!.displayName ?? 'User',
            roles: ['user'],
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );

          await _firestore.collection('users').doc(user.id).set({
            'email': user.email,
            'username': user.username,
            'roles': user.roles,
            'createdAt': user.createdAt,
            'lastLoginAt': user.lastLoginAt,
          });

          return user;
        } else {
          await _firestore
              .collection('users')
              .doc(userCredential.user!.uid)
              .update({'lastLoginAt': DateTime.now()});

          return await getUserById(userCredential.user!.uid);
        }
      }
    } catch (e) {
      _logger.severe('Lỗi khi đăng nhập Google: $e');
      rethrow;
    }
    return null;
  }

  // Đăng nhập bằng Facebook
  Future<models.User?> signInWithFacebook() async {
    try {
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        final credential = firebase_auth.FacebookAuthProvider.credential(
          loginResult.accessToken!.token,
        );

        final userCredential = await _auth.signInWithCredential(credential);
        if (userCredential.user != null) {
          final userDoc =
              await _firestore
                  .collection('users')
                  .doc(userCredential.user!.uid)
                  .get();

          if (!userDoc.exists) {
            final user = models.User(
              id: userCredential.user!.uid,
              email: userCredential.user!.email!,
              username: userCredential.user!.displayName ?? 'User',
              roles: ['user'],
              createdAt: DateTime.now(),
              lastLoginAt: DateTime.now(),
            );

            await _firestore.collection('users').doc(user.id).set({
              'email': user.email,
              'username': user.username,
              'roles': user.roles,
              'createdAt': user.createdAt,
              'lastLoginAt': user.lastLoginAt,
            });

            return user;
          } else {
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .update({'lastLoginAt': DateTime.now()});

            return await getUserById(userCredential.user!.uid);
          }
        }
      }
    } catch (e) {
      _logger.severe('Lỗi đăng nhập Facebook: $e');
      rethrow;
    }
    return null;
  }

  // Cập nhật thông tin user
  Future<void> updateUser(models.User user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
      _logger.info('Đã cập nhật user: ${user.email}');
    } catch (e) {
      _logger.severe('Lỗi khi cập nhật user: $e');
      rethrow;
    }
  }

  // Phân quyền admin
  Future<void> setAdminRole(String userId) async {
    final user = await getUserById(userId);
    if (user == null) throw Exception('User không tồn tại');

    final updatedUser = user.copyWith(roles: ['admin']);
    await updateUser(updatedUser);
  }

  // Kiểm tra quyền admin
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.roles.contains('admin') ?? false;
  }

  // Thêm manga vào danh sách yêu thích
  Future<void> addToFavorites(String mangaId) async {
    final user = await getCurrentUser();
    if (user == null) throw Exception('Chưa đăng nhập');

    if (!user.favoriteMangas.contains(mangaId)) {
      final updatedUser = user.copyWith(
        favoriteMangas: [...user.favoriteMangas, mangaId],
      );
      await updateUser(updatedUser);
    }
  }

  // Thêm vào lịch sử đọc
  Future<void> addToHistory(String mangaId) async {
    final user = await getCurrentUser();
    if (user == null) throw Exception('Chưa đăng nhập');

    final updatedHistory = Map<String, DateTime>.from(user.readingHistory);
    updatedHistory[mangaId] = DateTime.now();

    final updatedUser = user.copyWith(readingHistory: updatedHistory);
    await updateUser(updatedUser);
  }

  // Lấy danh sách tất cả users
  Future<List<models.User>> getAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Thêm id vào data
        return models.User.fromJson(data);
      }).toList();
    } catch (e) {
      _logger.severe('Lỗi khi lấy danh sách users: $e');
      rethrow;
    }
  }

  // Xóa quyền admin
  Future<void> removeAdminRole(String userId) async {
    final user = await getUserById(userId);
    if (user == null) throw Exception('User không tồn tại');

    final updatedUser = user.copyWith(roles: ['user']);
    await updateUser(updatedUser);
  }

  // Thêm role cho user
  Future<void> addRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'roles': FieldValue.arrayUnion([role]),
      });
      _logger.info('Đã thêm role $role cho user $userId');
    } catch (e) {
      _logger.severe('Lỗi khi thêm role: $e');
      rethrow;
    }
  }

  // Xóa role của user
  Future<void> removeRole(String userId, String role) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'roles': FieldValue.arrayRemove([role]),
      });
      _logger.info('Đã xóa role $role của user $userId');
    } catch (e) {
      _logger.severe('Lỗi khi xóa role: $e');
      rethrow;
    }
  }

  // Kiểm tra user có role cụ thể không
  Future<bool> hasRole(String userId, String role) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        _logger.warning('User $userId không tồn tại');
        return false;
      }

      final userData = userDoc.data();
      if (userData == null) {
        _logger.warning('User $userId không có dữ liệu');
        return false;
      }

      final roles = List<String>.from(userData['roles'] ?? []);
      final hasRole = roles.contains(role);
      _logger.info('User $userId ${hasRole ? 'có' : 'không có'} role $role');
      return hasRole;
    } catch (e) {
      _logger.severe('Lỗi khi kiểm tra role: $e');
      return false;
    }
  }
}
