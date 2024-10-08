import 'package:flutter/material.dart';
import 'diary_add.dart';
import 'diary_detail_screen.dart';
import 'diary_service.dart';
import 'diary_model.dart';

class DiaryListScreen extends StatefulWidget {
  static const routeName = '/diary'; // 라우트 네임 추가

  const DiaryListScreen({super.key});

  @override
  DiaryListScreenState createState() => DiaryListScreenState();
}

class DiaryListScreenState extends State<DiaryListScreen> {
  final DiaryService _diaryService = DiaryService();
  List<DiaryEntry> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadDiaryEntries();
  }

  void _loadDiaryEntries() async {
    final entries = await _diaryService.fetchAllEntries();
    setState(() {
      _entries = entries;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('로그랭'),
      ),
      body: ListView.builder(
        itemCount: _entries.length,
        itemBuilder: (context, index) {
          final entry = _entries[index];
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text(
                        '${entry.date.year}년 ${entry.date.month}월 ${entry.date.day}일'),
                    subtitle: Text(entry.content),
                    onTap: () {
                      Navigator.pushNamed(context, DiaryDetailScreen.routeName,
                              arguments: {'entry': entry, 'changes': []})
                          .then((updatedEntry) {
                        if (updatedEntry != null) {
                          // 수정된 항목을 리스트에서 반영
                          setState(() {
                            final index = _entries.indexWhere(
                                (e) => e.id == (updatedEntry as DiaryEntry).id);
                            if (index != -1) {
                              _entries[index] = updatedEntry as DiaryEntry;
                            }
                          });
                        }
                      });
                    },
                  )));
        },
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: FloatingActionButton(
          onPressed: () async {
            final newEntry =
                await Navigator.pushNamed(context, AddDiaryScreen.routeName);
            if (newEntry != null) {
              // 새로운 항목을 리스트에 추가
              setState(() {
                _entries.add(newEntry as DiaryEntry);
              });
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
