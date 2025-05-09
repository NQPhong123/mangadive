import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mangadive/controllers/manga_controller.dart';
import 'package:mangadive/models/manga.dart';
import 'package:mangadive/models/follow.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangadive/routes/app_routes.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final MangaController _mangaController = MangaController();
  List<Manga> _followedMangas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFollowedMangas();
  }

  Future<void> _loadFollowedMangas() async {
    try {
      setState(() => _isLoading = true);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print('User chưa đăng nhập');
        setState(() {
          _followedMangas = [];
          _isLoading = false;
        });
        return;
      }

      print('Bắt đầu load follows cho user: ${user.uid}');
      final follows = await _mangaController.getUserFollows(user.uid);
      print('Số lượng follows: ${follows.length}');

      final mangaIds = follows.map((f) => f.mangaId).toList();
      print('Danh sách mangaId: $mangaIds');

      if (mangaIds.isEmpty) {
        print('Không có manga nào được follow');
        setState(() {
          _followedMangas = [];
          _isLoading = false;
        });
        return;
      }

      print('Bắt đầu load thông tin manga');
      final mangas = await Future.wait(
        mangaIds.map((id) => _mangaController.getManga(id)),
      );
      print('Đã load được ${mangas.length} manga');

      setState(() {
        _followedMangas = mangas.whereType<Manga>().toList();
        _isLoading = false;
      });
      print('Số lượng manga hiển thị: ${_followedMangas.length}');
    } catch (e) {
      print('Lỗi khi load followed mangas: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _followedMangas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.menu_book,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Bạn chưa theo dõi truyện nào',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context,
                            AppRoutes.mainScreen,
                          );
                        },
                        icon: const Icon(Icons.explore),
                        label: const Text('Khám phá truyện'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadFollowedMangas,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_followedMangas.length} truyện đã theo dõi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _loadFollowedMangas,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.all(8),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _followedMangas.length,
                          itemBuilder: (context, index) {
                            final manga = _followedMangas[index];
                            return _buildMangaCard(manga);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMangaCard(Manga manga) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.mangaDetail,
          arguments: {'mangaId': manga.id},
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: manga.coverImage,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${manga.totalFollowers} theo dõi',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
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
