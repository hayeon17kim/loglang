import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'diary_service.dart';
import 'diary_model.dart';
import 'package:loglang/src/diary/diary_detail_screen.dart';

class AddDiaryScreen extends StatefulWidget {
  static const routeName = '/diary/form'; // 라우트 네임 추가
  const AddDiaryScreen({super.key});

  @override
  AddDiaryScreenState createState() => AddDiaryScreenState();
}

class AddDiaryScreenState extends State<AddDiaryScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  final DiaryService _diaryService = DiaryService();
  String? _revisedContent;
  List<Map<String, dynamic>>? _changes;

  // Flask API에 요청을 보내서 수정된 일기를 받아오는 함수
  Future<void> _reviseDiary(String content) async {
    final url = Uri.parse('http://127.0.0.1:5000/diary'); // Flask API URL
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'content': content}),
      );

      // 서버로부터 정상 응답 받았을 때 처리
      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        // 1차 디코딩: 이스케이프된 문자열을 일반 문자열로 변환
        final String decodedString = jsonDecode(response.body);

        // 2차 디코딩: 다시 JSON 데이터로 파싱
        final Map<String, dynamic> data = jsonDecode(decodedString);

        print('Original: $content');
        print('Data: $data');

        // 'revised_sentence'가 있는지 먼저 확인하고 접근
        if (data.containsKey('revised_journal')) {
          print('Revised: ${data['revised_journal']}');
        } else {
          print('Error: revised_jouranl 키가 없습니다.');
        }

        // 'changes' 리스트가 존재하고 비어 있지 않은지 확인
        if (data.containsKey('changes') && data['changes'] is List) {
          final changes = List<Map<String, dynamic>>.from(data['changes']);
          if (changes.isNotEmpty) {
            print(
                'First Change: ${changes[0]['original']} -> ${changes[0]['revised']}');
            print('Reason: ${changes[0]['reason']}');
          } else {
            print('Error: changes 리스트가 비어 있습니다.');
          }

          // setState를 통해 수정된 데이터를 저장
          setState(() {
            _revisedContent = data['revised_journal'];
            _changes = changes; // List<Map<String, dynamic>> 형태로 저장
          });
        } else {
          print('Error: changes 리스트가 없습니다.');
        }
      } else {
        throw Exception('Failed to revise diary content');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _saveDiary() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      await _reviseDiary(_content);

      final newEntry = DiaryEntry(
        title: _title,
        content: _revisedContent ?? _content, // 수정된 내용을 사용
        date: DateTime.now(),
      );

      await _diaryService.addDiaryEntry(newEntry);

      if (mounted) {
        Navigator.pop(context, newEntry); // 이전 화면으로 돌아가기
        Navigator.pushNamed(
          context,
          DiaryDetailScreen.routeName,
          arguments: {
            'entry': newEntry,
            'changes': _changes ?? [], // API 리턴값에서 changes 가져오기
          },
        ); // Navigate to detail screen with changes
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Diary Entry'),
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
        ));
  }
}
