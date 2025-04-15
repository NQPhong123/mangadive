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
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        final userProfile = authController.userProfile;

        if (user == null) {
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

        return Scaffold(
          appBar: AppBar(title: const Text('Tài khoản'), centerTitle: true),
          body: ListView(
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userProfile?.username ?? user.displayName ?? ''),
                accountEmail: const Text('Cấp 1'),
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Thông tin tài khoản'),
                onTap: () {
                  if (userProfile != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfileScreen(user: userProfile),
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
                    MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
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
      },
    );
  }
}
