class DiaryEntry {
  final int? id;
  final String title;
  final String content;
  final DateTime date;

  DiaryEntry({
    this.id,
    required this.title,
    required this.content,
    required this.date,
  });

  // 일기 데이터를 JSON으로 변환
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
    };
  }

  // Map으로부터 DiaryEntry 객체 생성
  factory DiaryEntry.fromMap(Map<String, dynamic> map) {
    return DiaryEntry(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      date: DateTime.parse(map['date']),
    );
  }
}
