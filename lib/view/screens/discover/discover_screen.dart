import 'package:flutter/material.dart';
import 'package:mangadive/view/widgets/common/search_bar.dart';
import 'package:mangadive/controllers/manga_controller.dart';
import 'package:mangadive/services/firebase_service.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/category.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';
import 'package:mangadive/view/screens/search/search_screen.dart';
import 'package:mangadive/view/widgets/manga/manga_card.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
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

      // Tải danh sách categories
      final categories = await _firebaseService.getAllCategories();

      print("Đã tải ${categories.length} thể loại");
      for (var cat in categories) {
        print("Thể loại: ${cat.name}, ID: ${cat.id}");
      }

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
        _filteredMangas = _allMangas;
      });
      return;
    }

    // Lấy danh sách tên thể loại từ ID đã chọn
    final selectedCategoryNames = _selectedCategoryIds
        .map((id) => _categories.firstWhere((cat) => cat.id == id,
        orElse: () => Category(
            id: '',
            name: '',
            description: '',
            mangaCount: 0,
            createdAt: DateTime.now()
        )).name)
        .where((name) => name.isNotEmpty)
        .toSet();

    setState(() {
      _filteredMangas = _allMangas.where((manga) {
        return selectedCategoryNames.every((categoryName) =>
            manga.genres.contains(categoryName));
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
                hintText: 'Khám phá manga mới...',
              ),
            ),

            // Categories filter section
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
              child: Text(
                'Thể loại (${_categories.length})',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Categories chips
            Container(
              height: 50,
              child: _isLoading
                  ? Center(child: CircularProgressIndicator(strokeWidth: 2))
                  : _categories.isEmpty
                  ? Center(child: Text("Không có thể loại nào"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategoryIds.contains(category.id);

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text('${category.name} (${category.mangaCount})'),
                      selected: isSelected,
                      selectedColor: Colors.blue.withOpacity(0.2),
                      checkmarkColor: Colors.blue,
                      onSelected: (_) {
                        _toggleCategory(category.id);
                      },
                    ),
                  );
                },
              ),
            ),

            // Results count
            if (!_isLoading)
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

            // Manga grid section
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredMangas.isEmpty
                  ? const Center(child: Text('Không tìm thấy manga phù hợp'))
                  : GridView.builder(
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
                          // Hiển thị dialog thông báo yêu cầu gói premium
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Nội dung Premium'),
                              content: Text('Bạn cần nâng cấp lên gói Premium để đọc manga này.'),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Đóng')
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Chuyển đến trang đăng ký premium
                                    // Navigator.push(context, MaterialPageRoute(builder: (_) => PremiumScreen()));
                                  },
                                  child: Text('Nâng cấp Premium'),
                                )
                              ],
                            ),
                          );
                          return;
                        }
                      }

                      // Nếu manga không premium hoặc user đã có premium
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
            ),
          ],
        ),
      ),
    );
  }
}