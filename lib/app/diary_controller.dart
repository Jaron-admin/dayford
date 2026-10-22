import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/diary_repository.dart';
import '../domain/diary_day.dart';
import '../services/ai_service.dart';
import '../services/clock.dart';
import '../services/model_manager.dart';
import '../ui/theme/tokens.dart';

enum ResponseKind { streaming, done, notReady, unsupported, firstCard }

class DiaryController extends ChangeNotifier {
  DiaryController({
    required this.repo,
    required this.clock,
    required this.ai,
    required this.models,
    required this.brightness,
    this.saveDelay = const Duration(milliseconds: 300),
    this.watchClock = false,
  });

  final DiaryRepository repo;
  final Clock clock;
  final AiService ai;
  final ModelManager models;
  final Duration saveDelay;
  final bool watchClock;

  Brightness brightness;
  ThemeId lightTheme = ThemeId.d;
  ThemeId darkTheme = ThemeId.e;
  bool welcome = true;
  bool cardDismissed = false;
  String todayText = '';
  bool loaded = false;
  DiaryDay? editingDay;
  bool appendComposer = false;

  /// Day key shown in place of today's editor after the 04:00 seal.
  String? sealedFocus;
  Timer? _saveTimer;
  Timer? _watchTimer;

  DayfordTokens get tokens =>
      DayfordTokens.of(brightness == Brightness.dark ? darkTheme : lightTheme);

  bool get todayIsSealed {
    final editing = editingDay;
    if (editing == null) return false;
    return editing.isBefore(DiaryDay.from(clock.now()));
  }

  bool get canFinish => todayText.trim().isNotEmpty && !todayIsSealed;

  Future<void> init() async {
    lightTheme =
        ThemeId.parse(await repo.getSetting('light_theme')) ?? ThemeId.d;
    darkTheme = ThemeId.parse(await repo.getSetting('dark_theme')) ?? ThemeId.e;
    welcome = (await repo.getSetting('welcome')) != '0';
    cardDismissed = (await repo.getSetting('model_card_dismissed')) == '1';
    final phaseName = await repo.getSetting('model_phase');
    final progress =
        double.tryParse(await repo.getSetting('model_progress') ?? '') ?? 0;
    final modelId = await repo.getSetting('model_id');
    if (models is FakeModelManager && phaseName != null) {
      final phase = ModelPhase.values.where((item) => item.name == phaseName);
      if (phase.isNotEmpty) {
        (models as FakeModelManager).restore(
          phase: phase.first,
          progress: progress,
          activeModelId: (modelId == null || modelId.isEmpty) ? null : modelId,
        );
      }
    }
    editingDay = DiaryDay.from(clock.now());
    final entry = await repo.getEntry(editingDay!.key);
    todayText = entry?.body ?? '';
    if ((await repo.history()).isNotEmpty) welcome = false;
    models.addListener(_onModel);
    loaded = true;
    notifyListeners();
    if (watchClock) {
      _watchTimer = Timer.periodic(const Duration(seconds: 20), (_) {
        checkBoundary();
      });
    }
  }

  void _onModel() {
    if (models is FakeModelManager) {
      repo.setSetting('model_phase', models.phase.name);
      repo.setSetting('model_progress', models.progress.toString());
      repo.setSetting('model_id', models.activeModelId ?? '');
    }
    notifyListeners();
  }

  void setBrightness(Brightness value) {
    if (brightness == value) return;
    brightness = value;
    notifyListeners();
  }

  Future<void> setLight(ThemeId id) async {
    lightTheme = id;
    await repo.setSetting('light_theme', id.wire);
    notifyListeners();
  }

  Future<void> setDark(ThemeId id) async {
    darkTheme = id;
    await repo.setSetting('dark_theme', id.wire);
    notifyListeners();
  }

  /// The open day stays writable until [checkBoundary] rolls it over. A sentence
  /// typed across 04:00 belongs to the day it started on, so refusing the input
  /// here would drop whatever the user wrote just before sleeping.
  void onTodayText(String value) {
    if (value == todayText) return;
    todayText = value;
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, flush);
    notifyListeners();
  }

  Future<void> flush() async {
    _saveTimer?.cancel();
    _saveTimer = null;
    final day = editingDay;
    if (day == null) return;
    final when = todayIsSealed
        ? day.sealAt.subtract(const Duration(minutes: 1))
        : clock.now();
    await repo.saveBody(day.key, todayText, when);
  }

  /// When the open day has crossed 04:00, keep its text and offer an append.
  Future<void> checkBoundary() async {
    final nowDay = DiaryDay.from(clock.now());
    final editing = editingDay;
    if (editing == null || !editing.isBefore(nowDay)) return;
    await flush();
    sealedFocus = editing.key;
    appendComposer = true;
    editingDay = nowDay;
    final entry = await repo.getEntry(nowDay.key);
    todayText = entry?.body ?? '';
    notifyListeners();
  }

  void leaveSealed() {
    appendComposer = false;
    sealedFocus = null;
    notifyListeners();
  }

  Future<ResponseKind> finishToday() async {
    await flush();
    final first = welcome;
    welcome = false;
    await repo.setSetting('welcome', '0');
    final phase = models.phase;
    final ResponseKind kind;
    if (first && phase == ModelPhase.unsupported) {
      kind = ResponseKind.unsupported;
    } else if (first && phase != ModelPhase.ready && !cardDismissed) {
      kind = ResponseKind.firstCard;
    } else if (phase == ModelPhase.unsupported) {
      kind = ResponseKind.unsupported;
    } else if (phase != ModelPhase.ready) {
      kind = ResponseKind.notReady;
    } else {
      kind = ResponseKind.streaming;
    }
    notifyListeners();
    return kind;
  }

  Future<void> dismissModelCard() async {
    cardDismissed = true;
    await repo.setSetting('model_card_dismissed', '1');
    notifyListeners();
  }

  Future<void> saveReply(String reply, List<String> done) async {
    final day = editingDay;
    if (day == null) return;
    await repo.saveAi(day.key, reply, done, clock.now());
  }

  Future<void> saveAppend(String dayKey, String text) async {
    final body = text.trim();
    if (body.isEmpty) return;
    await repo.saveAppend(dayKey, body, clock.now());
    appendComposer = false;
    sealedFocus = null;
    notifyListeners();
  }

  Future<List<StoredEntry>> loadHistory() => repo.history();

  Future<StoredEntry?> loadEntry(String dayKey) => repo.getEntry(dayKey);

  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveTimer = null;
    _watchTimer?.cancel();
    models.removeListener(_onModel);
    super.dispose();
  }
}
