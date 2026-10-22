import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../icons.dart';
import '../theme/scope.dart';
import '../theme/tokens.dart';

class PageFrame extends StatelessWidget {
  const PageFrame({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final style = DayfordStyles(tokens).sans(size: 17, color: tokens.ink);
    return Material(
      color: tokens.bg,
      elevation: 0,
      child: DefaultTextStyle(
        style: style,
        child: CustomPaint(painter: DecoPainter(tokens), child: child),
      ),
    );
  }
}

double barBottomPad(BuildContext context) {
  final keyboard = MediaQuery.viewInsetsOf(context).bottom;
  if (keyboard > 0) return 12;
  final gesture = MediaQuery.viewPaddingOf(context).bottom;
  return math.max(38, gesture);
}

class DayfordButton extends StatefulWidget {
  const DayfordButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.small = false,
    this.ghost = false,
    this.serif = false,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool small;
  final bool ghost;
  final bool serif;
  final Widget? icon;
  final bool expand;

  @override
  State<DayfordButton> createState() => _DayfordButtonState();
}

class _DayfordButtonState extends State<DayfordButton> {
  var _down = false;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final height = widget.small ? 44.0 : 52.0;
    final radius = widget.small ? 22.0 : 26.0;
    final child = Opacity(
      opacity: widget.enabled ? 1 : 0.38,
      child: AnimatedScale(
        scale: _down && widget.enabled ? 0.98 : 1,
        duration: const Duration(milliseconds: 120),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: widget.ghost
                ? tokens.chip
                : (tokens.buttonGradient == null
                      ? (tokens.buttonSolid ?? Colors.transparent)
                      : null),
            gradient: widget.ghost ? null : tokens.buttonGradient,
            borderRadius: BorderRadius.circular(radius),
            border: widget.ghost ? null : tokens.buttonBorder,
            boxShadow: widget.ghost || !widget.enabled
                ? null
                : tokens.buttonShadow,
          ),
          child: SizedBox(
            height: height,
            width: widget.expand ? double.infinity : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: widget.expand
                    ? MainAxisSize.max
                    : MainAxisSize.min,
                children: [
                  if (widget.icon != null) ...[
                    widget.icon!,
                    const SizedBox(width: 6),
                  ],
                  Text(
                    widget.label,
                    style: widget.serif
                        ? styles.serif(
                            size: widget.small ? 16 : 17,
                            weight: FontWeight.w600,
                            color: widget.ghost ? tokens.ink : tokens.buttonFg,
                            letterSpacing: (widget.small ? 16 : 17) * 0.12,
                          )
                        : styles.sans(
                            size: widget.small ? 16 : 17,
                            weight: FontWeight.w600,
                            color: widget.ghost ? tokens.ink : tokens.buttonFg,
                            letterSpacing: (widget.small ? 16 : 17) * 0.04,
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.enabled ? widget.onPressed : null,
      child: child,
    );
  }
}

class RoundIconButton extends StatelessWidget {
  const RoundIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final String icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: tokens.chip, shape: BoxShape.circle),
          child: DayIcon(icon, size: 20, stroke: 1.8, color: tokens.ink2),
        ),
      ),
    );
  }
}

class DayfordLink extends StatelessWidget {
  const DayfordLink({
    super.key,
    required this.label,
    required this.onPressed,
    this.color,
    this.size = 15,
    this.chevron = false,
    this.icon,
    this.weight = FontWeight.w400,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;
  final bool chevron;
  final Widget? icon;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    final paint = color ?? tokens.accentText;
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 4)],
            Text(
              label,
              style: styles.sans(size: size, weight: weight, color: paint),
            ),
            if (chevron) DayIcon('chevR', size: 14, stroke: 2, color: paint),
          ],
        ),
      ),
    );
  }
}

class DayfordNav extends StatelessWidget {
  const DayfordNav({
    super.key,
    required this.label,
    required this.onBack,
    this.trailing,
  });

  final String label;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            behavior: HitTestBehavior.opaque,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DayIcon(
                    'chevL',
                    size: 24,
                    stroke: 2,
                    color: tokens.accentText,
                  ),
                  Text(
                    label,
                    style: styles.sans(size: 17, color: tokens.accentText),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          ?trailing,
        ],
      ),
    );
  }
}

class BackEdge extends StatelessWidget {
  const BackEdge({super.key, required this.child, required this.onBack});

  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    if (onBack == null) return child;
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: 14,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              if ((details.primaryVelocity ?? 0) > 300) onBack!();
            },
          ),
        ),
      ],
    );
  }
}

class Orb extends StatelessWidget {
  const Orb({super.key, this.size = 20, this.breath = false, this.dim = false});

  final double size;
  final bool breath;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final orb = _orb(tokens, breath && !reduce ? 1 : 1, breath);
    if (!breath || reduce) {
      return Opacity(opacity: dim ? 0.45 : 1, child: orb);
    }
    return _Breath(size: size, dim: dim, child: orb);
  }

  Widget _orb(DayfordTokens tokens, double scale, bool glow) {
    final spec = tokens.orb;
    final decoration = BoxDecoration(
      shape: BoxShape.circle,
      gradient: spec.kind == OrbKind.radial
          ? RadialGradient(
              center: spec.center,
              colors: spec.colors,
              stops: spec.stops,
            )
          : SweepGradient(
              startAngle: spec.startAngle,
              endAngle: spec.startAngle + math.pi * 2,
              colors: spec.colors,
              stops: spec.stops,
            ),
      boxShadow: glow ? [BoxShadow(color: spec.glow, blurRadius: 14)] : null,
    );
    return Transform.scale(
      scale: scale,
      child: Container(width: size, height: size, decoration: decoration),
    );
  }
}

class _Breath extends StatefulWidget {
  const _Breath({required this.child, required this.size, required this.dim});

  final Widget child;
  final double size;
  final bool dim;

  @override
  State<_Breath> createState() => _BreathState();
}

class _BreathState extends State<_Breath> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        final scale = 0.86 + (1.06 - 0.86) * t;
        final opacity = (0.72 + (1 - 0.72) * t) * (widget.dim ? 0.45 : 1);
        return Opacity(
          opacity: opacity.clamp(0, 1),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: widget.child,
    );
  }
}

class DoneDot extends StatelessWidget {
  const DoneDot({super.key, required this.index, this.size = 10});

  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    if (!tokens.monoDots) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: tokens.dots[index % tokens.dots.length],
          shape: BoxShape.circle,
        ),
      );
    }
    return CustomPaint(
      size: Size.square(size),
      painter: _MonoDotPainter(tokens.ink, index % 3),
    );
  }
}

class _MonoDotPainter extends CustomPainter {
  _MonoDotPainter(this.color, this.kind);

  final Color color;
  final int kind;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    final fill = Paint()..color = color;
    if (kind == 0) {
      canvas.drawCircle(rect.center, size.width / 2, fill);
      return;
    }
    canvas.drawCircle(rect.center, size.width / 2 - 0.75, stroke);
    if (kind == 2) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width / 2, size.height));
      canvas.drawCircle(rect.center, size.width / 2 - 0.75, fill);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MonoDotPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.kind != kind;
}

class DayfordCard extends StatelessWidget {
  const DayfordCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 22,
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    return DecoratedBox(
      decoration: tokens.cardBox(radius: radius),
      child: Padding(padding: padding, child: child),
    );
  }
}

class ProgressTrack extends StatelessWidget {
  const ProgressTrack({super.key, required this.value, this.paused = false});

  final double value;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        height: 6,
        child: Stack(
          children: [
            const Positioned.fill(child: SizedBox.shrink()),
            Positioned.fill(child: ColoredBox(color: tokens.chip)),
            FractionallySizedBox(
              widthFactor: value.clamp(0, 1),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.accent.withValues(alpha: paused ? 0.45 : 1),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NoticeBanner extends StatelessWidget {
  const NoticeBanner({super.key, required this.icon, required this.text});

  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tokens.chip,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1),
            child: DayIcon(icon, size: 16, stroke: 1.8, color: tokens.ink),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: styles.sans(size: 13, line: 20, color: tokens.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 8),
      child: Text(
        text,
        style: styles.sans(
          size: 13,
          color: tokens.ink3,
          letterSpacing: 13 * 0.04,
        ),
      ),
    );
  }
}

class IconTile extends StatelessWidget {
  const IconTile({super.key, required this.icon, required this.index});

  final String icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final Color bg;
    final Color fg;
    if (tokens.monoDots) {
      bg = tokens.chip;
      fg = tokens.ink;
    } else {
      final dot = tokens.dots[index % tokens.dots.length];
      bg = dot.withValues(alpha: 0.2);
      fg = Color.lerp(tokens.ink, dot, tokens.isDark ? 1 : 0.72)!;
    }
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9),
      ),
      child: DayIcon(icon, size: 18, stroke: 1.8, color: fg),
    );
  }
}

class RuleLine extends StatelessWidget {
  const RuleLine({super.key});

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    if (!tokens.showRule) return const SizedBox.shrink();
    // A bare width is ignored inside a ListView's tight cross-axis, which
    // stretched this into a full-width rule. Align loosens that constraint.
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        width: 44,
        height: 1.2,
        color: tokens.rule,
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  const TagChip({super.key, required this.label, this.icon});

  final String label;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      height: 20,
      decoration: BoxDecoration(
        color: tokens.tagBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon!, const SizedBox(width: 3)],
          Text(
            label,
            style: styles.sans(
              size: 12,
              line: 20,
              weight: FontWeight.w600,
              color: tokens.tagFg,
            ),
          ),
        ],
      ),
    );
  }
}

class PreviewChrome extends StatelessWidget {
  const PreviewChrome({
    super.key,
    required this.time,
    required this.cellular,
    required this.child,
  });

  final String time;
  final bool cellular;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    final styles = DayfordStyles(tokens);
    return DefaultTextStyle(
      style: styles.sans(size: 15, color: tokens.ink),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(child: child),
          Positioned(
            top: 11,
            left: 0,
            right: 0,
            child: Center(
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 34,
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 50,
            child: IgnorePointer(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 6, 30, 0),
                child: Row(
                  children: [
                    Text(
                      time,
                      style: styles.sans(
                        size: 15,
                        weight: FontWeight.w600,
                        color: tokens.ink,
                      ),
                    ),
                    const Spacer(),
                    if (cellular)
                      Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '5G',
                          style: styles.sans(
                            size: 12,
                            weight: FontWeight.w600,
                            color: tokens.ink,
                          ),
                        ),
                      ),
                    _Signal(color: tokens.ink),
                    const SizedBox(width: 6),
                    if (!cellular) ...[
                      DayIcon('wifi', size: 15, stroke: 1.6, color: tokens.ink),
                      const SizedBox(width: 6),
                    ],
                    _Battery(color: tokens.ink),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: IgnorePointer(
              child: Center(
                child: Container(
                  width: 134,
                  height: 5,
                  decoration: BoxDecoration(
                    color: tokens.ink.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Signal extends StatelessWidget {
  const _Signal({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 17,
      height: 11,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final h in [4.0, 6.0, 8.5, 11.0]) ...[
            Container(
              width: 3,
              height: h,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
            if (h != 11) const SizedBox(width: 1.5),
          ],
        ],
      ),
    );
  }
}

class _Battery extends StatelessWidget {
  const _Battery({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 12,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 22,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3.5),
                border: Border.all(color: color.withValues(alpha: 0.4)),
              ),
            ),
          ),
          Positioned(
            left: 2,
            top: 2,
            child: Container(
              width: 16,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 4,
            child: Container(
              width: 1.5,
              height: 4,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(0.7),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LinedPaper extends StatelessWidget {
  const LinedPaper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = TokenScope.of(context);
    if (!tokens.lined) return child;
    return CustomPaint(painter: _LinePainter(tokens.line), child: child);
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    // Handoff / prototype: 1px rule every 34px, first rule under the first line.
    for (double y = 33; y < size.height; y += 34) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_LinePainter oldDelegate) => oldDelegate.color != color;
}

class CaretMark extends StatelessWidget {
  const CaretMark({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 2,
      height: 22,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
