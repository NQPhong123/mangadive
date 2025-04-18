import 'package:flutter/material.dart';
import 'package:mangadive/models/post.dart';
import 'package:mangadive/models/comment.dart';
import 'package:mangadive/models/reply.dart';
import 'package:mangadive/controllers/post_controller.dart';
import 'package:mangadive/controllers/comment_controller.dart';
import 'package:mangadive/view/widgets/comment/comment_item.dart';
import 'package:mangadive/view/widgets/comment/comment_input.dart';
import 'package:mangadive/view/widgets/user/user_info.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDetailScreen extends StatefulWidget {
  final String postId;
  final String currentUserId;

  const PostDetailScreen({
    Key? key,
    required this.postId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final PostController _postController = PostController();
  final CommentController _commentController = CommentController();
  String? _replyingToCommentId;
  ReplyTo? _replyingTo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
      ),
      body: StreamBuilder<Post>(
        stream: _postController.getPost(widget.postId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final post = snapshot.data!;
          final source = CommentSource(postId: post.id);

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.title,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: UserInfo(
                                    userId: post.userId,
                                    avatarRadius: 16,
                                  ),
                                ),
                                Text(
                                  timeago.format(post.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(post.content),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite_border),
                                  onPressed: () {
                                    _postController.toggleLikePost(
                                      postId: post.id,
                                      userId: widget.currentUserId,
                                    );
                                  },
                                ),
                                Text('${post.likes}'),
                                const SizedBox(width: 16),
                                const Icon(Icons.comment),
                                const SizedBox(width: 4),
                                Text('${post.commentsCount}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      StreamBuilder<List<Comment>>(
                        stream: _commentController.getComments(source: source),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(child: Text('Lỗi: ${snapshot.error}'));
                          }

                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          final comments = snapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              return CommentItem(
                                comment: comment,
                                currentUserId: widget.currentUserId,
                                onReply: (commentId) {
                                  setState(() {
                                    _replyingToCommentId = commentId;
                                    _replyingTo = ReplyTo(
                                      id: commentId,
                                      userId: comment.userId,
                                    );
                                  });
                                },
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CommentInput(
                userId: widget.currentUserId,
                source: source,
                replyToCommentId: _replyingToCommentId,
                replyTo: _replyingTo,
                onSubmitted: () {
                  setState(() {
                    _replyingToCommentId = null;
                    _replyingTo = null;
                  });
                },
              ),
            ],
          );
        },
      ),
    );
  }
} 