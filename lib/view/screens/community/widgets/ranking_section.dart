import 'package:flutter/material.dart';

class RankingSection extends StatelessWidget {
  const RankingSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _buildRankingCard(
          'Top truyện tuần',
          [
            {'title': 'One Piece', 'rank': 1, 'views': '1.2M'},
            {'title': 'Jujutsu Kaisen', 'rank': 2, 'views': '980K'},
            {'title': 'Chainsaw Man', 'rank': 3, 'views': '850K'},
          ],
        ),
        _buildRankingCard(
          'Top truyện tháng',
          [
            {'title': 'One Piece', 'rank': 1, 'views': '5.2M'},
            {'title': 'Jujutsu Kaisen', 'rank': 2, 'views': '4.8M'},
            {'title': 'Chainsaw Man', 'rank': 3, 'views': '4.5M'},
          ],
        ),
        _buildRankingCard(
          'Top truyện mới',
          [
            {'title': 'Blue Lock', 'rank': 1, 'views': '750K'},
            {'title': 'Solo Leveling', 'rank': 2, 'views': '680K'},
            {'title': 'Tokyo Revengers', 'rank': 3, 'views': '620K'},
          ],
        ),
      ],
    );
  }

  Widget _buildRankingCard(String title, List<Map<String, dynamic>> rankings) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...rankings.map((manga) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Text(
                    manga['rank'].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(manga['title']),
                trailing: Text('${manga['views']} lượt xem'),
              )),
        ],
      ),
    );
  }
} 