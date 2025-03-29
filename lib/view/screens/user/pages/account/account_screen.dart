import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangadive/controllers/auth_controller.dart';
import 'package:mangadive/view/screens/user/pages/account/edit_profile.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      //người dùng chưa đăng nhập thì hiển thị màn hình này
      return Scaffold(
        appBar: AppBar(title: const Text('Tài khoản'), centerTitle: true),
        body: ListView(
          children: [
            const UserAccountsDrawerHeader(
              accountName: Text('Khách'),
              accountEmail: Text('Cấp 1'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  'Q',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: Color.fromARGB(255, 139, 8, 8),
                  ),
                ),
              ),
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

    // màn hình account user đã đăng nhập
    return Scaffold(
      appBar: AppBar(title: const Text('Tài khoản'), centerTitle: true),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: const Text('Cấp 1'),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(
                'Q',
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Thông tin tài khoản'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Lịch sử đọc truyện'),
            onTap: () {},
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
            onTap: () {},
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
