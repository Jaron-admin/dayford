import 'package:flutter/material.dart';

import '../../constants/model_catalog.dart';
import '../../services/model_manager.dart';
import '../icons.dart';
import '../theme/scope.dart';
import '../widgets/chrome.dart';
import '../widgets/delete_sheet.dart';

class ModelView extends StatelessWidget {
  const ModelView({
    super.key,
    required this.phase,
    this.progress = 0.46,
    this.activeId = 'mid',
    this.onBack,
    this.onDownload,
    this.onPause,
    this.onResume,
    this.onRetry,
    this.onCellular,
    this.onDelete,
    this.onSwitch,
  });

  final ModelPhase phase;
  final double progress;
  final String activeId;
  final VoidCallback? onBack;
  final void Function(String id)? onDownload;
  final VoidCallback? onPause;
  final VoidCallback? onResume;
  final VoidCallback? onRetry;
  final VoidCallback? onCellular;
  final Future<void> Function()? onDelete;
  final void Function(String id)? onSwitch;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final top = MediaQuery.viewPaddingOf(context).top;
    final unsupported = phase == ModelPhase.unsupported;
    final ready = phase == ModelPhase.ready;
    final mid = ModelCatalog.mid;
    final percent = (progress * 100).round();
    final doneGb = (mid.gigabytes * progress).toStringAsFixed(1);
    return PageFrame(
      child: BackEdge(
        onBack: onBack,
        child: ListView(
          padding: EdgeInsets.fromLTRB(26, top, 26, 42),
          children: [
            DayfordNav(label: '设置', onBack: onBack),
            Text(
              'AI 模型',
              style: styles.serif(
                size: 30,
                line: 40,
                weight: FontWeight.w600,
                letterSpacing: 30 * 0.02,
              ),
            ),
            if (!unsupported) ...[
              const SizedBox(height: 6),
              Text(
                '在手机里运行，你写的字不会被传出去。',
                style: styles.sans(size: 15, line: 24, color: tokens.ink2),
              ),
            ],
            const RuleLine(),
            const SizedBox(height: 18),
            _DeviceCard(unsupported: unsupported),
            if (unsupported) ...[
              const SizedBox(height: 22),
              const _PlainStatus(
                title: '这台手机暂时用不了 AI，\n但日记照样能写',
                body: '本机 AI 至少需要 6 GB 内存，这台手机还差一点。写下的每一篇都会好好存着，封存、补写、历史和以前一样。',
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '换了新手机之后，这里会自动出现可以用的模型。',
                  textAlign: TextAlign.center,
                  style: styles.sans(size: 13, line: 20, color: tokens.ink3),
                ),
              ),
            ] else ...[
              SectionLabel(ready ? '正在用的' : '推荐给这台手机'),
              DayfordCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          mid.name,
                          style: styles.sans(
                            size: 19,
                            line: 26,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (ready)
                          TagChip(
                            label: '正在使用',
                            icon: DayIcon(
                              'check',
                              size: 12,
                              stroke: 2.4,
                              color: tokens.tagFg,
                            ),
                          )
                        else
                          const TagChip(label: '推荐'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${mid.sizeLabel} · ${mid.speedLabel}',
                      style: styles.sans(
                        size: 13,
                        line: 19,
                        color: tokens.ink2,
                      ),
                    ),
                    if (!ready) ...[
                      const SizedBox(height: 10),
                      Text(
                        mid.reason ?? '',
                        style: styles.serif(size: 15, line: 24),
                      ),
                    ],
                    if (phase == ModelPhase.cellular)
                      const NoticeBanner(
                        icon: 'wifi',
                        text: '现在用的是蜂窝网络。模型有点大，连上 Wi‑Fi 后会自动开始下载。',
                      ),
                    if (phase == ModelPhase.storage)
                      const NoticeBanner(
                        icon: 'disk',
                        text: '手机里的空间还差 0.6 GB。清出一点空间后回来就好，或者先试试小一点的「轻巧」（420 MB）。',
                      ),
                    if (phase == ModelPhase.failed)
                      const NoticeBanner(
                        icon: 'cloudoff',
                        text: '没关系，已经下好的部分还留着，重试会从这里接着下。',
                      ),
                    if (phase == ModelPhase.downloading ||
                        phase == ModelPhase.paused ||
                        phase == ModelPhase.failed) ...[
                      const SizedBox(height: 16),
                      ProgressTrack(
                        value: progress,
                        paused: phase != ModelPhase.downloading,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            phase == ModelPhase.paused
                                ? '已暂停 · $doneGb / ${mid.sizeLabel}'
                                : phase == ModelPhase.failed
                                ? '网络断了一下'
                                : '$percent% · $doneGb / ${mid.sizeLabel}',
                            style: styles.sans(size: 13, color: tokens.ink2),
                          ),
                          const Spacer(),
                          Text(
                            phase == ModelPhase.downloading
                                ? '大约还要 2 分钟'
                                : '$percent%',
                            style: styles.sans(size: 13, color: tokens.ink2),
                          ),
                        ],
                      ),
                    ],
                    if (ready)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          '写好日记后，回应都在这台手机里生成。',
                          style: styles.sans(
                            size: 13,
                            line: 20,
                            color: tokens.ink3,
                          ),
                        ),
                      ),
                    if (phase == ModelPhase.none) ...[
                      const SizedBox(height: 16),
                      DayfordButton(
                        label: '下载 · ${mid.sizeLabel}',
                        small: true,
                        onPressed: () => onDownload?.call(mid.id),
                      ),
                    ],
                    if (phase == ModelPhase.cellular) ...[
                      const SizedBox(height: 14),
                      const DayfordButton(
                        label: '等 Wi‑Fi 中…',
                        small: true,
                        enabled: false,
                        onPressed: null,
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: DayfordLink(
                          label: '这次用蜂窝数据也行',
                          size: 13,
                          onPressed: onCellular,
                        ),
                      ),
                    ],
                    if (phase == ModelPhase.downloading) ...[
                      const SizedBox(height: 14),
                      DayfordButton(
                        label: '暂停',
                        small: true,
                        ghost: true,
                        onPressed: onPause,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '可以先去写日记，下载会在后台继续。',
                        style: styles.sans(
                          size: 13,
                          line: 20,
                          color: tokens.ink3,
                        ),
                      ),
                    ],
                    if (phase == ModelPhase.paused) ...[
                      const SizedBox(height: 14),
                      DayfordButton(
                        label: '继续',
                        small: true,
                        onPressed: onResume,
                      ),
                    ],
                    if (phase == ModelPhase.failed) ...[
                      const SizedBox(height: 14),
                      DayfordButton(
                        label: '重试',
                        small: true,
                        icon: DayIcon(
                          'retry',
                          size: 16,
                          stroke: 2,
                          color: tokens.buttonFg,
                        ),
                        onPressed: onRetry,
                      ),
                    ],
                    if (phase == ModelPhase.storage) ...[
                      const SizedBox(height: 14),
                      DayfordButton(
                        label: '再试一次',
                        small: true,
                        ghost: true,
                        onPressed: () => onDownload?.call(mid.id),
                      ),
                    ],
                  ],
                ),
              ),
              const SectionLabel('也可以选'),
              DecoratedBox(
                decoration: tokens.cardBox(),
                child: Column(
                  children: [
                    for (final spec in [ModelCatalog.small, ModelCatalog.large])
                      _AltRow(
                        spec: spec,
                        ready: ready,
                        first: spec.id == ModelCatalog.small.id,
                        onPressed: () => ready
                            ? onSwitch?.call(spec.id)
                            : onDownload?.call(spec.id),
                      ),
                  ],
                ),
              ),
              if (ready) ...[
                const SizedBox(height: 22),
                Center(
                  child: DayfordLink(
                    key: const Key('delete-model'),
                    label: '删除「${mid.name}」· 释放 ${mid.sizeLabel}',
                    color: tokens.danger,
                    onPressed: () async {
                      final ok = await confirmDeleteModel(
                        context,
                        modelName: mid.name,
                        sizeLabel: mid.sizeLabel,
                      );
                      if (ok) await onDelete?.call();
                    },
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text(
                    '删除后日记都还在，只是暂时不会有回应。',
                    style: styles.sans(size: 13, line: 20, color: tokens.ink3),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.unsupported});

  final bool unsupported;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return DayfordCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const IconTile(icon: 'phone', index: 3),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  unsupported
                      ? ModelCatalog.unsupportedDevice
                      : ModelCatalog.supportedDevice,
                  style: styles.sans(
                    size: 17,
                    line: 24,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  unsupported
                      ? ModelCatalog.unsupportedDeviceNote
                      : ModelCatalog.supportedDeviceNote,
                  style: styles.sans(size: 13, line: 19, color: tokens.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlainStatus extends StatelessWidget {
  const _PlainStatus({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return DayfordCard(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Orb(size: 40, dim: true),
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
        ],
      ),
    );
  }
}

class _AltRow extends StatelessWidget {
  const _AltRow({
    required this.spec,
    required this.ready,
    required this.first,
    required this.onPressed,
  });

  final ModelSpec spec;
  final bool ready;
  final bool first;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: tokens.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  spec.name,
                  style: styles.sans(
                    size: 17,
                    line: 24,
                    weight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${spec.sizeLabel} · ${spec.speedLabel}',
                  style: styles.sans(size: 13, line: 19, color: tokens.ink2),
                ),
                Text(
                  spec.note ?? '',
                  style: styles.sans(size: 13, line: 20, color: tokens.ink3),
                ),
              ],
            ),
          ),
          DayfordLink(label: ready ? '换成这个' : '下载', onPressed: onPressed),
        ],
      ),
    );
  }
}
