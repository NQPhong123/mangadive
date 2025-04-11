import 'package:flutter/material.dart';
import 'package:mangadive/controllers/manga_controller.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/chapter.dart';
import 'package:mangadive/constants/app_constants.dart';
import 'package:mangadive/utils/string_utils.dart';
import 'package:mangadive/view/screens/manga/manga_read_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:mangadive/controllers/auth_controller.dart';
import 'package:mangadive/routes/app_routes.dart';

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
  bool _isFollowing = false;
  bool _isFollowingLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMangaData();
  }

  Future<void> _loadMangaData() async {
    try {
      setState(() => _isLoading = true);
      final manga = await _mangaController.getManga(widget.mangaId);
      final chapters = await _mangaController.getChapters(widget.mangaId);

      if (manga != null) {
        print('Loaded manga: ${manga.title}');
        if (mounted) {
          final filteredChapters = chapters.where((c) => c.chapterNumber > 0).toList();
          filteredChapters.sort((a, b) => a.chapterNumber.compareTo(b.chapterNumber));

          setState(() {
            _manga = manga;
            _chapters = filteredChapters;
            _isLoading = false;
          });
        }
      } else {
        throw Exception(AppConstants.errorLoadingManga);
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

  void _readManga(int chapterNumber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MangaReadScreen(
          mangaId: _manga!.id,
          chapterId: chapterNumber.toString(),
        ),
      ),
    );
  }

  void _toggleFollow() async {
    try {
      setState(() => _isFollowingLoading = true);
      final authController = Provider.of<AuthController>(context, listen: false);
      final userId = authController.currentUser?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để theo dõi truyện')),
        );
        return;
      }

      if (_isFollowing) {
        await _mangaController.unfollowManga(userId, _manga!.id);
      } else {
        await _mangaController.followManga(userId, _manga!.id);
      }

      setState(() {
        _isFollowing = !_isFollowing;
        _isFollowingLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
      setState(() => _isFollowingLoading = false);
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
              background: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: _manga!.coverImage,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Text(
                      _manga!.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 8,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
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
                    _manga!.title,
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
                  _buildStats(),
                  const SizedBox(height: 24),
                  _buildActions(),
                  const SizedBox(height: 24),
                  const Text(
                    'Thông tin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildInfo(),
                  const SizedBox(height: 24),
                  _buildDescription(),
                  const SizedBox(height: 24),
                  _buildChapterList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat(
            Icons.remove_red_eye,
            StringUtils.formatNumber(_manga!.totalViews),
            'Lượt xem',
          ),
          _buildStat(
            Icons.favorite,
            StringUtils.formatNumber(_manga!.totalFollowers),
            'Theo dõi',
          ),
          _buildStat(
            Icons.star,
            _manga!.averageRating.toStringAsFixed(1),
            'Đánh giá',
          ),
        ],
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                if (_chapters.isNotEmpty) {
                  _readManga(_chapters.first.chapterNumber);
                }
              },
              icon: const Icon(Icons.menu_book),
              label: Text(_chapters.isNotEmpty
                  ? AppConstants.readFromStart
                  : AppConstants.noImage),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isFollowingLoading ? null : _toggleFollow,
            icon: _isFollowingLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    _isFollowing ? Icons.favorite : Icons.favorite_border,
                    color: _isFollowing ? Colors.red : null,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Tác giả', _manga!.author),
          const Divider(),
          _buildInfoRow('Họa sĩ', _manga!.artist),
          const Divider(),
          _buildInfoRow('Trạng thái', _formatStatus(_manga!.status)),
          const Divider(),
          _buildInfoRow('Thể loại', _manga!.genres.join(', ')),
        ],
      ),
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'ongoing':
        return 'Đang tiến hành';
      case 'completed':
        return 'Hoàn thành';
      case 'hiatus':
        return 'Tạm ngưng';
      default:
        return status;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mô tả',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(_manga!.description),
        ],
      ),
    );
  }

  Widget _buildChapterList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Danh sách Chapter',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text('${_chapters.length} chapter'),
            ],
          ),
          const SizedBox(height: 12),
          ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: _chapters.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final chapter = _chapters[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  StringUtils.getChapterTitle(chapter.chapterNumber.toString()),
                ),
                onTap: () => _readManga(chapter.chapterNumber),
              );
            },
          ),
        ],
      ),
    );
  }
}
