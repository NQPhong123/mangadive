import 'package:flutter/material.dart';
import 'package:mangadive/models/comment.dart';
import 'package:mangadive/models/reply.dart';
import 'package:mangadive/controllers/comment_controller.dart';

class CommentInput extends StatefulWidget {
  final String userId;
  final CommentSource source;
  final String? replyToCommentId;
  final ReplyTo? replyTo;
  final VoidCallback? onSubmitted;

  const CommentInput({
    Key? key,
    required this.userId,
    required this.source,
    this.replyToCommentId,
    this.replyTo,
    this.onSubmitted,
  }) : super(key: key);

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _textController = TextEditingController();
  final CommentController _commentController = CommentController();
  bool _isSpoiler = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    if (_textController.text.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      if (widget.replyToCommentId != null && widget.replyTo != null) {
        await _commentController.createReply(
          userId: widget.userId,
          commentId: widget.replyToCommentId!,
          content: _textController.text,
          replyTo: widget.replyTo!,
        );
      } else {
        await _commentController.createComment(
          userId: widget.userId,
          content: _textController.text,
          source: widget.source,
          isSpoiler: _isSpoiler,
        );
      }

      if (mounted) {
        _textController.clear();
        setState(() {
          _isSpoiler = false;
        });
        
        if (widget.onSubmitted != null) {
          widget.onSubmitted!();
        }
      }
    } catch (e) {
      print('Lỗi khi gửi comment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isSpoiler ? Icons.warning_amber_rounded : Icons.warning_amber_outlined,
              color: _isSpoiler ? Colors.orange : Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _isSpoiler = !_isSpoiler;
              });
            },
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: widget.replyToCommentId != null
                    ? 'Trả lời bình luận...'
                    : 'Viết bình luận...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              maxLines: null,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submitComment(),
            ),
          ),
          IconButton(
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            onPressed: _isSubmitting ? null : _submitComment,
          ),
        ],
      ),
    );
  }
} 