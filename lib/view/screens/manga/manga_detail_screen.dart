import 'package:flutter/material.dart';
import 'package:mangadive/controllers/manga_controller.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/chapter.dart';
import 'package:mangadive/constants/app_constants.dart';
import 'package:mangadive/utils/string_utils.dart';
import 'package:mangadive/view/screens/manga/manga_read_screen.dart';
import 'package:mangadive/view/screens/manga/manga_collection_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MangaDetailScreen extends StatefulWidget {
  final String mangaId;

  const MangaDetailScreen({
    super.key,
    required this.mangaId,
  });

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  final MangaController _mangaController = MangaController();
  bool _isLoading = true;
  Manga? _manga;
  List<Chapter> _chapters = [];

  @override
  void initState() {
    super.initState();
    _loadMangaData();
  }

  Future<void> _loadMangaData() async {
    try {
      setState(() => _isLoading = true);
      print('Loading manga data with ID: ${widget.mangaId}');

      final manga = await _mangaController.getManga(widget.mangaId);
      final chapters = await _mangaController.getMangaChapters(widget.mangaId);

      print('Loaded manga: ${manga?.name}');
      print('Loaded chapters: ${chapters.length}');

      if (mounted) {
        setState(() {
          _manga = manga;
          _chapters = chapters;
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error loading manga data: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppConstants.errorLoadingManga)),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_manga == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(AppConstants.errorLoadingManga)),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: _manga!.coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  // TODO: Implement favorite functionality
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  // TODO: Implement share functionality
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _manga!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _manga!.description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        Icons.remove_red_eye,
                        StringUtils.formatNumber(_manga!.views),
                        'Lượt xem',
                      ),
                      _buildInfoItem(
                        Icons.favorite,
                        StringUtils.formatNumber(_manga!.follows),
                        'Theo dõi',
                      ),
                      _buildInfoItem(
                        Icons.star,
                        _manga!.voteScore.toStringAsFixed(1),
                        'Đánh giá',
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _chapters.isNotEmpty
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MangaReadScreen(
                                        mangaId: widget.mangaId,
                                        chapterId: _chapters.first.id,
                                      ),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('Đọc ngay'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Danh sách chapter',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_chapters.isEmpty)
                    const Center(
                      child: Text('Chưa có chapter nào'),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _chapters.length,
                      itemBuilder: (context, index) {
                        final chapter = _chapters[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(
                                  chapter.chapterNumber.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              StringUtils.getChapterTitle(
                                  chapter.chapterNumber.toString()),
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(
                              StringUtils.formatDate(chapter.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.remove_red_eye,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  StringUtils.formatNumber(chapter.views),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MangaReadScreen(
                                    mangaId: widget.mangaId,
                                    chapterId: chapter.id,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
