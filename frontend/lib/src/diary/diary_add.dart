import 'package:flutter/material.dart';

import 'diary_service.dart';
import 'diary_model.dart';

class AddDiaryScreen extends StatefulWidget {
  static const routeName = '/diary/form';  // 라우트 네임 추가
  const AddDiaryScreen({super.key});

  @override
  AddDiaryScreenState createState() => AddDiaryScreenState();
}

class AddDiaryScreenState extends State<AddDiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  final DiaryService _diaryService = DiaryService();

  void _saveDiary() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newEntry = DiaryEntry(
        title: _title,
        content: _content,
        date: DateTime.now(),
      );

      await _diaryService.addDiaryEntry(newEntry);

      if (mounted) {
        Navigator.pop(context, newEntry); // 이전 화면으로 돌아가기
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Diary Entry'),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              onSaved: (value) => _title = value!,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Content'),
              onSaved: (value) => _content = value!,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter content';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _saveDiary,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    )
    );
  }
}