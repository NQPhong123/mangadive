import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:intl/intl.dart';
import 'package:mangadive/controllers/manga_controller.dart';
import 'package:mangadive/services/reading_history_service.dart';
import 'package:mangadive/view/screens/manga/manga_detail_screen.dart';

class ReadingHistoryScreen extends StatefulWidget {
  const ReadingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends State<ReadingHistoryScreen> {
  final ReadingHistoryService _historyService = ReadingHistoryService();
  final MangaController _mangaController = MangaController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _histories = [];

  @override
  void initState() {
    super.initState();
    _loadHistories();
  }

  Future<void> _loadHistories() async {
    setState(() => _isLoading = true);

    try {
      final histories = await _historyService.getReadingHistory();
      if (mounted) {
        setState(() {
          _histories = histories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tải lịch sử đọc: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDateTime(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử đọc truyện'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _histories.isEmpty
              ? const Center(child: Text('Bạn chưa đọc truyện nào'))
              : ListView.builder(
                  itemCount: _histories.length,
                  itemBuilder: (context, index) {
                    final history = _histories[index];
                    final mangaId = history['mangaId'] as String;
                    final lastReadChapter =
                        history['lastReadChapter'] as Map<String, dynamic>;
                    final chapterNumber = lastReadChapter['chapterNumber'];
                    final readAt = lastReadChapter['readAt'] as Timestamp;
                    final totalChapters = history['totalReadChapters'] as int;

                    return FutureBuilder(
                      future: _mangaController.getManga(mangaId),
                      builder: (context, snapshot) {
                        final mangaTitle = snapshot.hasData
                            ? snapshot.data!.title
                            : 'Đang tải...';

                        return ListTile(
                          leading: snapshot.hasData &&
                                  snapshot.data!.coverImage.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(
                                    snapshot.data!.coverImage,
                                    width: 50,
                                    height: 70,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(Icons.book, size: 40),
                          title: Text(mangaTitle),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Đọc đến: Chương $chapterNumber'),
                              Text(
                                'Đọc lúc: ${_formatDateTime(readAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                          trailing: Text(
                            '$totalChapters chương',
                            style: const TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            if (snapshot.hasData) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MangaDetailScreen(
                                    mangaId: mangaId,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadHistories,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
