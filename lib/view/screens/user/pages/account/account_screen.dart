import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mangadive/controllers/auth_controller.dart';
import 'package:mangadive/view/screens/user/pages/account/edit_profile.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  AccountScreen({super.key});

  User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    if (user == null) {
      //người dùng chưa đăng nhập thì hiển thị màn hình này
      return Scaffold(
        appBar: AppBar(title: Text('Tài khoản'), centerTitle: true),
        body: ListView(
          children: [
            UserAccountsDrawerHeader(
              accountName: Text('Khách'),
              accountEmail: Text('Cấp 1'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.orange,
                child: Text(
                  'Q',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: const Color.fromARGB(255, 139, 8, 8),
                  ),
                ),
              ),
            ),

            ListTile(
              leading: Icon(Icons.login),
              title: Text('Đăng nhập'),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      );
    }
    String userName = user?.displayName ?? ' ';

    // màn hình account user đã đăng nhập
    return Scaffold(
      appBar: AppBar(title: Text('Tài khoản'), centerTitle: true),
      body: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(userName),
            accountEmail: Text('Cấp 1'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.orange,
              child: Text(
                'Q',
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Thông tin tài khoản'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('Lịch sử đọc truyện'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            title: Text('Linh thạch'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.notifications),
            title: Text('Thông báo của bạn'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.lock),
            title: Text('Đổi mật khẩu'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.description),
            title: Text('Điều khoản sử dụng'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.exit_to_app),
            title: Text('Đăng xuất'),
            onTap: () {
              authController.sigOut(context);
            },
          ),
        ],
      ),
    );
  }
}
