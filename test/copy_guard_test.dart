import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('product copy stays inside the diary, not a scoreboard', () {
    const banned = ['打卡', '连续', '字数', '红点', '评分', '你应该', '建议你', '日记本'];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final hits = <String>[];
    for (final file in files) {
      final text = file.readAsStringSync();
      for (final word in banned) {
        if (text.contains(word)) hits.add('${file.path}: $word');
      }
    }
    expect(hits, isEmpty);
  });

  test('lib does not open a network client', () {
    const banned = [
      'package:http',
      'dart:io',
      'HttpClient',
      'WebSocket',
      'Socket(',
    ];
    final files = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'));
    final hits = <String>[];
    for (final file in files) {
      final text = file.readAsStringSync();
      for (final word in banned) {
        if (text.contains(word)) hits.add('${file.path}: $word');
      }
    }
    expect(hits, isEmpty);
  });
}
