import 'package:flutter/material.dart';
import 'diary_model.dart';
import 'diary_service.dart';

class DiaryDetailScreen extends StatefulWidget {
  static const routeName = '/diary/detail';  // 라우트 네임 추가
  final DiaryEntry entry;
  const DiaryDetailScreen({super.key, required this.entry});

  @override
  DiaryDetailScreenState createState() => DiaryDetailScreenState();
}

class DiaryDetailScreenState extends State<DiaryDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _content;
  final DiaryService _diaryService = DiaryService();

  @override
  void initState() {
    super.initState();
    _title = widget.entry.title;
    _content = widget.entry.content;
  }

  void _updateDiary() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final updatedEntry = DiaryEntry(
        id: widget.entry.id,
        title: _title,
        content: _content,
        date: widget.entry.date,
      );

      await _diaryService.updateDiaryEntry(updatedEntry);

      if (mounted) {
        Navigator.pop(context, updatedEntry); // 이전 화면으로 돌아가기
      }
    }
  }

  void _deleteDiary() async {
    await _diaryService.deleteDiaryEntry(widget.entry.id!);
    if (mounted) {
      Navigator.pop(context); // 이전 화면으로 돌아가기
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Detail'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteDiary,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) => value!.isEmpty ? 'Please enter a title' : null,
              ),
              TextFormField(
                initialValue: _content,
                decoration: const InputDecoration(labelText: 'Content'),
                maxLines: 10,
                onSaved: (value) => _content = value!,
                validator: (value) => value!.isEmpty ? 'Please enter some content' : null,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateDiary,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
