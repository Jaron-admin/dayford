import 'package:flutter/material.dart';

import '../../constants/model_catalog.dart';
import '../../constants/sample_copy.dart';
import '../../services/model_manager.dart';
import '../pages/appearance_page.dart';
import '../pages/journal_pages.dart';
import '../pages/model_page.dart';
import '../theme/scope.dart';
import '../theme/tokens.dart';
import '../widgets/chrome.dart';

const kPreviewStates = [
  'welcome',
  'first-card',
  'today-empty',
  'today-typing',
  'ai-streaming',
  'ai-done',
  'ai-notready',
  'ai-unsupported',
  'sealed',
  'sealed-append',
  'history',
  'weekly',
  'model-pick',
  'model-cellular',
  'model-downloading',
  'model-paused',
  'model-failed',
  'model-storage',
  'model-ready',
  'model-unsupported',
  'settings',
  'appearance',
  'about',
];

const kExtraThemes = ['A', 'Bl', 'Bd', 'C'];
const kExtraStates = ['today-typing', 'ai-done', 'appearance'];

String statusTimeFor(String id) {
  if (id.startsWith('model')) return '20:16';
  return switch (id) {
    'settings' || 'appearance' || 'about' => '20:15',
    'history' => '21:28',
    'weekly' => '21:29',
    'sealed' => '21:30',
    'sealed-append' => '21:31',
    'welcome' => '22:38',
    _ => '22:41',
  };
}

ModelPhase phaseForState(String id) => switch (id) {
  'model-cellular' => ModelPhase.cellular,
  'model-downloading' || 'ai-notready' => ModelPhase.downloading,
  'model-paused' => ModelPhase.paused,
  'model-failed' => ModelPhase.failed,
  'model-storage' => ModelPhase.storage,
  'model-ready' || 'settings' => ModelPhase.ready,
  'model-unsupported' || 'ai-unsupported' => ModelPhase.unsupported,
  _ => ModelPhase.none,
};

String appearanceLineFor(ThemeId current) {
  final light = current.isLight ? current : ThemeId.d;
  final dark = current.isLight ? ThemeId.e : current;
  return '浅色时 ${light.displayName} · 深色时 ${dark.displayName}';
}

Widget buildPreviewPage(
  String id, {
  VoidCallback? onBack,
  VoidCallback? onDebug,
}) {
  final partial = SampleCopy.reply.substring(0, 31);
  return switch (id) {
    'welcome' => TodayView(
      dateLine: '10月22日 · 周四',
      title: '你好呀',
      hint: '这里是你的日济。不用写很多，\n一句话也算一篇。',
      privacy: '写下的字只存在这台手机里',
      placeholder: '就从现在这一刻开始吧…',
      text: '',
      onDebug: onDebug,
    ),
    'today-empty' => TodayView(
      dateLine: '10月22日 · 周四',
      title: '今天',
      hint: '写一句也算一篇。',
      placeholder: '今天怎么样？随便写一句就好。',
      text: '',
      onDebug: onDebug,
    ),
    'today-typing' => TodayView(
      dateLine: '10月22日 · 周四',
      title: '今天',
      hint: '写一句也算一篇。',
      placeholder: '今天怎么样？随便写一句就好。',
      text: SampleCopy.entry,
      onDebug: onDebug,
    ),
    'first-card' => ResponseView(
      dateLine: '10月22日 · 周四 · 22:43',
      quote: SampleCopy.firstEntry,
      kind: 'first-card',
    ),
    'ai-streaming' => ResponseView(
      dateLine: '10月22日 · 周四 · 22:43',
      quote: SampleCopy.entry,
      kind: 'ai-streaming',
      reply: partial,
    ),
    'ai-done' => ResponseView(
      dateLine: '10月22日 · 周四 · 22:43',
      quote: SampleCopy.entry,
      kind: 'ai-done',
      reply: SampleCopy.reply,
      done: SampleCopy.done,
    ),
    'ai-notready' => ResponseView(
      dateLine: '10月22日 · 周四 · 22:43',
      quote: SampleCopy.entry,
      kind: 'ai-notready',
      progress: 0.46,
    ),
    'ai-unsupported' => ResponseView(
      dateLine: '10月22日 · 周四 · 22:43',
      quote: SampleCopy.entry,
      kind: 'ai-unsupported',
    ),
    'sealed' => SealedView(
      yearWeek: '2026 · 周三',
      title: '10月21日',
      seal: '10月22日 04:00 已封存 · 原文不再改动',
      original: SampleCopy.oldEntry,
      appends: const [('补写于 10月22日 09:12', SampleCopy.oldAppend)],
      done: SampleCopy.oldDone,
      onBack: onBack,
    ),
    'sealed-append' => SealedView(
      yearWeek: '2026 · 周三',
      title: '10月21日',
      seal: '10月22日 04:00 已封存 · 原文不再改动',
      original: SampleCopy.oldEntry,
      appends: const [('补写于 10月22日 09:12', SampleCopy.oldAppend)],
      done: SampleCopy.oldDone,
      draftLabel: '补写于 10月22日 21:31 · 现在',
      draftText: SampleCopy.appendDraft,
      onBack: onBack,
    ),
    'history' => HistoryView(
      groups: [
        for (final group in SampleCopy.history)
          (
            group.$1,
            [for (final row in group.$2) (row.$1, row.$1, row.$2, row.$3)],
          ),
      ],
      onBack: onBack,
    ),
    'weekly' => WeeklyView(
      range: '10月19日 – 10月25日',
      thisWeek: true,
      reply: SampleCopy.weekReply,
      items: SampleCopy.weekItems,
      onBack: onBack,
    ),
    'settings' => SettingsView(
      appearanceLine: '浅色时 素白 · 深色时 墨夜',
      modelLine: modelStatusLine(ModelPhase.ready, 1, ModelCatalog.mid.id),
      onBack: onBack,
    ),
    'about' => AboutView(onBack: onBack),
    _ when id.startsWith('model') => ModelView(
      phase: phaseForState(id),
      onBack: onBack,
    ),
    _ => const SizedBox.shrink(),
  };
}

class StatePreview extends StatelessWidget {
  const StatePreview({
    super.key,
    required this.stateId,
    required this.themeId,
    this.chrome = true,
    this.onBack,
    this.onDebug,
  });

  final String stateId;
  final ThemeId themeId;
  final bool chrome;
  final VoidCallback? onBack;
  final VoidCallback? onDebug;

  @override
  Widget build(BuildContext context) {
    final tokens = DayfordTokens.of(themeId);
    final Widget page = switch (stateId) {
      'appearance' => AppearanceView(
        systemLight: themeId.isLight,
        lightId: themeId.isLight ? themeId : ThemeId.d,
        darkId: themeId.isLight ? ThemeId.e : themeId,
        onBack: onBack,
      ),
      'settings' => settingsForTheme(themeId, onBack: onBack),
      _ => buildPreviewPage(stateId, onBack: onBack, onDebug: onDebug),
    };
    final body = chrome
        ? PreviewChrome(
            time: statusTimeFor(stateId),
            cellular: stateId == 'model-cellular',
            child: page,
          )
        : page;
    return TokenScope(
      tokens: tokens,
      child: DefaultTextStyle(
        style: DayfordStyles(tokens).sans(size: 17, color: tokens.ink),
        child: body,
      ),
    );
  }
}

/// Settings copy depends on the active theme, so it is rebuilt here.
Widget settingsForTheme(ThemeId theme, {VoidCallback? onBack}) {
  return SettingsView(
    appearanceLine: appearanceLineFor(theme),
    modelLine: modelStatusLine(ModelPhase.ready, 1, ModelCatalog.mid.id),
    onBack: onBack,
  );
}
