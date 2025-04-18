import 'package:flutter/material.dart';
import 'package:mangadive/models/reply.dart';
import 'package:mangadive/controllers/comment_controller.dart';
import 'package:mangadive/view/widgets/user/user_info.dart';
import 'package:timeago/timeago.dart' as timeago;

class ReplyItem extends StatefulWidget {
  final Reply reply;
  final String currentUserId;
  final String commentId;

  const ReplyItem({
    Key? key,
    required this.reply,
    required this.currentUserId,
    required this.commentId,
  }) : super(key: key);

  @override
  State<ReplyItem> createState() => _ReplyItemState();
}

class _ReplyItemState extends State<ReplyItem> {
  final CommentController _commentController = CommentController();
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 32),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: UserInfo(
                  userId: widget.reply.userId,
                  avatarRadius: 12,
                  usernameStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                timeago.format(widget.reply.createdAt),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.reply.content,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              InkWell(
                onTap: () {
                  _commentController.toggleLikeReply(
                    commentId: widget.commentId,
                    replyId: widget.reply.id,
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
                      size: 12,
                      color: _isLiked ? Colors.red : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.reply.likes}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.reply.mentions.isNotEmpty) ...[
                const SizedBox(width: 16),
                Text(
                  '${widget.reply.mentions.length} người được đề cập',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
} 