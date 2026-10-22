import 'dart:io';

import 'package:dayford/app/diary_controller.dart';
import 'package:dayford/constants/model_catalog.dart';
import 'package:dayford/data/diary_repository.dart';
import 'package:dayford/domain/diary_day.dart';
import 'package:dayford/services/ai_service.dart';
import 'package:dayford/services/clock.dart';
import 'package:dayford/services/model_manager.dart';
import 'package:dayford/ui/theme/tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('03:59 belongs to the previous day and 04:00 opens the next', () {
    final before = DateTime(2026, 10, 22, 3, 59);
    final atBoundary = DateTime(2026, 10, 22, 4);
    expect(DiaryDay.from(before).key, '2026-10-21');
    expect(DiaryDay.from(atBoundary).key, '2026-10-22');
    expect(DiaryDay.parse('2026-10-21').sealAt, DateTime(2026, 10, 22, 4));
    expect(
      formatSealLabel(DateTime(2026, 10, 22, 4)),
      '10月22日 04:00 已封存 · 原文不再改动',
    );
  });

  test('append labels use an unpadded date and a padded clock', () {
    final saved = DateTime(2026, 10, 22, 9, 12);
    expect(formatAppendLabel(saved), '补写于 10月22日 09:12');
    expect(
      formatAppendLabel(DateTime(2026, 10, 22, 21, 31), drafting: true),
      '补写于 10月22日 21:31 · 现在',
    );
  });

  test('a week runs Monday through Sunday', () {
    final week = weekContaining(DateTime(2026, 10, 22));
    expect(week.start, DateTime(2026, 10, 19));
    expect(week.end, DateTime(2026, 10, 25));
  });

  test('recommendation follows the 6 GB floor', () {
    expect(ModelCatalog.recommendedId(3), isNull);
    expect(ModelCatalog.recommendedId(6), ModelCatalog.small.id);
    expect(ModelCatalog.recommendedId(7.5), ModelCatalog.small.id);
    expect(ModelCatalog.recommendedId(8), ModelCatalog.mid.id);
  });

  test('harsh diary text is answered without advice', () {
    final result = FakeAiService().respond('今天很失败，一事无成，什么都没做好。');
    expect(result.reply.contains('你应该'), isFalse);
    expect(result.reply.contains('建议'), isFalse);
    expect(result.done, isEmpty);
  });

  test('history skips days that are only whitespace', () async {
    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    final now = DateTime(2026, 10, 22, 21);
    await repo.saveBody('2026-10-20', '   \n', now);
    await repo.saveBody('2026-10-21', '写了一句', now);
    final keys = (await repo.history()).map((entry) => entry.dayKey);
    expect(keys, ['2026-10-21']);
    await repo.close();
  });

  test('debounced text survives a close and reopen', () async {
    final dir = await Directory.systemTemp.createTemp('dayford');
    final path = '${dir.path}/diary.db';
    final repo = await DiaryRepository.open(path);
    final clock = ManualClock(DateTime(2026, 10, 22, 21));
    final controller = DiaryController(
      repo: repo,
      clock: clock,
      ai: FakeAiService(),
      models: FakeModelManager(autoProgress: false),
      brightness: Brightness.light,
      saveDelay: const Duration(milliseconds: 30),
    );
    await controller.init();
    controller.onTodayText('杀进程前还在写');
    await Future<void>.delayed(const Duration(milliseconds: 80));
    await repo.close();

    final reopened = await DiaryRepository.open(path);
    final entry = await reopened.getEntry('2026-10-22');
    expect(entry?.body, '杀进程前还在写');
    await reopened.close();
    controller.dispose();
  });

  test('flush writes immediately, before the debounce elapses', () async {
    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    final controller = _controller(repo, DateTime(2026, 10, 22, 22));
    await controller.init();
    expect(controller.saveDelay, const Duration(milliseconds: 300));
    controller.onTodayText('立刻写下');
    await controller.flush();
    expect((await repo.getEntry('2026-10-22'))?.body, '立刻写下');
    controller.dispose();
    await repo.close();
  });

  test('crossing 04:00 seals the open day and keeps its text', () async {
    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    final clock = ManualClock(DateTime(2026, 10, 22, 3, 50));
    final controller = _controller(repo, clock.now(), clock: clock);
    await controller.init();
    expect(controller.editingDay?.key, '2026-10-21');
    controller.onTodayText('凌晨的字');
    await controller.flush();
    clock.set(DateTime(2026, 10, 22, 4, 1));
    await controller.checkBoundary();
    expect(controller.editingDay?.key, '2026-10-22');
    expect(controller.sealedFocus, '2026-10-21');
    expect(controller.appendComposer, isTrue);
    expect((await repo.getEntry('2026-10-21'))?.body, '凌晨的字');
    controller.dispose();
    await repo.close();
  });

  test('theme choice is kept and follows light or dark', () async {
    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    final controller = _controller(repo, DateTime(2026, 10, 22, 12));
    await controller.init();
    expect(controller.tokens.id, ThemeId.d);
    await controller.setLight(ThemeId.a);
    await controller.setDark(ThemeId.bd);
    expect(controller.tokens.id, ThemeId.a);
    controller.setBrightness(Brightness.dark);
    expect(controller.tokens.id, ThemeId.bd);
    controller.dispose();

    final again = _controller(repo, DateTime(2026, 10, 22, 12));
    await again.init();
    expect(again.lightTheme, ThemeId.a);
    expect(again.darkTheme, ThemeId.bd);
    again.setBrightness(Brightness.light);
    expect(again.tokens.id, ThemeId.a);
    again.dispose();
    await repo.close();
  });

  test('a day whose only content is an append still shows in history', () async {    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    await repo.saveAppend('2026-10-21', '凌晨补一句', DateTime(2026, 10, 22, 5));
    final entry = await repo.getEntry('2026-10-21');
    expect(entry, isNotNull);
    expect(entry!.appends.single.body, '凌晨补一句');
    expect(entry.hasContent, isTrue);
    expect((await repo.history()).map((item) => item.dayKey), contains('2026-10-21'));
    await repo.close();
  });

  test('typing across 04:00 is kept, then the day rolls over', () async {    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    final clock = ManualClock(DateTime(2026, 10, 22, 3, 59));
    final controller = _controller(repo, clock.now(), clock: clock);
    await controller.init();
    controller.onTodayText('凌晨写的');
    clock.set(DateTime(2026, 10, 22, 4, 0, 30));
    controller.onTodayText('凌晨写的，又补了一句');
    expect(controller.todayText, '凌晨写的，又补了一句');
    await controller.checkBoundary();
    expect((await repo.getEntry('2026-10-21'))?.body, '凌晨写的，又补了一句');
    expect(controller.editingDay?.key, '2026-10-22');
    expect(controller.todayText, '');
    expect(controller.sealedFocus, '2026-10-21');
    controller.dispose();
    await repo.close();
  });

  test('a sentence typed 350ms ago is already on disk', () async {    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    final controller = _controller(repo, DateTime(2026, 10, 22, 12));
    await controller.init();
    controller.onTodayText('刚写一半就被关了');
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final again = _controller(repo, DateTime(2026, 10, 22, 12));
    await again.init();
    expect(again.todayText, '刚写一半就被关了');
    again.dispose();
    controller.dispose();
    await repo.close();
  });

  test('appends are indexed by day', () async {
    final dir = await Directory.systemTemp.createTemp('dayford');
    final path = '${dir.path}/diary.db';
    final repo = await DiaryRepository.open(path);
    await repo.close();
    final raw = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    final indexes = await raw.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'index' AND name = 'idx_appends_day'",
    );
    await raw.close();
    expect(indexes, hasLength(1));
  });

  test('history keeps every append when there are many days', () async {
    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    for (var i = 1; i <= 40; i++) {
      final day = DiaryDay(DateTime(2026, 9, 1).add(Duration(days: i)));
      await repo.saveBody(day.key, '第 $i 天', DateTime(2026, 9, 1));
      await repo.saveAppend(day.key, '补一句 $i', DateTime(2026, 9, 2));
    }
    final all = await repo.history();
    expect(all, hasLength(40));
    expect(all.first.appends.single.body, '补一句 40');
    expect(all.last.appends.single.body, '补一句 1');
    await repo.close();
  });
}

DiaryController _controller(
  DiaryRepository repo,
  DateTime now, {
  ManualClock? clock,
}) {
  return DiaryController(
    repo: repo,
    clock: clock ?? ManualClock(now),
    ai: FakeAiService(),
    models: FakeModelManager(autoProgress: false),
    brightness: Brightness.light,
  );
}
