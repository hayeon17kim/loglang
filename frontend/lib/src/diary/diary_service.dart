import 'package:loglang/src/db/diary_database.dart';
import 'diary_model.dart';

class DiaryService {
  static const String diaryKey = 'diary_entries';

  Future<int> addDiaryEntry(DiaryEntry entry) async {
    final db = await DiaryDatabase.instance.database;
    return await db.insert('diaries', entry.toMap());
  }

  Future<List<DiaryEntry>> fetchAllEntries() async {
    final db = await DiaryDatabase.instance.database;
    final result = await db.query('diaries');
    
    return result.map((json) => DiaryEntry.fromMap(json)).toList();
  } 

  Future<int> updateDiaryEntry(DiaryEntry entry) async {
    final db = await DiaryDatabase.instance.database;
    return await db.update('diaries', entry.toMap(), where: 'id = ?', whereArgs: [entry.id]);
  }

  Future<int> deleteDiaryEntry(int id) async {
    final db = await DiaryDatabase.instance.database;
    return await db.delete('diaries', where: 'id = ?', whereArgs: [id]);
  }
}
