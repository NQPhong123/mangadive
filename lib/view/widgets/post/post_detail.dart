import 'package:flutter/material.dart';
import 'package:mangadive/models/post.dart';
import 'package:mangadive/models/comment.dart';
import 'package:mangadive/controllers/post_controller.dart';
import 'package:mangadive/controllers/comment_controller.dart';
import 'package:mangadive/view/widgets/comment/comment_item.dart';
import 'package:mangadive/view/widgets/comment/comment_input.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mangadive/models/reply.dart';

class PostDetail extends StatefulWidget {
  final Post post;
  final String currentUserId;

  const PostDetail({
    Key? key,
    required this.post,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<PostDetail> createState() => _PostDetailState();
}

class _PostDetailState extends State<PostDetail> {
  final PostController _postController = PostController();
  final CommentController _commentController = CommentController();
  bool _isLiked = false;
  String? _replyingToCommentId;
  ReplyTo? _replyingTo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết bài viết'),
        actions: [
          if (widget.post.userId == widget.currentUserId)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _postController.deletePost(widget.post.id);
                Navigator.pop(context);
              },
            ),
        ],
      ),
      body: Column(
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
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 20,
                              child: Icon(Icons.person),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User ${widget.post.userId}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    timeago.format(widget.post.createdAt),
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
                        const SizedBox(height: 16),
                        Text(
                          widget.post.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.post.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (widget.post.tags.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: widget.post.tags.map((tag) {
                              return Chip(
                                label: Text(
                                  '#$tag',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _postController.toggleLikePost(
                                postId: widget.post.id,
                                userId: widget.currentUserId,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _isLiked ? Icons.favorite : Icons.favorite_border,
                                    size: 20,
                                    color: _isLiked ? Colors.red : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${widget.post.likes}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Row(
                              children: [
                                const Icon(
                                  Icons.comment_outlined,
                                  size: 20,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${widget.post.commentsCount}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Bình luận (${widget.post.commentsCount})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  StreamBuilder<List<Comment>>(
                    stream: _commentController.getComments(
                      source: CommentSource(
                        postId: widget.post.id,
                      ),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
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
            source: CommentSource(
              postId: widget.post.id,
            ),
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
      ),
    );
  }
} 