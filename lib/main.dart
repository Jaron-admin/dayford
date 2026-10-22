import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app/dayford_app.dart';
import 'app/diary_controller.dart';
import 'data/diary_repository.dart';
import 'services/ai_service.dart';
import 'services/clock.dart';
import 'services/model_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final dir = await getApplicationDocumentsDirectory();
  final repo = await DiaryRepository.open(p.join(dir.path, 'dayford.db'));
  final controller = DiaryController(
    repo: repo,
    clock: const SystemClock(),
    ai: FakeAiService(paced: true),
    models: FakeModelManager(),
    brightness: WidgetsBinding.instance.platformDispatcher.platformBrightness,
    watchClock: true,
  );
  await controller.init();
  runApp(DayfordApp(controller: controller));
}
