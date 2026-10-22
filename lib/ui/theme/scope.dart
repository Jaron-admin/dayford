import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tokens.dart';

class TokenScope extends InheritedWidget {
  const TokenScope({super.key, required this.tokens, required super.child});

  final DayfordTokens tokens;

  static DayfordTokens of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TokenScope>();
    assert(scope != null, 'TokenScope missing');
    return scope!.tokens;
  }

  @override
  bool updateShouldNotify(TokenScope oldWidget) => oldWidget.tokens != tokens;
}

class AnimatedTokenHost extends StatefulWidget {
  const AnimatedTokenHost({
    super.key,
    required this.target,
    required this.child,
    this.animate = true,
  });

  final DayfordTokens target;
  final Widget child;
  final bool animate;

  @override
  State<AnimatedTokenHost> createState() => _AnimatedTokenHostState();
}

class _AnimatedTokenHostState extends State<AnimatedTokenHost>
    with SingleTickerProviderStateMixin {
  late DayfordTokens _from;
  late DayfordTokens _shown;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _from = widget.target;
    _shown = widget.target;
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 300),
        )..addListener(() {
          setState(() {
            _shown = DayfordTokens.lerp(
              _from,
              widget.target,
              _controller.value,
            );
          });
        });
  }

  @override
  void didUpdateWidget(AnimatedTokenHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target.id == widget.target.id &&
        oldWidget.target.bg == widget.target.bg) {
      return;
    }
    if (!widget.animate || MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      setState(() => _shown = widget.target);
      return;
    }
    _from = _shown;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = _shown.isDark;
    return TokenScope(
      tokens: _shown,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: _shown.bg,
          statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: _shown.bg,
          systemNavigationBarIconBrightness: dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarDividerColor: const Color(0x00000000),
          systemStatusBarContrastEnforced: false,
          systemNavigationBarContrastEnforced: false,
        ),
        child: widget.child,
      ),
    );
  }
}

class DayfordStyles {
  const DayfordStyles(this.tokens);

  final DayfordTokens tokens;

  static DayfordStyles of(BuildContext context) =>
      DayfordStyles(TokenScope.of(context));

  TextStyle serif({
    double size = 18,
    double? line,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: 'Noto Serif SC',
      fontFamilyFallback: const ['Songti SC', 'Noto Serif CJK SC', 'serif'],
      fontSize: size,
      height: line == null ? null : line / size,
      fontWeight: weight,
      color: color ?? tokens.ink,
      letterSpacing: letterSpacing,
    );
  }

  TextStyle sans({
    double size = 17,
    double? line,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: uiFontFamily(),
      fontFamilyFallback: const [
        'PingFang SC',
        'Noto Sans SC',
        'Noto Sans CJK',
        'sans-serif',
      ],
      fontSize: size,
      height: line == null ? null : line / size,
      fontWeight: weight,
      color: color ?? tokens.ink,
      letterSpacing: letterSpacing,
    );
  }
}

/// Android UI text uses the system Noto Sans CJK family. iOS uses PingFang,
/// matching the handoff. Goldens run as Android and load Noto Sans SC.
String uiFontFamily() {
  if (defaultTargetPlatform == TargetPlatform.iOS) return 'PingFang SC';
  return 'Noto Sans CJK SC';
}
