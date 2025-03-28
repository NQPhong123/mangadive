import 'package:flutter/material.dart';
import 'package:mangadive/view/screens/user/pages/home_screen.dart';

import 'package:mangadive/view/screens/user/pages/account/account_screen.dart';

import 'package:mangadive/view/widgets/navigation_bar/nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    Center(child: Text('Tìm kiếm', style: TextStyle(fontSize: 24))),
    Center(child: Text('BookMark', style: TextStyle(fontSize: 24))),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Hiển thị màn hình tương ứng
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
