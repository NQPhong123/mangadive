import 'package:flutter/material.dart';
import 'package:mangadive/view/screens/community/widgets/ranking_section.dart';
import 'package:mangadive/view/screens/community/widgets/discussion_section.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cộng đồng'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Bảng xếp hạng'),
              Tab(text: 'Thảo luận'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RankingSection(),
            DiscussionSection(),
          ],
        ),
      ),
    );
  }
} 