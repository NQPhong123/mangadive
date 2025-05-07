import 'package:flutter/material.dart';
import 'package:mangadive/controllers/auth_controller.dart';
import 'package:mangadive/view/screens/user/edit_profile_screen.dart';
import 'package:mangadive/view/screens/user/mangacoin_purchase_screen.dart';
import 'package:mangadive/view/screens/user/premium_screen.dart';
import 'package:mangadive/view/screens/user/reading_history_screen.dart';
import 'package:mangadive/view/screens/user/change_password_screen.dart';
import 'package:mangadive/view/screens/user/notification_screen.dart';
import 'package:provider/provider.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final user = authController.currentUser;
        final userProfile = authController.userProfile;

        final isLoggedIn = user != null;
        final username = isLoggedIn
            ? userProfile?.username ?? user.displayName ?? ''
            : 'Khách';
        final mangaCoin = isLoggedIn ? (userProfile?.mangaCoin ?? 0) : 0;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Tài khoản'),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0.5,
          ),
          body: Container(
            color: Colors.white,
            child: ListView(
              children: [
                UserAccountsDrawerHeader(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  accountName: Text(
                    username,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  accountEmail: Text(
                    'MangaCoin: $mangaCoin MC',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ),
                if (!isLoggedIn)
                  ListTile(
                    leading: const Icon(Icons.login, color: Colors.black),
                    title: const Text('Đăng nhập'),
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.black),
                    title: const Text('Thông tin tài khoản'),
                    onTap: () {
                      if (userProfile != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EditProfileScreen(user: userProfile),
                          ),
                        );
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.black),
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
                    leading: const Icon(Icons.account_balance_wallet,
                        color: Colors.black),
                    title: const Text('Đăng ký premium'),
                    onTap: () {
                      PremiumBottomSheet.show(context, authController);
                      ;
                    },
                  ),
                  ListTile(
                    leading:
                        const Icon(Icons.notifications, color: Colors.black),
                    title: const Text('Thông báo của bạn'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock, color: Colors.black),
                    title: const Text('Đổi mật khẩu'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen()),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_card, color: Colors.black),
                    title: const Text('Mua MangaCoin'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MangaCoinPurchaseScreen(
                              authController: authController),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.black),
                    title: const Text('Đăng xuất'),
                    onTap: () {
                      authController.signOut(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
