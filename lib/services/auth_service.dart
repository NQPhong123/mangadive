import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // register account with email and password
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Lỗi đăng ký: $e");
      return null;
    }
  }

  //signIn account with email and password
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      return null;
    }
  }

  //sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // sign in with facebook
  Future<User?> signInWithFacebook() async {
    try {
      // Trigger the sign-in flow
      final LoginResult loginResult = await FacebookAuth.instance.login();

      if (loginResult.status == LoginStatus.success) {
        // Create a credential from the access token
        final OAuthCredential facebookAuthCredential =
            FacebookAuthProvider.credential(loginResult.accessToken!.token);

        // Once signed in, return the UserCredential
        UserCredential userCredential = await _auth.signInWithCredential(
          facebookAuthCredential,
        );
        print("✅ Đăng nhập thành công: ${userCredential.user?.displayName}");
        return userCredential.user;
      } else if (loginResult.status == LoginStatus.cancelled) {
        print("⚠️ Người dùng đã hủy đăng nhập Facebook.");
        return null;
      } else {
        print("❌ Lỗi đăng nhập Facebook: ${loginResult.message}");
        return null;
      }
    } catch (e) {
      print("Lỗi đăng nhập bằng Facebook: $e");
      return null;
    }
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<User?> signInWithGoogle() async {
    try {
      // Mở hộp thoại đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Lấy thông tin xác thực từ Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Tạo credential để đăng nhập Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      return userCredential.user;
    } catch (e) {
      print("Lỗi đăng nhập: $e");
      return null;
    }
  }
}
