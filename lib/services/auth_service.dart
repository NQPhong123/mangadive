import "package:firebase_auth/firebase_auth.dart" as firebase_auth;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/models/user.dart' as models;
import 'package:mangadive/constants/app_constants.dart';
import 'package:logging/logging.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _logger = Logger('AuthService');

  // Đăng ký tài khoản với email và password
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

  // Đăng nhập tài khoản với email và password
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

  // Đăng xuất
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Lấy người dùng hiện tại
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
      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .get();
      if (doc.exists) {
        return models.User.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      _logger.severe('Lỗi khi lấy user by ID: $e');
      return null;
    }
  }

  // Đăng ký user mới
  Future<models.User?> signUpUser(
    String email,
    String password,
    String username,
  ) async {
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
          experience: 0, // Giá trị mặc định
          totalReadChapters: 0, // Giá trị mặc định
          premium: false, // Giá trị mặc định
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
          settings: models.UserSettings(
            theme: 'light',
            language: 'vi',
            notification: models.NotificationSettings(
              newChapter: true,
              system: true,
            ),
            reading: models.ReadingSettings(
              defaultQuality: 'high',
              defaultDirection: 'vertical',
            ),
          ),
        );

        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.id)
            .set(user.toMap());

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
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .update({
          'lastLogin': FieldValue.serverTimestamp(),
        });

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
        final userDoc = await _firestore
            .collection(AppConstants.usersCollection)
            .doc(userCredential.user!.uid)
            .get();

        if (!userDoc.exists) {
          final user = models.User(
            id: userCredential.user!.uid,
            email: userCredential.user!.email!,
            username: userCredential.user!.displayName ?? 'User',
            experience: 0, // Giá trị mặc định
            totalReadChapters: 0, // Giá trị mặc định
            premium: false, // Giá trị mặc định
            createdAt: DateTime.now(),
            lastLogin: DateTime.now(),
            settings: models.UserSettings(
              theme: 'light',
              language: 'vi',
              notification: models.NotificationSettings(
                newChapter: true,
                system: true,
              ),
              reading: models.ReadingSettings(
                defaultQuality: 'high',
                defaultDirection: 'vertical',
              ),
            ),
          );

          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(user.id)
              .set(user.toMap());

          return user;
        } else {
          await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .update({'lastLogin': FieldValue.serverTimestamp()});

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
          final userDoc = await _firestore
              .collection(AppConstants.usersCollection)
              .doc(userCredential.user!.uid)
              .get();

          if (!userDoc.exists) {
            final user = models.User(
              id: userCredential.user!.uid,
              email: userCredential.user!.email!,
              username: userCredential.user!.displayName ?? 'User',
              experience: 0, // Giá trị mặc định
              totalReadChapters: 0, // Giá trị mặc định
              premium: false, // Giá trị mặc định
              createdAt: DateTime.now(),
              lastLogin: DateTime.now(),
              settings: models.UserSettings(
                theme: 'light',
                language: 'vi',
                notification: models.NotificationSettings(
                  newChapter: true,
                  system: true,
                ),
                reading: models.ReadingSettings(
                  defaultQuality: 'high',
                  defaultDirection: 'vertical',
                ),
              ),
            );

            await _firestore
                .collection(AppConstants.usersCollection)
                .doc(user.id)
                .set(user.toMap());

            return user;
          } else {
            await _firestore
                .collection(AppConstants.usersCollection)
                .doc(userCredential.user!.uid)
                .update({'lastLogin': FieldValue.serverTimestamp()});

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

  // Đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Cập nhật thông tin user
  Future<void> updateUser(models.User user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .update(user.toMap());
      _logger.info('Đã cập nhật user: ${user.email}');
    } catch (e) {
      _logger.severe('Lỗi khi cập nhật user: $e');
      rethrow;
    }
  }

  // Lấy danh sách tất cả users
  Future<List<models.User>> getAllUsers() async {
    try {
      final querySnapshot =
          await _firestore.collection(AppConstants.usersCollection).get();
      return querySnapshot.docs
          .map((doc) => models.User.fromFirestore(doc))
          .toList();
    } catch (e) {
      _logger.severe('Lỗi khi lấy danh sách users: $e');
      rethrow;
    }
  }
}
