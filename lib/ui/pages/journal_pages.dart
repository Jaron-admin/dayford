import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme/scope.dart';
import '../widgets/chrome.dart';

class TodayView extends StatelessWidget {
  const TodayView({
    super.key,
    required this.dateLine,
    required this.title,
    required this.hint,
    required this.placeholder,
    required this.text,
    this.privacy,
    this.interactive = false,
    this.autofocus = false,
    this.onChanged,
    this.onHistory,
    this.onSettings,
    this.onFinish,
    this.onDebug,
  });

  final String dateLine;
  final String title;
  final String hint;
  final String placeholder;
  final String text;
  final String? privacy;
  final bool interactive;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onHistory;
  final VoidCallback? onSettings;
  final VoidCallback? onFinish;
  final VoidCallback? onDebug;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final top = MediaQuery.viewPaddingOf(context).top;
    final enabled = text.trim().isNotEmpty;
    return PageFrame(
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(26, top + 18, 26, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onLongPress: onDebug,
                          child: Text(
                            dateLine,
                            style: styles.sans(
                              size: 13,
                              color: tokens.ink3,
                              letterSpacing: 13 * 0.06,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          title,
                          style: styles.serif(
                            size: 30,
                            line: 40,
                            weight: FontWeight.w600,
                            letterSpacing: 30 * 0.02,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          hint,
                          style: styles.sans(
                            size: 15,
                            line: 24,
                            color: tokens.ink2,
                          ),
                        ),
                        if (privacy != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                DayIcon(
                                  'lock',
                                  size: 14,
                                  stroke: 1.8,
                                  color: tokens.ink3,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  privacy!,
                                  style: styles.sans(
                                    size: 13,
                                    color: tokens.ink3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const RuleLine(),
                        SizedBox(height: tokens.showRule ? 10 : 22),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(26, 0, 26, 28),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: LinedPaper(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: interactive
                            ? _LiveEditor(
                                text: text,
                                placeholder: placeholder,
                                autofocus: autofocus,
                                onChanged: onChanged,
                              )
                            : _FrozenEditor(
                                text: text,
                                placeholder: placeholder,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(26, 12, 26, barBottomPad(context)),
            child: Row(
              children: [
                RoundIconButton(
                  icon: 'book',
                  label: '历史',
                  onPressed: onHistory,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DayfordButton(
                    key: const Key('finish-button'),
                    label: '写好了',
                    serif: true,
                    enabled: enabled,
                    onPressed: onFinish,
                  ),
                ),
                const SizedBox(width: 12),
                RoundIconButton(
                  icon: 'gear',
                  label: '设置',
                  onPressed: onSettings,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FrozenEditor extends StatelessWidget {
  const _FrozenEditor({required this.text, required this.placeholder});

  final String text;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final body = styles.serif(size: 18, line: 34);
    final caret = CaretMark(color: tokens.accent);
    if (text.isEmpty) {
      return Text.rich(
        TextSpan(
          children: [
            WidgetSpan(alignment: PlaceholderAlignment.middle, child: caret),
            TextSpan(
              text: placeholder,
              style: body.copyWith(color: tokens.ink3),
            ),
          ],
        ),
      );
    }
    return Text.rich(
      TextSpan(
        style: body,
        children: [
          TextSpan(text: text),
          WidgetSpan(alignment: PlaceholderAlignment.middle, child: caret),
        ],
      ),
    );
  }
}

class _LiveEditor extends StatefulWidget {
  const _LiveEditor({
    required this.text,
    required this.placeholder,
    required this.autofocus,
    required this.onChanged,
  });

  final String text;
  final String placeholder;
  final bool autofocus;
  final ValueChanged<String>? onChanged;

  @override
  State<_LiveEditor> createState() => _LiveEditorState();
}

class _LiveEditorState extends State<_LiveEditor> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

  @override
  void didUpdateWidget(_LiveEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != _controller.text && widget.text != oldWidget.text) {
      _controller.value = TextEditingValue(
        text: widget.text,
        selection: TextSelection.collapsed(offset: widget.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return TextField(
      key: const Key('today-field'),
      controller: _controller,
      autofocus: widget.autofocus,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      maxLines: null,
      minLines: 4,
      cursorColor: tokens.accent,
      cursorWidth: 2,
      style: styles.serif(size: 18, line: 34),
      decoration: InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
        hintText: widget.placeholder,
        hintStyle: styles.serif(size: 18, line: 34, color: tokens.ink3),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class ResponseView extends StatelessWidget {
  const ResponseView({
    super.key,
    required this.dateLine,
    required this.quote,
    required this.kind,
    this.reply = '',
    this.done = const [],
    this.progress = 0.46,
    this.showModelCard = true,
    this.onDone,
    this.onModels,
    this.onLater,
    this.onWhy,
  });

  final String dateLine;
  final String quote;
  final String kind;
  final String reply;
  final List<String> done;
  final double progress;
  final bool showModelCard;
  final VoidCallback? onDone;
  final VoidCallback? onModels;
  final VoidCallback? onLater;
  final VoidCallback? onWhy;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final top = MediaQuery.viewPaddingOf(context).top;
    final streaming = kind == 'ai-streaming';
    return PageFrame(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(26, top, 26, 42),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - top,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 24,
                    child: Row(
                      children: [
                        Text(
                          dateLine,
                          style: styles.sans(
                            size: 13,
                            color: tokens.ink3,
                            letterSpacing: 13 * 0.06,
                          ),
                        ),
                        const Spacer(),
                        DayfordLink(
                          label: '完成',
                          size: 17,
                          weight: FontWeight.w600,
                          onPressed: onDone,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  DecoratedBox(
                    decoration: tokens.cardBox(radius: 18),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      child: Text(
                        quote,
                        style: styles.serif(
                          size: 15,
                          line: 26,
                          color: tokens.ink2,
                        ),
                      ),
                    ),
                  ),
                  if (kind == 'ai-streaming' || kind == 'ai-done') ...[
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Orb(breath: streaming),
                        const SizedBox(width: 8),
                        Text(
                          streaming ? '正在慢慢读你写的…' : '今天的回应',
                          style: styles.sans(
                            size: 13,
                            line: 20,
                            color: tokens.ink3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(reply, style: styles.serif(size: 17, line: 31)),
                    if (!streaming) ...[
                      const SizedBox(height: 22),
                      _DoneCard(title: '今天其实做完了', items: done),
                    ],
                  ],
                  if (kind == 'ai-notready' || kind == 'ai-unsupported') ...[
                    const SizedBox(height: 14),
                    _SavedLine(
                      kind == 'ai-notready' || kind == 'ai-unsupported'
                          ? '日记已经好好存下了'
                          : '第一篇存好了',
                    ),
                    const SizedBox(height: 22),
                    if (kind == 'ai-notready')
                      _StatusCard(
                        title: '模型准备好后，我会回应你',
                        body: '它还在下载。等它好了，我会回来读这一篇，不用你再做什么。',
                        dim: true,
                        progress: progress,
                        progressLabel: '下载中 · ${(progress * 100).round()}%',
                      )
                    else
                      _StatusCard(
                        title: '这一次，就由你自己收好它',
                        body: '这台手机暂时跑不动本机 AI，所以没有回应。但写下来这件事，本身就已经很好了。',
                        dim: true,
                      ),
                    const SizedBox(height: 14),
                    DayfordLink(
                      label: kind == 'ai-notready' ? '看看模型 ' : '为什么用不了 ',
                      chevron: true,
                      onPressed: kind == 'ai-notready' ? onModels : onWhy,
                    ),
                  ],
                  if (kind == 'first-card') ...[
                    const SizedBox(height: 14),
                    const _SavedLine('第一篇存好了'),
                    if (showModelCard) ...[
                      const SizedBox(height: 22),
                      _StatusCard(
                        title: '读完之后，想听我说几句吗？',
                        body: '需要先下载一个小模型。它只在这台手机里运行，你写的字不会离开这里。',
                        breath: true,
                        extra: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Text(
                              '这台 iPhone 15 Pro 推荐「均衡」· 1.1 GB',
                              style: styles.sans(
                                size: 13,
                                line: 19,
                                color: tokens.ink2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: DayfordButton(
                                    label: '去看看',
                                    small: true,
                                    onPressed: onModels,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: DayfordButton(
                                    label: '以后再说',
                                    small: true,
                                    ghost: true,
                                    onPressed: onLater,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                  if (kind != 'first-card' || showModelCard) ...[
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        kind == 'first-card'
                            ? '不下载也没关系，日记照样能写。\n之后可以在「设置 › AI 模型」里找到它。'
                            : '这一篇凌晨 4 点后会封存，之后还能往下补写',
                        textAlign: TextAlign.center,
                        style: styles.sans(
                          size: 13,
                          line: 20,
                          color: tokens.ink3,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SavedLine extends StatelessWidget {
  const _SavedLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return Row(
      children: [
        DayIcon('check', size: 16, stroke: 2, color: tokens.accentText),
        const SizedBox(width: 6),
        Text(text, style: styles.sans(size: 13, color: tokens.ink2)),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({
    required this.title,
    required this.body,
    this.dim = false,
    this.breath = false,
    this.progress,
    this.progressLabel,
    this.extra,
  });

  final String title;
  final String body;
  final bool dim;
  final bool breath;
  final double? progress;
  final String? progressLabel;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return DayfordCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Orb(size: 40, dim: dim, breath: breath),
          const SizedBox(height: 14),
          Text(
            title,
            style: styles.serif(size: 18, line: 30, weight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: styles.sans(size: 15, line: 24, color: tokens.ink2),
          ),
          if (progress != null) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ProgressTrack(value: progress!)),
                const SizedBox(width: 10),
                Text(
                  progressLabel ?? '',
                  style: styles.sans(size: 13, color: tokens.ink2),
                ),
              ],
            ),
          ],
          ?extra,
        ],
      ),
    );
  }
}

class _DoneCard extends StatelessWidget {
  const _DoneCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return DayfordCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: styles.serif(size: 15, weight: FontWeight.w600),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < items.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                border: i == 0
                    ? null
                    : Border(top: BorderSide(color: tokens.line)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7),
                    child: DoneDot(index: i),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      items[i],
                      style: styles.serif(size: 16, line: 24),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class SealedView extends StatelessWidget {
  const SealedView({
    super.key,
    required this.yearWeek,
    required this.title,
    required this.seal,
    required this.original,
    required this.appends,
    required this.done,
    this.reply = '',
    this.draftLabel,
    this.draftText,
    this.navLabel = '历史',
    this.onBack,
    this.onStartAppend,
    this.onCancel,
    this.onSave,
    this.onDraftChanged,
  });

  final String yearWeek;
  final String title;
  final String seal;
  final String original;
  final List<(String, String)> appends;
  final List<String> done;
  final String reply;
  final String? draftLabel;
  final String? draftText;
  final String navLabel;
  final VoidCallback? onBack;
  final VoidCallback? onStartAppend;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final ValueChanged<String>? onDraftChanged;

  bool get editing => draftLabel != null;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final top = MediaQuery.viewPaddingOf(context).top;
    return PageFrame(
      child: BackEdge(
        onBack: onBack,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(26, top, 26, 28),
                children: [
                  DayfordNav(label: navLabel, onBack: onBack),
                  const SizedBox(height: 4),
                  Text(
                    yearWeek,
                    style: styles.sans(
                      size: 13,
                      color: tokens.ink3,
                      letterSpacing: 13 * 0.06,
                    ),
                  ),
                  Text(
                    title,
                    style: styles.serif(
                      size: 30,
                      line: 40,
                      weight: FontWeight.w600,
                      letterSpacing: 30 * 0.02,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(11, 5, 11, 5),
                      decoration: BoxDecoration(
                        color: tokens.chip,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          DayIcon(
                            'lock',
                            size: 14,
                            stroke: 1.8,
                            color: tokens.ink2,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            seal,
                            style: styles.sans(size: 13, color: tokens.ink2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const RuleLine(),
                  const SizedBox(height: 18),
                  Text(original, style: styles.serif(size: 18, line: 34)),
                  for (final append in appends)
                    _AppendBlock(append.$1, append.$2),
                  if (editing)
                    _AppendBlock(
                      draftLabel!,
                      draftText ?? '',
                      editing: true,
                      onChanged: onDraftChanged,
                    ),
                  if (!editing && (reply.isNotEmpty || done.isNotEmpty)) ...[
                    const SizedBox(height: 28),
                    if (reply.isNotEmpty) ...[
                      Text(
                        '那天的回应',
                        style: styles.sans(size: 13, color: tokens.ink3),
                      ),
                      const SizedBox(height: 8),
                      Text(reply, style: styles.serif(size: 17, line: 31)),
                      if (done.isNotEmpty) const SizedBox(height: 22),
                    ],
                    if (done.isNotEmpty)
                      _DoneCard(title: '那天其实做完了', items: done),
                  ],
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(26, 12, 26, barBottomPad(context)),
              child: editing
                  ? Row(
                      children: [
                        SizedBox(
                          width: 96,
                          child: DayfordButton(
                            label: '取消',
                            ghost: true,
                            small: true,
                            expand: true,
                            onPressed: onCancel,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DayfordButton(
                            label: '补写好了',
                            serif: true,
                            onPressed: onSave,
                          ),
                        ),
                      ],
                    )
                  : DayfordButton(
                      label: '补写一段',
                      ghost: true,
                      icon: DayIcon(
                        'plus',
                        size: 18,
                        stroke: 2,
                        color: tokens.ink,
                      ),
                      onPressed: onStartAppend,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppendBlock extends StatelessWidget {
  const _AppendBlock(
    this.label,
    this.text, {
    this.editing = false,
    this.onChanged,
  });

  final String label;
  final String text;
  final bool editing;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return Container(
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.only(left: 14),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: editing ? tokens.accent : tokens.line2,
            width: 2,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: styles.sans(size: 13, line: 20, color: tokens.ink3),
          ),
          const SizedBox(height: 4),
          if (editing && onChanged != null)
            _DraftField(text: text, onChanged: onChanged!)
          else
            Text.rich(
              TextSpan(
                style: styles.serif(size: 18, line: 34),
                children: [
                  TextSpan(text: text),
                  if (editing)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: CaretMark(color: tokens.accent),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DraftField extends StatefulWidget {
  const _DraftField({required this.text, required this.onChanged});

  final String text;
  final ValueChanged<String> onChanged;

  @override
  State<_DraftField> createState() => _DraftFieldState();
}

class _DraftFieldState extends State<_DraftField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.text,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return TextField(
      controller: _controller,
      autofocus: true,
      maxLines: null,
      minLines: 2,
      cursorColor: tokens.accent,
      cursorWidth: 2,
      style: styles.serif(size: 18, line: 34),
      decoration: const InputDecoration(
        border: InputBorder.none,
        isCollapsed: true,
      ),
      onChanged: widget.onChanged,
    );
  }
}

class HistoryView extends StatelessWidget {
  const HistoryView({
    super.key,
    required this.groups,
    this.onBack,
    this.onWeek,
    this.onOpen,
  });

  final List<(String, List<(String, String, String, String)>)> groups;
  final VoidCallback? onBack;
  final VoidCallback? onWeek;
  final void Function(String id)? onOpen;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final top = MediaQuery.viewPaddingOf(context).top;
    var dot = 0;
    return PageFrame(
      child: BackEdge(
        onBack: onBack,
        child: ListView(
          padding: EdgeInsets.fromLTRB(26, top, 26, 42),
          children: [
            DayfordNav(label: '今天', onBack: onBack),
            Text(
              '历史',
              style: styles.serif(
                size: 30,
                line: 40,
                weight: FontWeight.w600,
                letterSpacing: 30 * 0.02,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '这里只放写过的日子。',
              style: styles.sans(size: 15, line: 24, color: tokens.ink2),
            ),
            const RuleLine(),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onWeek,
              child: DecoratedBox(
                decoration: tokens.cardBox(),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Orb(),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '这一周',
                              style: styles.sans(
                                size: 17,
                                weight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '看看这周做完了些什么',
                              style: styles.sans(size: 13, color: tokens.ink2),
                            ),
                          ],
                        ),
                      ),
                      DayIcon('chevR', size: 16, stroke: 2, color: tokens.ink3),
                    ],
                  ),
                ),
              ),
            ),
            for (final group in groups) ...[
              SectionLabel(group.$1),
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: DecoratedBox(
                  decoration: tokens.cardBox(),
                  child: Column(
                    children: [
                      for (var i = 0; i < group.$2.length; i++)
                        _HistoryRow(
                          group.$2[i],
                          dotIndex: dot++,
                          first: i == 0,
                          onTap: () => onOpen?.call(group.$2[i].$1),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow(
    this.row, {
    required this.dotIndex,
    required this.first,
    this.onTap,
  });

  final (String, String, String, String) row;
  final int dotIndex;
  final bool first;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 19),
              child: DoneDot(index: dotIndex),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(0, 13, 0, 13),
                decoration: BoxDecoration(
                  border: first
                      ? null
                      : Border(top: BorderSide(color: tokens.line)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: row.$2,
                            style: styles.sans(
                              size: 15,
                              line: 22,
                              weight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '  ${row.$3}',
                            style: styles.sans(size: 13, color: tokens.ink3),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      row.$4,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: styles.serif(
                        size: 15,
                        line: 24,
                        color: tokens.ink2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: DayIcon('chevR', size: 16, stroke: 2, color: tokens.ink3),
            ),
          ],
        ),
      ),
    );
  }
}

class WeeklyView extends StatelessWidget {
  const WeeklyView({
    super.key,
    required this.range,
    required this.thisWeek,
    required this.reply,
    required this.items,
    this.empty = false,
    this.daysOnly = const [],
    this.onBack,
    this.onSelectWeek,
  });

  final String range;
  final bool thisWeek;
  final String? reply;
  final List<(String, String)> items;
  final bool empty;
  final List<String> daysOnly;
  final VoidCallback? onBack;
  final ValueChanged<bool>? onSelectWeek;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final top = MediaQuery.viewPaddingOf(context).top;
    final total = items.length;
    return PageFrame(
      child: BackEdge(
        onBack: onBack,
        child: ListView(
          padding: EdgeInsets.fromLTRB(26, top, 26, 42),
          children: [
            DayfordNav(label: '历史', onBack: onBack),
            Text(
              '这一周',
              style: styles.serif(
                size: 30,
                line: 40,
                weight: FontWeight.w600,
                letterSpacing: 30 * 0.02,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              range,
              style: styles.sans(
                size: 13,
                color: tokens.ink3,
                letterSpacing: 13 * 0.06,
              ),
            ),
            const RuleLine(),
            const SizedBox(height: 16),
            _Segment(thisWeek: thisWeek, onSelect: onSelectWeek),
            if (empty) ...[
              const SizedBox(height: 22),
              Text('这周还没写，写一句也算', style: styles.serif(size: 17, line: 31)),
            ] else if (reply == null) ...[
              const SizedBox(height: 22),
              if (daysOnly.isEmpty)
                Text('这周还没写，写一句也算', style: styles.serif(size: 17, line: 31))
              else
                DayfordCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      for (var i = 0; i < daysOnly.length; i++)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            border: i == 0
                                ? null
                                : Border(top: BorderSide(color: tokens.line)),
                          ),
                          child: Text(
                            daysOnly[i],
                            style: styles.sans(size: 15),
                          ),
                        ),
                    ],
                  ),
                ),
            ] else ...[
              const SizedBox(height: 22),
              Row(
                children: [
                  const Orb(),
                  const SizedBox(width: 8),
                  Text(
                    '这一周的回应',
                    style: styles.sans(size: 13, line: 20, color: tokens.ink3),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(reply!, style: styles.serif(size: 17, line: 31)),
              const SizedBox(height: 22),
              DayfordCard(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          '这周做完的事',
                          style: styles.serif(
                            size: 15,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '一共 $total 件',
                          style: styles.sans(size: 13, color: tokens.ink2),
                        ),
                      ],
                    ),
                    for (var i = 0; i < items.length; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          border: i == 0
                              ? null
                              : Border(top: BorderSide(color: tokens.line)),
                        ),
                        child: Row(
                          children: [
                            DoneDot(index: i),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                items[i].$1,
                                style: styles.serif(size: 16, line: 24),
                              ),
                            ),
                            Text(
                              items[i].$2,
                              style: styles.sans(size: 13, color: tokens.ink2),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  '只数做到了的事。',
                  style: styles.sans(size: 13, line: 20, color: tokens.ink3),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.thisWeek, required this.onSelect});

  final bool thisWeek;
  final ValueChanged<bool>? onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    return Container(
      height: 34,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: tokens.chip,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _seg(context, '这一周', thisWeek, () => onSelect?.call(true)),
          _seg(context, '上一周', !thisWeek, () => onSelect?.call(false)),
        ],
      ),
    );
  }

  Widget _seg(BuildContext context, String label, bool on, VoidCallback onTap) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: on ? tokens.segOn : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: on ? tokens.segShadow : null,
          ),
          child: Center(
            child: Text(
              label,
              style: styles.sans(
                size: 13,
                weight: on ? FontWeight.w600 : FontWeight.w400,
                color: on ? tokens.ink : tokens.ink2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  const SettingsView({
    super.key,
    required this.appearanceLine,
    required this.modelLine,
    this.onBack,
    this.onAppearance,
    this.onModel,
    this.onAbout,
  });

  final String appearanceLine;
  final String modelLine;
  final VoidCallback? onBack;
  final VoidCallback? onAppearance;
  final VoidCallback? onModel;
  final VoidCallback? onAbout;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final top = MediaQuery.viewPaddingOf(context).top;
    return PageFrame(
      child: BackEdge(
        onBack: onBack,
        child: ListView(
          padding: EdgeInsets.fromLTRB(26, top, 26, 42),
          children: [
            DayfordNav(label: '今天', onBack: onBack),
            Text(
              '设置',
              style: styles.serif(
                size: 30,
                line: 40,
                weight: FontWeight.w600,
                letterSpacing: 30 * 0.02,
              ),
            ),
            const RuleLine(),
            const SizedBox(height: 20),
            DayfordCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Orb(size: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '日记只在这台手机里',
                          style: styles.serif(
                            size: 17,
                            line: 24,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '不用注册，不上传，AI 也在本机运行。',
                          style: styles.sans(
                            size: 13,
                            line: 20,
                            color: tokens.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SectionLabel('看起来'),
            _SettingRow(
              icon: 'half',
              index: 2,
              title: '外观',
              detail: appearanceLine,
              onTap: onAppearance,
            ),
            const SectionLabel('回应'),
            _SettingRow(
              icon: 'spark',
              index: 1,
              title: 'AI 模型',
              detail: modelLine,
              onTap: onModel,
            ),
            const SectionLabel('关于'),
            _SettingRow(
              icon: 'leaf',
              index: 0,
              title: '关于与隐私',
              detail: '数据只在本机 · 版本 0.1',
              onTap: onAbout,
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                '日济 0.1\n慢慢写，一句也算。',
                textAlign: TextAlign.center,
                style: styles.serif(size: 13, line: 20, color: tokens.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.index,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final String icon;
  final int index;
  final String title;
  final String detail;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: tokens.cardBox(),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              children: [
                IconTile(icon: icon, index: index),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: styles.sans(size: 17, line: 24)),
                      const SizedBox(height: 2),
                      Text(
                        detail,
                        style: styles.sans(
                          size: 13,
                          line: 19,
                          color: tokens.ink2,
                        ),
                      ),
                    ],
                  ),
                ),
                DayIcon('chevR', size: 16, stroke: 2, color: tokens.ink3),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AboutView extends StatelessWidget {
  const AboutView({super.key, this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final top = MediaQuery.viewPaddingOf(context).top;
    const rows = [
      ('phone', 3, '只存在这台手机里', '日记、补写和回应都保存在本机。'),
      ('spark', 1, 'AI 也在本机运行', '读你的日记、写回应，全都在手机里完成。'),
      ('wifi', 0, '只有下载模型时会联网', '下载的只是模型本身，不会带走任何日记。'),
      ('lock', 2, '删掉 app，日记也会一起删掉', '因为它们从来没有离开过这台手机。'),
    ];
    return PageFrame(
      child: BackEdge(
        onBack: onBack,
        child: ListView(
          padding: EdgeInsets.fromLTRB(26, top, 26, 42),
          children: [
            DayfordNav(label: '设置', onBack: onBack),
            Text(
              '关于与隐私',
              style: styles.serif(
                size: 30,
                line: 40,
                weight: FontWeight.w600,
                letterSpacing: 30 * 0.02,
              ),
            ),
            const RuleLine(),
            const SizedBox(height: 20),
            DayfordCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Orb(size: 40),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '你写的，只有你看得到',
                          style: styles.serif(
                            size: 17,
                            line: 24,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '日济不需要账号，也没有服务器在另一头等着。',
                          style: styles.sans(
                            size: 13,
                            line: 20,
                            color: tokens.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SectionLabel('数据去了哪里'),
            DecoratedBox(
              decoration: tokens.cardBox(),
              child: Column(
                children: [
                  for (var i = 0; i < rows.length; i++)
                    Container(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        border: i == 0
                            ? null
                            : Border(top: BorderSide(color: tokens.line)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconTile(icon: rows[i].$1, index: rows[i].$2),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rows[i].$3,
                                  style: styles.sans(
                                    size: 15,
                                    line: 22,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  rows[i].$4,
                                  style: styles.sans(
                                    size: 13,
                                    line: 20,
                                    color: tokens.ink2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: Text(
                '日济 0.1\n给想把每件事都做好的你。',
                textAlign: TextAlign.center,
                style: styles.serif(size: 13, line: 20, color: tokens.ink3),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
