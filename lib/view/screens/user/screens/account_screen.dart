import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangadive/controllers/auth_controller.dart';
import 'package:mangadive/models/user.dart' as models;
import 'package:mangadive/services/auth_service.dart';
import 'package:mangadive/view/screens/user/screens/edit_profile_screen.dart';
import 'package:mangadive/view/screens/user/screens/reading_history_screen.dart';
import 'package:mangadive/view/screens/user/screens/change_password_screen.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = FirebaseAuth.instance.currentUser;
    final authService = AuthService(); // Khởi tạo AuthService

    if (user == null) {
      // Người dùng chưa đăng nhập thì hiển thị màn hình này
      return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản'), centerTitle: true),
        body: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Khách'),
              accountEmail: Text('Cấp 1'),
            ),
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Đăng nhập'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      );
    }

    String userName = user.displayName ?? ' ';

    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản'), centerTitle: true),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: const Text('Cấp 1'),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Thông tin tài khoản'),
            onTap: () async {
              // Lấy thông tin user từ AuthService
              models.User? currentUser =
                  await authService.getUserById(user.uid);
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(user: currentUser),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Không thể lấy thông tin người dùng'),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Lịch sử đọc truyện'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReadingHistoryScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Linh thạch'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Thông báo của bạn'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Đổi mật khẩu'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Điều khoản sử dụng'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Đăng xuất'),
            onTap: () {
              authController.signOut(context);
            },
          ),
        ],
      ),
    );
  }
}
