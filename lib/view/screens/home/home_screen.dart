import 'package:flutter/material.dart';
import 'package:mangadive/view/widgets/common/search_bar.dart';

import 'package:mangadive/view/widgets/home/banner_widget.dart';
import 'package:mangadive/view/widgets/manga/manga_card.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';
import 'package:mangadive/services/firebase_service.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/category.dart';

import 'package:mangadive/view/screens/search/search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = true;
  List<Manga> _allMangas = [];
  List<Manga> _filteredMangas = [];
  List<Category> _categories = [];
  Set<String> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Tải danh sách manga
      final mangas = await _firebaseService.getAllManga();
      print('Loaded mangas: ${mangas.length}'); // Debug print

      // Tải danh sách categories
      final categories = await _firebaseService.getAllCategories();
      print('Loaded categories: ${categories.length}'); // Debug print

      if (mounted) {
        setState(() {
          _allMangas = mangas;
          _filteredMangas = mangas;
          _categories = categories..sort((a, b) => a.name.compareTo(b.name));
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Lỗi khi tải dữ liệu: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterMangas() {
    if (_selectedCategoryIds.isEmpty) {
      setState(() {
        _filteredMangas = List.from(_allMangas); // Tạo bản sao của danh sách
      });
      return;
    }

    final selectedCategoryNames = _selectedCategoryIds
        .map((id) => _categories.firstWhere(
              (cat) => cat.id == id,
              orElse: () => Category(
                id: '',
                name: '',
                description: '',
                mangaCount: 0,
                createdAt: DateTime.now(),
              ),
            ).name)
        .where((name) => name.isNotEmpty)
        .toSet();

    setState(() {
      _filteredMangas = _allMangas.where((manga) {
        return selectedCategoryNames.every(
            (categoryName) => manga.genres.contains(categoryName));
      }).toList();
    });
  }

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategoryIds.contains(categoryId)) {
        _selectedCategoryIds.remove(categoryId);
      } else {
        _selectedCategoryIds.add(categoryId);
      }
      _filterMangas();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: CustomSearchBar(
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
                ),

                // Banner section
                if (_allMangas.isNotEmpty) // Chỉ hiển thị nếu có manga
                  SizedBox(
                    height: 180,
                    child: PageView.builder(
                      itemCount: _allMangas.length.clamp(0, 3),
                      itemBuilder: (context, index) {
                        final manga = _allMangas[index];
                        return BannerWidget(
                          title: manga.title,
                          imageUrl: manga.coverImage,
                        );
                      },
                    ),
                  ),

                const SizedBox(height: 16),

                // Categories filter section
                if (_categories.where((cat) => cat.mangaCount > 0).isNotEmpty) // Chỉ hiển thị nếu có categories có manga
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
                    child: Text(
                      'Thể loại (${_categories.where((cat) => cat.mangaCount > 0).length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                // Categories chips
                if (_categories.where((cat) => cat.mangaCount > 0).isNotEmpty) // Chỉ hiển thị nếu có categories có manga
                  Container(
                    height: 50,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categories.where((cat) => cat.mangaCount > 0).length,
                      itemBuilder: (context, index) {
                        final category = _categories
                            .where((cat) => cat.mangaCount > 0)
                            .toList()[index];
                        final isSelected = _selectedCategoryIds.contains(category.id);

                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: FilterChip(
                            label: Text('${category.name} (${category.mangaCount})'),
                            selected: isSelected,
                            selectedColor: Colors.blue.withOpacity(0.2),
                            checkmarkColor: Colors.blue,
                            onSelected: (_) => _toggleCategory(category.id),
                          ),
                        );
                      },
                    ),
                  ),

                // Results count and Manga grid
                if (_filteredMangas.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Tìm thấy ${_filteredMangas.length} kết quả',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.7,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _filteredMangas.length,
                    itemBuilder: (context, index) {
                      final manga = _filteredMangas[index];
                      return MangaCard(
                        manga: manga,
                        onTap: () async {
                          if (manga.isPremium) {
                            final isPremium = await _firebaseService.isUserPremium();
                            if (!isPremium) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Nội dung Premium'),
                                  content: const Text('Bạn cần nâng cấp lên gói Premium để đọc manga này.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Đóng'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                        // TODO: Navigate to premium screen
                                      },
                                      child: const Text('Nâng cấp Premium'),
                                    )
                                  ],
                                ),
                              );
                              return;
                            }
                          }

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
                ] else if (!_isLoading) ...[
                  // Hiển thị thông báo khi không có manga
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Không tìm thấy manga phù hợp',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 80),
              ],
            ),
          ),
      ),
    );
  }
}