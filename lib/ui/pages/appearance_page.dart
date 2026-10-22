import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme/scope.dart';
import '../theme/tokens.dart';
import '../widgets/chrome.dart';

class AppearanceView extends StatelessWidget {
  const AppearanceView({
    super.key,
    required this.systemLight,
    required this.lightId,
    required this.darkId,
    this.onBack,
    this.onPick,
  });

  final bool systemLight;
  final ThemeId lightId;
  final ThemeId darkId;
  final VoidCallback? onBack;
  final ValueChanged<ThemeId>? onPick;

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
            DayfordNav(label: '设置', onBack: onBack),
            Text(
              '外观',
              style: styles.serif(
                size: 30,
                line: 40,
                weight: FontWeight.w600,
                letterSpacing: 30 * 0.02,
              ),
            ),
            const RuleLine(),
            const SizedBox(height: 18),
            DayfordCard(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                children: [
                  const IconTile(icon: 'half', index: 2),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        style: styles.sans(
                          size: 13,
                          line: 20,
                          color: tokens.ink2,
                        ),
                        children: [
                          TextSpan(
                            text: '跟随系统\n',
                            style: styles.sans(
                              size: 15,
                              line: 22,
                              weight: FontWeight.w600,
                              color: tokens.ink,
                            ),
                          ),
                          TextSpan(
                            text:
                                '手机切到浅色或深色时，这里会自动换过去。现在是${systemLight ? '浅色' : '深色'}。',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _ThemeRow(
              icon: 'sun',
              label: '浅色时',
              active: systemLight,
              spread: true,
              children: [
                for (final id in ThemeId.lightChoices)
                  ThemeThumb(
                    id: id,
                    selected: lightId == id,
                    onTap: () => onPick?.call(id),
                  ),
              ],
            ),
            _ThemeRow(
              icon: 'moon',
              label: '深色时',
              active: !systemLight,
              children: [
                for (final id in ThemeId.darkChoices)
                  Padding(
                    padding: EdgeInsets.only(right: id == ThemeId.bd ? 10 : 0),
                    child: ThemeThumb(
                      id: id,
                      selected: darkId == id,
                      onTap: () => onPick?.call(id),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              '选好的那一套会用在所有页面上。「晨雾」「水彩手账」「素白」只有浅色，「墨夜」只有深色，「夜灯」两种都有。',
              style: styles.sans(size: 13, line: 20, color: tokens.ink3),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({
    required this.icon,
    required this.label,
    required this.active,
    required this.children,
    this.spread = false,
  });

  final String icon;
  final String label;
  final bool active;
  final List<Widget> children;
  final bool spread;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
          child: Row(
            children: [
              DayIcon(icon, size: 16, stroke: 1.8, color: tokens.ink),
              const SizedBox(width: 6),
              Text(
                label,
                style: styles.sans(size: 15, weight: FontWeight.w600),
              ),
              const Spacer(),
              if (active) const TagChip(label: '正在用'),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: spread
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ],
    );
  }
}

class ThemeThumb extends StatelessWidget {
  const ThemeThumb({
    super.key,
    required this.id,
    required this.selected,
    this.onTap,
  });

  final ThemeId id;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final page = TokenScope.of(context);
    final preview = DayfordTokens.of(id);
    final styles = DayfordStyles(page);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 68,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 68,
                  height: 132,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A1A),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: selected
                        ? [
                            BoxShadow(color: page.bg, spreadRadius: 2),
                            BoxShadow(color: page.accentText, spreadRadius: 4),
                          ]
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: TokenScope(
                      tokens: preview,
                      child: const _MiniScreen(),
                    ),
                  ),
                ),
                if (selected)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: page.accentText,
                        shape: BoxShape.circle,
                        border: Border.all(color: page.bg, width: 2),
                      ),
                      child: DayIcon(
                        'check',
                        size: 12,
                        stroke: 3,
                        color: page.bg,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              preview.id.name,
              style: styles.sans(
                size: 12,
                line: 16,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? page.ink : page.ink2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniScreen extends StatelessWidget {
  const _MiniScreen();

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    return ColoredBox(
      color: tokens.bg,
      child: CustomPaint(
        painter: DecoPainter(tokens),
        child: Stack(
          children: [
            Positioned(
              top: 16,
              left: 8,
              child: _bar(20, 3, tokens.ink3.withValues(alpha: 0.7)),
            ),
            Positioned(top: 23, left: 8, child: _bar(24, 7, tokens.ink)),
            if (tokens.showRule)
              Positioned(top: 36, left: 8, child: _bar(10, 1, tokens.rule)),
            Positioned(
              top: 42,
              left: 8,
              child: _bar(44, 3, tokens.ink.withValues(alpha: 0.45)),
            ),
            Positioned(
              top: 50,
              left: 8,
              child: _bar(46, 3, tokens.ink.withValues(alpha: 0.45)),
            ),
            Positioned(
              top: 58,
              left: 8,
              child: _bar(28, 3, tokens.ink.withValues(alpha: 0.45)),
            ),
            Positioned(
              top: 72,
              left: 6,
              right: 6,
              height: 22,
              child: DecoratedBox(decoration: tokens.cardBox(radius: 5)),
            ),
            Positioned(top: 79, left: 11, child: DoneDot(index: 0, size: 4)),
            Positioned(
              top: 80,
              left: 18,
              child: _bar(24, 2, tokens.ink2.withValues(alpha: 0.6)),
            ),
            Positioned(top: 86, left: 11, child: DoneDot(index: 1, size: 4)),
            Positioned(
              top: 87,
              left: 18,
              child: _bar(20, 2, tokens.ink2.withValues(alpha: 0.6)),
            ),
            Positioned(
              bottom: 9,
              left: 6,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: tokens.chip,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 9,
              left: 20,
              right: 6,
              height: 11,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.buttonGradient == null
                      ? (tokens.buttonSolid ?? Colors.transparent)
                      : null,
                  gradient: tokens.buttonGradient,
                  borderRadius: BorderRadius.circular(6),
                  border: tokens.buttonBorder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bar(double w, double h, Color color) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
