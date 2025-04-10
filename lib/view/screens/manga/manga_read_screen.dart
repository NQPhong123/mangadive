import 'package:flutter/material.dart';
import 'package:mangadive/controllers/manga_controller.dart';
import 'package:mangadive/models/chapter.dart';
import 'package:mangadive/constants/app_constants.dart';
import 'package:mangadive/utils/string_utils.dart';
import 'package:mangadive/services/firebase_service.dart';

class MangaReadScreen extends StatefulWidget {
  final String mangaId;
  final String chapterId;

  const MangaReadScreen({
    super.key,
    required this.mangaId,
    required this.chapterId,
  });

  @override
  State<MangaReadScreen> createState() => _MangaReadScreenState();
}

class _MangaReadScreenState extends State<MangaReadScreen> {
  final MangaController _mangaController = MangaController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  List<String> _pages = [];
  int _currentPage = 0;
  List<Chapter> _chapters = [];
  String _currentChapterId = '';

  @override
  void initState() {
    super.initState();
    _currentChapterId = widget.chapterId;
    _loadMangaData();
    _loadChapters();
    _setupScrollListener();
    _incrementView();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.hasViewportDimension &&
          _pages.isNotEmpty) {
        final viewportHeight = _scrollController.position.viewportDimension;
        final currentScroll = _scrollController.offset;
        final newPage = (currentScroll / viewportHeight).floor();

        if (newPage != _currentPage) {
          setState(() => _currentPage = newPage.clamp(0, _pages.length - 1));
        }
      }
    });
  }

  Future<void> _loadMangaData() async {
    try {
      setState(() => _isLoading = true);

      final chapter =
          await _mangaController.getChapter(widget.mangaId, int.parse(_currentChapterId));

      if (chapter != null) {
        final List<String> pages =
            chapter.pages.map((page) => page.imageUrl).toList();

        if (mounted) {
          setState(() {
            _pages = pages;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(AppConstants.errorLoadingChapter);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadChapters() async {
    try {
      print('Đang tải danh sách chapter...');
      final chapters = await _mangaController.getChapters(widget.mangaId);
      print('Số lượng chapter: ${chapters.length}');
      if (mounted) {
        setState(() {
          _chapters = chapters;
        });
      }
    } catch (e) {
      print('Lỗi khi tải danh sách chapter: $e');
    }
  }

  Future<void> _incrementView() async {
    try {
      final firebaseService = FirebaseService();
      await firebaseService.incrementMangaView(widget.mangaId);
    } catch (e) {
      print('Lỗi khi tăng lượt xem: $e');
    }
  }

  void _navigateToChapter(String chapterId) {
    setState(() {
      _currentChapterId = chapterId;
      _isLoading = true;
      _pages = [];
    });
    _loadMangaData();
    _incrementView();
  }

  void _showChapterSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppConstants.chapterList,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _chapters.isEmpty
                  ? Center(child: Text(AppConstants.errorNoChapters))
                  : ListView.builder(
                      itemCount: _chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = _chapters[index];
                        return ListTile(
                          title: Text(StringUtils.getChapterTitle(
                              chapter.chapterNumber.toString())),
                          selected: chapter.id == _currentChapterId,
                          onTap: () {
                            Navigator.pop(context);
                            _navigateToChapter(chapter.id);
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _chapters.indexWhere((c) => c.id == _currentChapterId);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation bar
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    StringUtils.getChapterTitle(_currentChapterId),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return Image.network(
                          _pages[index],
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(AppConstants.errorLoadingImage),
                            );
                          },
                        );
                      },
                    ),
            ),

            // Bottom navigation bar
            Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: currentIndex > 0
                        ? () =>
                            _navigateToChapter(_chapters[currentIndex - 1].id)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: _showChapterSelection,
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios),
                    onPressed: currentIndex < _chapters.length - 1
                        ? () =>
                            _navigateToChapter(_chapters[currentIndex + 1].id)
                        : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment_outlined),
                    onPressed: null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
