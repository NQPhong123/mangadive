import 'package:flutter/material.dart';

class DiscussionSection extends StatelessWidget {
  const DiscussionSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildDiscussionCard(
          'One Piece Chapter 1085',
          'Bình luận về chapter mới nhất',
          'user123',
          '2 giờ trước',
          125,
        ),
        _buildDiscussionCard(
          'Jujutsu Kaisen Season 2',
          'Thảo luận về anime mới',
          'manga_fan',
          '5 giờ trước',
          89,
        ),
        _buildDiscussionCard(
          'Chainsaw Man Part 2',
          'Dự đoán về phần tiếp theo',
          'anime_lover',
          '1 ngày trước',
          67,
        ),
      ],
    );
  }

  Widget _buildDiscussionCard(
    String title,
    String content,
    String author,
    String time,
    int comments,
  ) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(title),
            subtitle: Text('Đăng bởi $author • $time'),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(content),
          ),
          ButtonBar(
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.comment),
                label: Text('$comments bình luận'),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.share),
                label: const Text('Chia sẻ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
} 