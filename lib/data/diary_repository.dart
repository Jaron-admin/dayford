import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../domain/diary_day.dart';

class StoredAppend {
  const StoredAppend({
    required this.id,
    required this.dayKey,
    required this.body,
    required this.savedAt,
  });

  final int id;
  final String dayKey;
  final String body;
  final DateTime savedAt;
}

class StoredEntry {
  const StoredEntry({
    required this.dayKey,
    required this.body,
    required this.updatedAt,
    required this.aiReply,
    required this.aiDone,
    required this.appends,
  });

  final String dayKey;
  final String body;
  final DateTime updatedAt;
  final String? aiReply;
  final List<String> aiDone;
  final List<StoredAppend> appends;

  bool get hasContent =>
      body.trim().isNotEmpty ||
      appends.any((item) => item.body.trim().isNotEmpty);

  String get excerpt {
    final line = firstLine(body);
    if (line.isNotEmpty) return line;
    for (final append in appends) {
      final text = firstLine(append.body);
      if (text.isNotEmpty) return text;
    }
    return '';
  }
}

class DiaryRepository {
  DiaryRepository._(this._db);

  final Database _db;

  static Future<DiaryRepository> open(String path) async {
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            day_key TEXT PRIMARY KEY,
            body TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            ai_reply TEXT,
            ai_done TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE appends (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            day_key TEXT NOT NULL,
            body TEXT NOT NULL,
            saved_at TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT NOT NULL
          )
        ''');
      },
    );
    return DiaryRepository._(db);
  }

  Future<void> close() => _db.close();

  Future<String?> getSetting(String key) async {
    final rows = await _db.query(
      'settings',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) {
    return _db.insert('settings', {
      'key': key,
      'value': value,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<StoredEntry?> getEntry(String dayKey) async {
    final rows = await _db.query(
      'entries',
      where: 'day_key = ?',
      whereArgs: [dayKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final appends = await _appends(dayKey);
    return _entryFrom(rows.first, appends);
  }

  Future<void> saveBody(String dayKey, String body, DateTime now) async {
    final existing = await getEntry(dayKey);
    if (existing == null && body.trim().isEmpty) return;
    if (existing == null) {
      await _db.insert('entries', {
        'day_key': dayKey,
        'body': body,
        'updated_at': now.toIso8601String(),
      });
      return;
    }
    await _db.update(
      'entries',
      {'body': body, 'updated_at': now.toIso8601String()},
      where: 'day_key = ?',
      whereArgs: [dayKey],
    );
  }

  Future<StoredAppend> saveAppend(
    String dayKey,
    String body,
    DateTime now,
  ) async {
    final existing = await getEntry(dayKey);
    if (existing == null) {
      await saveBody(dayKey, '', now);
    }
    final id = await _db.insert('appends', {
      'day_key': dayKey,
      'body': body,
      'saved_at': now.toIso8601String(),
    });
    return StoredAppend(id: id, dayKey: dayKey, body: body, savedAt: now);
  }

  Future<void> saveAi(String dayKey, String reply, List<String> done) {
    return _db.update(
      'entries',
      {'ai_reply': reply, 'ai_done': jsonEncode(done)},
      where: 'day_key = ?',
      whereArgs: [dayKey],
    );
  }

  Future<List<StoredEntry>> history() async {
    final rows = await _db.query('entries', orderBy: 'day_key DESC');
    final result = <StoredEntry>[];
    for (final row in rows) {
      final key = row['day_key'] as String;
      final entry = _entryFrom(row, await _appends(key));
      if (entry.hasContent) result.add(entry);
    }
    return result;
  }

  Future<List<StoredEntry>> entriesBetween(DiaryDay start, DiaryDay end) async {
    final all = await history();
    return all.where((entry) {
      final day = DiaryDay.parse(entry.dayKey);
      return !day.date.isBefore(start.date) && !day.date.isAfter(end.date);
    }).toList();
  }

  Future<List<StoredAppend>> _appends(String dayKey) async {
    final rows = await _db.query(
      'appends',
      where: 'day_key = ?',
      whereArgs: [dayKey],
      orderBy: 'id ASC',
    );
    return rows
        .map(
          (row) => StoredAppend(
            id: row['id'] as int,
            dayKey: row['day_key'] as String,
            body: row['body'] as String,
            savedAt: DateTime.parse(row['saved_at'] as String),
          ),
        )
        .toList();
  }

  StoredEntry _entryFrom(Map<String, Object?> row, List<StoredAppend> appends) {
    final rawDone = row['ai_done'] as String?;
    final done = rawDone == null
        ? const <String>[]
        : (jsonDecode(rawDone) as List).cast<String>();
    return StoredEntry(
      dayKey: row['day_key'] as String,
      body: row['body'] as String,
      updatedAt: DateTime.parse(row['updated_at'] as String),
      aiReply: row['ai_reply'] as String?,
      aiDone: done,
      appends: appends,
    );
  }
}
