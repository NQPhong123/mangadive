import 'package:flutter/material.dart';

class NavBar extends StatefulWidget {
  final Function(int) onItemTapped;
  final int selectedIndex;

  const NavBar({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.home,
            color: widget.selectedIndex == 0 ? Colors.blue : Colors.black,
          ),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.search,
            color: widget.selectedIndex == 1 ? Colors.blue : Colors.black,
          ),
          label: 'Tìm kiếm',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.bookmark_border,
            color: widget.selectedIndex == 2 ? Colors.blue : Colors.black,
          ),
          label: 'BookMark',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: widget.selectedIndex == 3 ? Colors.blue : Colors.black,
          ),
          label: 'Tài khoản',
        ),
      ],
      currentIndex: widget.selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black,
      onTap: widget.onItemTapped,
    );
  }
}
