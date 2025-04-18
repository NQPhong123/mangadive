import 'package:flutter/material.dart';
import 'package:mangadive/models/post.dart';
import 'package:mangadive/controllers/post_controller.dart';
import 'package:mangadive/view/widgets/post/post_item.dart';
import 'package:mangadive/view/screens/post/post_detail_screen.dart';
import 'package:mangadive/view/screens/post/create_post_screen.dart';
import 'package:mangadive/models/manga.dart';

class PostList extends StatefulWidget {
  final String currentUserId;
  final String? mangaId;
  final int? chapterNumber;

  const PostList({
    Key? key,
    required this.currentUserId,
    this.mangaId,
    this.chapterNumber,
  }) : super(key: key);

  @override
  State<PostList> createState() => _PostListState();
}

class _PostListState extends State<PostList> {
  final PostController _postController = PostController();
  final ScrollController _scrollController = ScrollController();
  String? _lastPostId;
  bool _hasMore = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  Future<void> _loadMorePosts() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);

    try {
      final posts = await _postController.getAllPosts(
        limit: 10,
        lastPostId: _lastPostId,
      ).first;

      if (mounted) {
        setState(() {
          _hasMore = posts.length == 10;
          if (posts.isNotEmpty) {
            _lastPostId = posts.last.id;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Post>>(
      stream: _postController.getAllPostsStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final posts = snapshot.data!;

        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.post_add,
                  size: 48,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  widget.mangaId != null
                      ? 'Chưa có bài viết nào về manga này'
                      : 'Chưa có bài viết nào',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePostScreen(
                          currentUserId: widget.currentUserId,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tạo bài viết mới'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: posts.length + 1,
                itemBuilder: (context, index) {
                  if (index == posts.length) {
                    return _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox.shrink();
                  }

                  final post = posts[index];
                  return PostItem(
                    post: post,
                    currentUserId: widget.currentUserId,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailScreen(
                            postId: post.id,
                            currentUserId: widget.currentUserId,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_hasMore && !_isLoading)
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _loadMorePosts,
                  child: const Text('Tải thêm'),
                ),
              ),
          ],
        );
      },
    );
  }
} 