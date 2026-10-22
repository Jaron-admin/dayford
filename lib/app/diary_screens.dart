import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constants/model_catalog.dart';
import '../data/diary_repository.dart';
import '../domain/diary_day.dart';
import '../services/ai_service.dart';
import '../services/model_manager.dart';
import '../ui/pages/appearance_page.dart';
import '../ui/pages/journal_pages.dart';
import '../ui/pages/model_page.dart';
import '../ui/preview/state_catalog.dart';
import '../ui/theme/scope.dart';
import '../ui/widgets/chrome.dart';
import '../ui/widgets/delete_sheet.dart';
import 'dayford_route.dart';
import 'diary_controller.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final now = controller.clock.now();
    final day = DiaryDay.from(now);
    final welcome = controller.welcome;
    return TodayView(
      dateLine: formatDateLine(day.date),
      title: welcome ? '你好呀' : '今天',
      hint: welcome ? '这里是你的日济。不用写很多，\n一句话也算一篇。' : '写一句也算一篇。',
      privacy: welcome ? '写下的字只存在这台手机里' : null,
      placeholder: welcome ? '就从现在这一刻开始吧…' : '今天怎么样？随便写一句就好。',
      text: controller.todayText,
      interactive: true,
      onChanged: controller.onTodayText,
      onHistory: () => _push(context, HistoryScreen(controller: controller)),
      onSettings: () => _push(context, SettingsScreen(controller: controller)),
      onFinish: () => _finish(context),
      onDebug: kDebugMode
          ? () => _push(context, GalleryScreen(controller: controller))
          : null,
    );
  }

  Future<void> _finish(BuildContext context) async {
    final quote = controller.todayText;
    final now = controller.clock.now();
    final day = DiaryDay.from(now);
    final dateLine = formatDateLine(day.date, time: formatHm(now));
    final reduce = MediaQuery.disableAnimationsOf(context);
    final kind = await controller.finishToday();
    if (!context.mounted) return;
    await _push(
      context,
      ResponseScreen(
        controller: controller,
        quote: quote,
        dateLine: dateLine,
        kind: kind,
        reduceMotion: reduce,
      ),
    );
  }
}

class ResponseScreen extends StatefulWidget {
  const ResponseScreen({
    super.key,
    required this.controller,
    required this.quote,
    required this.dateLine,
    required this.kind,
    required this.reduceMotion,
  });

  final DiaryController controller;
  final String quote;
  final String dateLine;
  final ResponseKind kind;
  final bool reduceMotion;

  @override
  State<ResponseScreen> createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  late String _kind = _kindName(widget.kind);
  String _reply = '';
  List<String> _done = const [];
  bool _showCard = true;
  var _closed = false;

  @override
  void initState() {
    super.initState();
    if (widget.kind == ResponseKind.streaming) {
      _play();
    }
  }

  @override
  void dispose() {
    _closed = true;
    super.dispose();
  }

  Future<void> _play() async {
    final result = widget.controller.ai.respond(widget.quote);
    if (widget.reduceMotion) {
      if (!mounted) return;
      setState(() {
        _reply = result.reply;
        _done = result.done;
        _kind = 'ai-done';
      });
      await widget.controller.saveReply(result.reply, result.done);
      return;
    }
    await for (final partial in widget.controller.ai.streamReply(
      widget.quote,
    )) {
      if (!mounted || _closed) return;
      setState(() => _reply = partial);
    }
    await Future<void>.delayed(FakeAiService.settle);
    if (!mounted || _closed) return;
    setState(() {
      _reply = result.reply;
      _done = result.done;
      _kind = 'ai-done';
    });
    await widget.controller.saveReply(result.reply, result.done);
  }

  @override
  Widget build(BuildContext context) {
    final models = widget.controller.models;
    return ListenableBuilder(
      listenable: models,
      builder: (context, _) {
        return ResponseView(
          dateLine: widget.dateLine,
          quote: widget.quote,
          kind: _kind,
          reply: _reply,
          done: _done,
          progress: models.progress,
          showModelCard: _showCard,
          onDone: () => Navigator.of(context).pop(),
          onModels: () =>
              _push(context, ModelScreen(controller: widget.controller)),
          onWhy: () =>
              _push(context, ModelScreen(controller: widget.controller)),
          onLater: () async {
            await widget.controller.dismissModelCard();
            if (mounted) setState(() => _showCard = false);
          },
        );
      },
    );
  }
}

String _kindName(ResponseKind kind) => switch (kind) {
  ResponseKind.streaming => 'ai-streaming',
  ResponseKind.done => 'ai-done',
  ResponseKind.notReady => 'ai-notready',
  ResponseKind.unsupported => 'ai-unsupported',
  ResponseKind.firstCard => 'first-card',
};

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late final Future<List<StoredEntry>> _future = widget.controller
      .loadHistory();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<StoredEntry>>(
      future: _future,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <StoredEntry>[];
        final today = DiaryDay.from(widget.controller.clock.now());
        final groups = <(String, List<(String, String, String, String)>)>[];
        for (final entry in entries) {
          final day = DiaryDay.parse(entry.dayKey);
          final month = monthGroupLabel(day.date);
          final weekday = day == today ? '今天' : formatWeekday(day.date);
          final row = (
            entry.dayKey,
            formatMonthDay(day.date),
            weekday,
            entry.excerpt,
          );
          if (groups.isEmpty || groups.last.$1 != month) {
            groups.add((month, [row]));
          } else {
            groups.last.$2.add(row);
          }
        }
        return HistoryView(
          groups: groups,
          onBack: () => Navigator.of(context).pop(),
          onWeek: () =>
              _push(context, WeeklyScreen(controller: widget.controller)),
          onOpen: (id) => _push(
            context,
            SealedScreen(controller: widget.controller, dayKey: id),
          ),
        );
      },
    );
  }
}

class WeeklyScreen extends StatefulWidget {
  const WeeklyScreen({super.key, required this.controller, this.anchor});

  final DiaryController controller;
  final DateTime? anchor;

  @override
  State<WeeklyScreen> createState() => _WeeklyScreenState();
}

class _WeeklyScreenState extends State<WeeklyScreen> {
  late final DateTime _anchor = widget.anchor ?? widget.controller.clock.now();
  bool _thisWeek = true;
  late WeekSpan _span = _computeSpan();
  late Future<List<StoredEntry>> _future = _load();

  WeekSpan _computeSpan() {
    final base = weekContaining(_anchor);
    if (_thisWeek) return base;
    return weekContaining(base.start.subtract(const Duration(days: 1)));
  }

  Future<List<StoredEntry>> _load() {
    return widget.controller.repo.entriesBetween(
      DiaryDay(_span.start),
      DiaryDay(_span.end),
    );
  }

  void _selectWeek(bool value) {
    setState(() {
      _thisWeek = value;
      _span = _computeSpan();
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final span = _span;
    final ready = widget.controller.models.phase == ModelPhase.ready;
    return FutureBuilder<List<StoredEntry>>(
      future: _future,
      builder: (context, snapshot) {
        final entries = snapshot.data ?? const <StoredEntry>[];
        final counts = <String, int>{};
        for (final entry in entries) {
          for (final item in entry.aiDone) {
            counts[item] = (counts[item] ?? 0) + 1;
          }
        }
        final items = [
          for (final item in counts.entries) (item.key, '${item.value} 次'),
        ];
        final empty = entries.isEmpty;
        final String? reply;
        if (!ready || empty) {
          reply = null;
        } else if (items.isEmpty) {
          reply = '这一周你写下了几天。写下来的那些，都算数。';
        } else {
          final names = items.take(3).map((item) => item.$1).join('，');
          reply = '这一周你记下了这些：$names。这些都是真的做到了的事。';
        }
        final daysOnly = [
          for (final entry in entries)
            formatDateLine(DiaryDay.parse(entry.dayKey).date),
        ];
        return WeeklyView(
          range: '${formatMonthDay(span.start)} – ${formatMonthDay(span.end)}',
          thisWeek: _thisWeek,
          reply: reply,
          items: items,
          empty: empty,
          daysOnly: ready ? const [] : daysOnly,
          onBack: () => Navigator.of(context).pop(),
          onSelectWeek: _selectWeek,
        );
      },
    );
  }
}

class SealedScreen extends StatefulWidget {
  const SealedScreen({
    super.key,
    required this.controller,
    required this.dayKey,
    this.startEditing = false,
    this.navLabel = '历史',
    this.onBack,
  });

  final DiaryController controller;
  final String dayKey;
  final bool startEditing;
  final String navLabel;
  final VoidCallback? onBack;

  @override
  State<SealedScreen> createState() => _SealedScreenState();
}

class _SealedScreenState extends State<SealedScreen> {
  StoredEntry? _entry;
  var _loaded = false;
  late bool _editing = widget.startEditing;
  String _draft = '';
  late final String _draftLabel = formatAppendLabel(
    widget.controller.clock.now(),
    drafting: true,
  );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entry = await widget.controller.loadEntry(widget.dayKey);
    if (!mounted) return;
    setState(() {
      _entry = entry;
      _loaded = true;
    });
  }

  void _leave() {
    final back = widget.onBack;
    if (back != null) {
      back();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const PageFrame(child: SizedBox.expand());
    }
    final entry = _entry;
    final day = DiaryDay.parse(widget.dayKey);
    return SealedView(
      yearWeek: '${day.date.year} · ${formatWeekday(day.date)}',
      title: formatMonthDay(day.date),
      seal: formatSealLabel(day.sealAt),
      original: entry?.body ?? '',
      appends: [
        for (final append in entry?.appends ?? const <StoredAppend>[])
          (formatAppendLabel(append.savedAt), append.body),
      ],
      done: entry?.aiDone ?? const [],
      draftLabel: _editing ? _draftLabel : null,
      draftText: _draft,
      navLabel: widget.navLabel,
      onBack: _leave,
      onStartAppend: () => setState(() => _editing = true),
      onCancel: () => setState(() {
        _editing = false;
        _draft = '';
      }),
      onDraftChanged: (value) => setState(() => _draft = value),
      onSave: () async {
        final navigator = Navigator.of(context);
        final back = widget.onBack;
        await widget.controller.saveAppend(widget.dayKey, _draft);
        if (!mounted) return;
        if (back != null) {
          back();
          return;
        }
        navigator.pop();
      },
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final models = controller.models;
    return SettingsView(
      appearanceLine:
          '浅色时 ${controller.lightTheme.displayName} · 深色时 ${controller.darkTheme.displayName}',
      modelLine: modelStatusLine(
        models.phase,
        models.progress,
        models.activeModelId,
      ),
      onBack: () => Navigator.of(context).pop(),
      onAppearance: () =>
          _push(context, AppearanceScreen(controller: controller)),
      onModel: () => _push(context, ModelScreen(controller: controller)),
      onAbout: () =>
          _push(context, AboutView(onBack: () => Navigator.of(context).pop())),
    );
  }
}

class AppearanceScreen extends StatelessWidget {
  const AppearanceScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final light = controller.brightness == Brightness.light;
    return AppearanceView(
      systemLight: light,
      lightId: controller.lightTheme,
      darkId: controller.darkTheme,
      onBack: () => Navigator.of(context).pop(),
      onPick: (id) {
        if (id.isLight) {
          controller.setLight(id);
        } else {
          controller.setDark(id);
        }
      },
    );
  }
}

class ModelScreen extends StatelessWidget {
  const ModelScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final models = controller.models;
    return ListenableBuilder(
      listenable: models,
      builder: (context, _) {
        return ModelView(
          phase: models.phase,
          progress: models.progress,
          activeId: models.activeModelId ?? ModelCatalog.mid.id,
          onBack: () => Navigator.of(context).pop(),
          onDownload: models.startDownload,
          onPause: models.pause,
          onResume: models.resume,
          onRetry: models.retry,
          onCellular: models.allowCellularOnce,
          onDelete: () async {
            models.deleteActive();
          },
          onSwitch: (id) async {
            final name = ModelCatalog.byId(id).name;
            final ok = await confirmReplaceModel(context, modelName: name);
            if (!context.mounted || !ok) return;
            models.startDownload(id);
          },
        );
      },
    );
  }
}

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    final styles = DayfordStyles.of(context);
    final top = MediaQuery.viewPaddingOf(context).top;
    return PageFrame(
      child: ListView(
        padding: EdgeInsets.fromLTRB(26, top, 26, 42),
        children: [
          DayfordNav(label: '今天', onBack: () => Navigator.of(context).pop()),
          Text(
            '全部状态',
            style: styles.serif(size: 30, line: 40, weight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          for (final id in kPreviewStates)
            DayfordLink(
              label: id,
              onPressed: () {
                _push(
                  context,
                  StatePreview(
                    stateId: id,
                    themeId: controller.tokens.id,
                    onBack: () => Navigator.of(context).pop(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

Future<void> _push(BuildContext context, Widget page) {
  return Navigator.of(context)
      .push(DayfordPageRoute<void>(builder: (_) => page));
}
