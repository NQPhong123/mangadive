import 'package:flutter/material.dart';
import 'package:mangadive/models/comment.dart';
import 'package:mangadive/models/reply.dart';
import 'package:mangadive/controllers/comment_controller.dart';
import 'package:mangadive/view/widgets/user/user_info.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:mangadive/view/widgets/comment/reply_item.dart';

class CommentItem extends StatefulWidget {
  final Comment comment;
  final String currentUserId;
  final Function(String) onReply;

  const CommentItem({
    Key? key,
    required this.comment,
    required this.currentUserId,
    required this.onReply,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  final CommentController _commentController = CommentController();
  bool _isLiked = false;
  bool _showReplies = false;
  bool _showSpoiler = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: UserInfo(
                  userId: widget.comment.userId,
                  avatarRadius: 16,
                ),
              ),
              Text(
                timeago.format(widget.comment.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (widget.comment.isSpoiler && !_showSpoiler)
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 16),
                  const SizedBox(width: 8),
                  const Text('Spoiler'),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _showSpoiler = true;
                      });
                    },
                    child: const Text('Hiện'),
                  ),
                ],
              ),
            )
          else
            Text(widget.comment.content),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () {
                  _commentController.toggleLikeComment(
                    commentId: widget.comment.id,
                    userId: widget.currentUserId,
                  );
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 16,
                      color: _isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.comment.likes}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () {
                  widget.onReply(widget.comment.id);
                },
                child: Row(
                  children: [
                    const Icon(
                      Icons.reply,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Trả lời',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              if (widget.comment.repliesCount > 0)
                InkWell(
                  onTap: () {
                    setState(() {
                      _showReplies = !_showReplies;
                    });
                  },
                  child: Row(
                    children: [
                      Icon(
                        _showReplies ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.comment.repliesCount} phản hồi',
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
          if (_showReplies && widget.comment.repliesCount > 0)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 8),
              child: StreamBuilder<List<Reply>>(
                stream: _commentController.getReplies(
                  commentId: widget.comment.id,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Lỗi: ${snapshot.error}');
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final replies = snapshot.data!;
                  return Column(
                    children: replies.map((reply) {
                      return ReplyItem(
                        reply: reply,
                        currentUserId: widget.currentUserId,
                        commentId: widget.comment.id,
                      );
                    }).toList(),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
} 