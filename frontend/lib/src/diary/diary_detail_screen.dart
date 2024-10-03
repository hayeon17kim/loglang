import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'diary_model.dart';
import 'diary_service.dart';

class DiaryDetailScreen extends StatefulWidget {
  static const routeName = '/diary/detail'; // 라우트 네임 추가
  final DiaryEntry entry;
  final List<Map<String, dynamic>> changes; // 수정된 내용과 이유 추가

  const DiaryDetailScreen({
    Key? key,
    required this.entry,
    required this.changes, // 변경사항 전달
  }) : super(key: key);

  @override
  DiaryDetailScreenState createState() => DiaryDetailScreenState();
}

class DiaryDetailScreenState extends State<DiaryDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController; // 탭 컨트롤러

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this); // 2개의 탭
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat('MMM dd, yyyy').format(widget.entry.date),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black, // 탭의 글자색 검정으로 설정
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black, // 탭 선택된 표시 검정
          tabs: const [
            Tab(text: "내가 쓴 것"), // 첫 번째 탭: 내가 쓴 것
            Tab(text: "수정한 것"), // 두 번째 탭: 수정한 것
          ],
          indicator: BoxDecoration(
            color: Colors.white, // 탭 배경 하얀색으로 설정
            border: Border(
              bottom: BorderSide(color: Colors.black, width: 2), // 아래쪽에 검정 밑줄
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // 일기 삭제 로직 추가
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOriginalJournal(), // 내가 쓴 것
          _buildRevisedJournal(), // 수정한 것
        ],
      ),
    );
  }

  // 내가 쓴 일기 표시하는 위젯
  Widget _buildOriginalJournal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0), // 넉넉한 패딩으로 공간 확보
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.entry.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20.0),
          Text(
            widget.entry.content,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // 수정된 일기 표시하는 위젯
  Widget _buildRevisedJournal() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.entry.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20.0),
          HighlightedTextWithReason(
            content: widget.entry.content,
            changes: widget.changes
                .map((change) =>
                    change.map((key, value) => MapEntry(key, value.toString())))
                .toList(),
          ), // 수정된 내용과 이유를 표시
        ],
      ),
    );
  }
}

class HighlightedTextWithReason extends StatelessWidget {
  final String content;
  final List<Map<String, String>> changes; // 'original', 'revised', 'reason'

  const HighlightedTextWithReason({
    Key? key,
    required this.content,
    required this.changes,
  }) : super(key: key);

  // 하이라이트 및 수정 이유를 포함한 텍스트 빌드 함수
  InlineSpan _buildHighlightedTextWithReason(BuildContext context) {
    List<InlineSpan> children = [];
    String content = this.content;
    int lastMatchEnd = 0;

    for (var change in changes) {
      String original = change['original']!;
      String revised = change['revised']!;

      int startIndex = content.indexOf(original, lastMatchEnd);

      if (startIndex == -1) continue;

      // 원본과 다른 경우에만 굵게 표시
      bool isDifferent = original != revised;

      if (isDifferent) {
        children.add(TextSpan(
          text: revised,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // 수정된 부분 굵게 표시
          ),
        ));
      } else {
        children.add(TextSpan(
          text: revised,
          style: const TextStyle(color: Colors.black),
        ));
      }

      // 수정 이유를 표시하는 아이콘 추가
      children.add(WidgetSpan(
        child: GestureDetector(
          onTap: () {
            _showReasonDialog(context, change['reason']);
          },
          child: const Icon(
            Icons.info_outline,
            size: 14,
            color: Colors.grey,
          ),
        ),
      ));

      lastMatchEnd = startIndex + original.length;
    }

    return TextSpan(children: children);
  }

  // 수정 이유 팝업 표시 함수
  void _showReasonDialog(BuildContext context, String? reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          backgroundColor: Colors.white.withOpacity(0.9),
          title: const Text('수정 이유'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reason ?? 'No reason provided'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: _buildHighlightedTextWithReason(context),
    );
  }
}
