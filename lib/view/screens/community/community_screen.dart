import 'package:flutter/material.dart';
import 'package:mangadive/view/screens/community/widgets/ranking_section.dart';
import 'package:mangadive/view/widgets/post/post_list.dart';
import 'package:mangadive/view/screens/post/create_post_screen.dart';

class CommunityScreen extends StatelessWidget {
  final String currentUserId;

  const CommunityScreen({
    Key? key,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cộng đồng'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bảng xếp hạng'),
              Tab(text: 'Bài viết'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostScreen(
                      currentUserId: currentUserId,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            const RankingSection(),
            PostList(currentUserId: currentUserId),
          ],
        ),
      ),
    );
  }
} 