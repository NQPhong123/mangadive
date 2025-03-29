import 'package:flutter/material.dart';
import 'package:mangadive/view/widgets/home/search_bar.dart';
import 'package:mangadive/view/widgets/home/banner_widget.dart';
import 'package:mangadive/view/widgets/home/manga_grid_item.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';
import 'package:mangadive/services/firebase_service.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/view/widgets/navigation_bar/nav_bar.dart';
import 'package:mangadive/view/screens/user/pages/account/account_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  List<Manga> _mangas = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadMangas();
  }

  Future<void> _loadMangas() async {
    setState(() => _isLoading = true);
    try {
      print('Đang tải manga...');
      final mangas = await _firebaseService.getCollectionMangas();
      print('Đã tải xong manga: ${mangas.length} bộ');
      print(
          'Manga đầu tiên: ${mangas.isNotEmpty ? mangas.first.name : 'không có'}');

      if (mounted) {
        setState(() {
          _mangas = mangas;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Lỗi khi tải manga: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _onNavBarTap(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget _buildCurrentScreen() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const Center(
            child: Text('Tìm kiếm', style: TextStyle(fontSize: 24)));
      case 2:
        return const Center(
            child: Text('BookMark', style: TextStyle(fontSize: 24)));
      case 3:
        return AccountScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_mangas.isEmpty) {
      return const Center(child: Text('Không tìm thấy manga'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const CustomSearchBar(),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabItem(Icons.favorite_border, 'Favorites'),
                      const SizedBox(width: 12),
                      _buildTabItem(Icons.history, 'History'),
                      const SizedBox(width: 12),
                      _buildTabItem(Icons.bookmark_border, 'Following'),
                      const SizedBox(width: 12),
                      _buildTabItem(Icons.download_outlined, 'Downloads'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: PageView.builder(
              itemCount: _mangas.length.clamp(0, 3),
              itemBuilder: (context, index) {
                final manga = _mangas[index];
                return BannerWidget(
                  title: manga.name,
                  imageUrl:
                      'https://res.cloudinary.com/dbmua87fp/image/upload/manga/${manga.name}/cover.jpg',
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Manga của bạn',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Xem tất cả',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _mangas.length,
            itemBuilder: (context, index) {
              final manga = _mangas[index];
              return GestureDetector(
                onTap: () {
                  print('Manga được chọn: ${manga.name}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MangaDetailScreen(
                        mangaId: manga.name,
                      ),
                    ),
                  );
                },
                child: MangaGridItem(
                  title: manga.name,
                  chapter: manga.latestChapter.toString(),
                  imageUrl:
                      'https://res.cloudinary.com/dbmua87fp/image/upload/manga/${manga.name}/cover.jpg',
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
      bottomNavigationBar: NavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onNavBarTap,
      ),
    );
  }
}
