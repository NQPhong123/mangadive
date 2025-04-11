import 'package:flutter/material.dart';
import 'package:mangadive/routes/app_routes.dart';
import 'package:mangadive/view/widgets/navigation_bar/nav_bar.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  // Keys để giữ navigator stack riêng cho từng tab
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  // Routes tương ứng với từng tab
  final List<String> _tabRoutes = [
    AppRoutes.home,
    AppRoutes.discover,
    AppRoutes.bookmark,
    AppRoutes.account,
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: List.generate(_tabRoutes.length, (index) {
          return Navigator(
            key: _navigatorKeys[index],
            initialRoute: _tabRoutes[index],
            onGenerateRoute: AppRoutes.generateRoute,
          );
        }),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
      extendBody: true,
    );
  }
}
