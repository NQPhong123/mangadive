import 'package:flutter/material.dart';
import 'package:mangadive/view/widgets/home/search_bar.dart';
import 'package:mangadive/view/widgets/home/banner_widget.dart';
import 'package:mangadive/view/widgets/home/manga_card.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';
import 'package:mangadive/services/firebase_service.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/view/widgets/home/home_tab_item.dart';
import 'package:mangadive/view/screens/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  List<Manga> _mangas = [];

  @override
  void initState() {
    super.initState();
    _loadMangas();
  }

  Future<void> _loadMangas() async {
    setState(() => _isLoading = true);
    try {
      print('Đang tải manga...');
      final mangas = await _firebaseService.getAllManga();
      print('Đã tải xong manga: ${mangas.length} bộ');
      print('Manga đầu tiên: ${mangas.isNotEmpty ? mangas.first.title : 'không có'}');

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

  @override
  Widget build(BuildContext context) {
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
                CustomSearchBar(
                  onSearch: (query) {
                    if (query.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchScreen(),
                        ),
                      );
                    }
                  },
                  hintText: 'Tìm kiếm manga...',
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      HomeTabItem(icon: Icons.favorite_border, label: 'Favorites'),
                      const SizedBox(width: 12),
                      HomeTabItem(icon: Icons.history, label: 'History'),
                      const SizedBox(width: 12),
                      HomeTabItem(icon: Icons.bookmark_border, label: 'Following'),
                      const SizedBox(width: 12),
                      HomeTabItem(icon: Icons.download_outlined, label: 'Downloads'),
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
                  title: manga.title,
                  imageUrl: manga.coverImage,
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
              return MangaCard(
                manga: manga,
                onTap: () {
                  print('Manga được chọn: ${manga.title}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MangaDetailScreen(
                        mangaId: manga.id,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          // Thêm padding dưới cùng để tránh bị che bởi NavBar
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}