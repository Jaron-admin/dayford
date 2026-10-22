import 'package:dayford/app/diary_controller.dart';
import 'package:dayford/app/diary_screens.dart';
import 'package:dayford/data/diary_repository.dart';
import 'package:dayford/services/ai_service.dart';
import 'package:dayford/services/clock.dart';
import 'package:dayford/services/model_manager.dart';
import 'package:dayford/ui/theme/scope.dart';
import 'package:dayford/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  test('a reply for a day with no row is not dropped', () async {
    final repo = await DiaryRepository.open(inMemoryDatabasePath);
    await repo.saveAi('2026-10-20', '那天你写下了。', const ['做了饭'], DateTime(2026, 10, 20, 23));
    final entry = await repo.getEntry('2026-10-20');
    expect(entry?.aiReply, '那天你写下了。');
    await repo.close();
  });

  testWidgets('closing the response mid-stream still saves the reply', (
    tester,
  ) async {
    late DiaryRepository repo;
    late DiaryController controller;
    await tester.runAsync(() async {
      repo = await DiaryRepository.open(inMemoryDatabasePath);
      controller = DiaryController(
        repo: repo,
        clock: ManualClock(DateTime(2026, 10, 22, 12)),
        ai: FakeAiService(paced: true),
        models: FakeModelManager(autoProgress: false),
        brightness: Brightness.light,
      );
      await controller.init();
      controller.onTodayText('今天把书架整理了');
      await controller.finishToday();
    });

    await tester.pumpWidget(
      _host(
        ResponseScreen(
          controller: controller,
          quote: '今天把书架整理了',
          dateLine: '10月22日 · 周四',
          kind: ResponseKind.streaming,
          reduceMotion: false,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpWidget(_host(const SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 120));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );

    final entry = await tester.runAsync(() => repo.getEntry('2026-10-22'));
    expect(entry?.aiReply, isNotNull);
    expect(entry!.aiReply, isNotEmpty);
    await tester.runAsync(repo.close);
  });

  testWidgets('the sealed page shows the reply that was saved', (
    tester,
  ) async {
    late DiaryRepository repo;
    late DiaryController controller;
    await tester.runAsync(() async {
      repo = await DiaryRepository.open(inMemoryDatabasePath);
      controller = DiaryController(
        repo: repo,
        clock: ManualClock(DateTime(2026, 10, 22, 12)),
        ai: FakeAiService(),
        models: FakeModelManager(autoProgress: false),
        brightness: Brightness.light,
      );
      await controller.init();
      await repo.saveBody('2026-10-21', '今天把书架整理了', DateTime(2026, 10, 21, 22));
      await repo.saveAi(
        '2026-10-21',
        '你把今天写下了。',
        const ['今天把书架整理了'],
        DateTime(2026, 10, 21, 23),
      );
    });

    await tester.pumpWidget(
      _host(SealedScreen(controller: controller, dayKey: '2026-10-21')),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 150)),
    );
    await tester.pump();
    expect(find.textContaining('你把今天写下了。'), findsOneWidget);
    await tester.runAsync(repo.close);
  });
}

Widget _host(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(platform: TargetPlatform.android, useMaterial3: true),
    home: TokenScope(tokens: DayfordTokens.d, child: child),
  );
}
