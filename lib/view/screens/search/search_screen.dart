import 'package:flutter/material.dart';
import 'package:mangadive/view/widgets/common/search_bar.dart';
import 'package:mangadive/controllers/manga_controller.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';
import 'package:mangadive/view/widgets/manga/manga_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final MangaController _mangaController = MangaController();
  List<Manga> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm manga'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: CustomSearchBar(
              hintText: 'Nhập tên manga...',
              autoFocus: true,
              onSearch: (query) {
                _performSearch(query);
              },
            ),
          ),
          Expanded(
            child: _buildMangaList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMangaList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _hasSearched
                  ? 'Không tìm thấy kết quả'
                  : 'Tìm kiếm manga yêu thích của bạn',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final manga = _searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Image.network(
              manga.coverImage,
              width: 50,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 50,
                height: 70,
                color: Colors.grey[300],
                child: const Icon(Icons.broken_image, size: 24),
              ),
            ),
          ),
          title: Text(
            manga.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            '${manga.author} • ${manga.genres.join(", ")}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Text(
            'Ch. ${manga.lastChapterNumber}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MangaDetailScreen(mangaId: manga.id),
              ),
            );
          },
        );
      },
    );
  }

  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    try {
      final results = await _mangaController.searchMangas(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      print('Lỗi khi tìm kiếm: $e');
      setState(() {
        _searchResults = [];
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xảy ra lỗi khi tìm kiếm. Vui lòng thử lại.'),
        ),
      );
    }
  }
}
