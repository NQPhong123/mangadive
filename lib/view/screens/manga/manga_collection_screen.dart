import 'package:flutter/material.dart';
import 'package:mangadive/view/screens/manga/manga_read_screen.dart';

class MangaCollectionScreen extends StatelessWidget {
  final String mangaId;

  const MangaCollectionScreen({
    super.key,
    required this.mangaId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Chapter'),
      ),
      body: ListView.builder(
        itemCount: 10, // Số chapter hiện có
        itemBuilder: (context, index) {
          final chapterNumber = index + 1;
          return ListTile(
            title: Text('Chapter $chapterNumber'),
            subtitle: Text('Ngày đăng: 30/03/2025'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${31} trang',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MangaReadScreen(
                    mangaId: mangaId,
                    chapterId: chapterNumber.toString(),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
