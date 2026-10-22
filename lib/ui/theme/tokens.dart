import 'dart:math' as math;

import 'package:flutter/material.dart';

enum ThemeId {
  a('A', '晨雾', null, true),
  bl('Bl', '夜灯', '浅色', true),
  bd('Bd', '夜灯', '深色', false),
  c('C', '水彩手账', null, true),
  d('D', '素白', null, true),
  e('E', '墨夜', null, false);

  const ThemeId(this.wire, this.name, this.subtitle, this.isLight);

  final String wire;
  final String name;
  final String? subtitle;
  final bool isLight;

  String get displayName => subtitle == null ? name : '$name·$subtitle';

  static ThemeId? parse(String? raw) {
    if (raw == null) return null;
    for (final id in ThemeId.values) {
      if (id.wire == raw) return id;
    }
    return null;
  }

  static const lightChoices = [ThemeId.a, ThemeId.bl, ThemeId.c, ThemeId.d];
  static const darkChoices = [ThemeId.bd, ThemeId.e];
}

enum DecoKind { none, mist, lampLight, lampDark, watercolor }

enum OrbKind { radial, sweep }

class OrbSpec {
  const OrbSpec({
    required this.kind,
    required this.colors,
    required this.stops,
    required this.glow,
    this.center = const Alignment(-0.3, -0.3),
    this.startAngle = 0,
  });

  final OrbKind kind;
  final List<Color> colors;
  final List<double> stops;
  final Color glow;
  final Alignment center;
  final double startAngle;
}

class DayfordTokens {
  const DayfordTokens({
    required this.id,
    required this.brightness,
    required this.bg,
    required this.card,
    required this.ink,
    required this.ink2,
    required this.ink3,
    required this.accent,
    required this.accentText,
    required this.chip,
    required this.buttonFg,
    required this.buttonSolid,
    required this.buttonGradient,
    required this.buttonBorder,
    required this.buttonShadow,
    required this.cardBorder,
    required this.cardShadow,
    required this.line,
    required this.line2,
    required this.danger,
    required this.tagBg,
    required this.tagFg,
    required this.rule,
    required this.showRule,
    required this.lined,
    required this.monoDots,
    required this.dots,
    required this.segOn,
    required this.segShadow,
    required this.orb,
    required this.deco,
  });

  final ThemeId id;
  final Brightness brightness;
  final Color bg;
  final Color card;
  final Color ink;
  final Color ink2;
  final Color ink3;
  final Color accent;
  final Color accentText;
  final Color chip;
  final Color buttonFg;
  final Color? buttonSolid;
  final LinearGradient? buttonGradient;
  final Border? buttonBorder;
  final List<BoxShadow> buttonShadow;
  final Border? cardBorder;
  final List<BoxShadow> cardShadow;
  final Color line;
  final Color line2;
  final Color danger;
  final Color tagBg;
  final Color tagFg;
  final Color rule;
  final bool showRule;
  final bool lined;
  final bool monoDots;
  final List<Color> dots;
  final Color segOn;
  final List<BoxShadow> segShadow;
  final OrbSpec orb;
  final DecoKind deco;

  bool get isDark => brightness == Brightness.dark;

  BoxDecoration cardBox({double radius = 22}) => BoxDecoration(
    color: card,
    borderRadius: BorderRadius.circular(radius),
    border: cardBorder == null ? null : Border.fromBorderSide(cardBorder!.top),
    boxShadow: cardShadow,
  );

  static DayfordTokens of(ThemeId id) => switch (id) {
    ThemeId.a => a,
    ThemeId.bl => bl,
    ThemeId.bd => bd,
    ThemeId.c => c,
    ThemeId.d => d,
    ThemeId.e => e,
  };

  static const a = DayfordTokens(
    id: ThemeId.a,
    brightness: Brightness.light,
    bg: Color(0xFFF7F3EE),
    card: Color.fromRGBO(255, 255, 255, 0.72),
    ink: Color(0xFF33302C),
    ink2: Color(0xFF6E6862),
    ink3: Color(0xFF7E7770),
    accent: Color(0xFF7FA087),
    accentText: Color(0xFF52775F),
    chip: Color.fromRGBO(51, 48, 44, 0.06),
    buttonFg: Color(0xFFFFFFFF),
    buttonSolid: null,
    buttonGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF698C73), Color(0xFF5A7E67)],
    ),
    buttonBorder: null,
    buttonShadow: [
      BoxShadow(
        color: Color.fromRGBO(94, 130, 107, 0.22),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
    cardBorder: null,
    cardShadow: [
      BoxShadow(
        color: Color.fromRGBO(80, 60, 40, 0.04),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
      BoxShadow(
        color: Color.fromRGBO(80, 60, 40, 0.05),
        blurRadius: 20,
        offset: Offset(0, 6),
      ),
    ],
    line: Color.fromRGBO(51, 48, 44, 0.07),
    line2: Color.fromRGBO(51, 48, 44, 0.12),
    danger: Color(0xFFA85A46),
    tagBg: Color.fromRGBO(127, 160, 135, 0.18),
    tagFg: Color(0xFF46695A),
    rule: Color(0x00000000),
    showRule: false,
    lined: false,
    monoDots: false,
    dots: [
      Color(0xFF7FA087),
      Color(0xFFE8A48A),
      Color(0xFFA79BC8),
      Color(0xFF8EA9C1),
    ],
    segOn: Color(0xFFFFFFFF),
    segShadow: [
      BoxShadow(
        color: Color.fromRGBO(80, 60, 40, 0.12),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
    orb: OrbSpec(
      kind: OrbKind.radial,
      colors: [Color(0xFFF6D5C4), Color(0xFFE8A48A), Color(0xFFC9B8E0)],
      stops: [0, 0.6, 1],
      glow: Color.fromRGBO(232, 164, 138, 0.45),
    ),
    deco: DecoKind.mist,
  );

  static const bl = DayfordTokens(
    id: ThemeId.bl,
    brightness: Brightness.light,
    bg: Color(0xFFFBF4EA),
    card: Color(0xFFFFFCF7),
    ink: Color(0xFF3A2F2A),
    ink2: Color(0xFF75675C),
    ink3: Color(0xFF857669),
    accent: Color(0xFFEBA56E),
    accentText: Color(0xFFA0623A),
    chip: Color.fromRGBO(58, 47, 42, 0.06),
    buttonFg: Color(0xFF2A2230),
    buttonSolid: null,
    buttonGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF6C894), Color(0xFFEBA56E)],
    ),
    buttonBorder: null,
    buttonShadow: [
      BoxShadow(
        color: Color.fromRGBO(235, 165, 110, 0.30),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
    cardBorder: null,
    cardShadow: [
      BoxShadow(
        color: Color.fromRGBO(120, 80, 40, 0.05),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
      BoxShadow(
        color: Color.fromRGBO(120, 80, 40, 0.07),
        blurRadius: 20,
        offset: Offset(0, 6),
      ),
    ],
    line: Color.fromRGBO(58, 47, 42, 0.08),
    line2: Color.fromRGBO(58, 47, 42, 0.13),
    danger: Color(0xFFA8525A),
    tagBg: Color.fromRGBO(235, 165, 110, 0.22),
    tagFg: Color(0xFF8A5230),
    rule: Color(0x00000000),
    showRule: false,
    lined: false,
    monoDots: false,
    dots: [
      Color(0xFFEBA56E),
      Color(0xFFDE8C93),
      Color(0xFF8DBA94),
      Color(0xFF9DB4DC),
    ],
    segOn: Color(0xFFFFFCF7),
    segShadow: [
      BoxShadow(
        color: Color.fromRGBO(120, 80, 40, 0.14),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
    orb: OrbSpec(
      kind: OrbKind.radial,
      center: Alignment(-0.2, -0.3),
      colors: [Color(0xFFFFE6C2), Color(0xFFF2B880), Color(0xFFE59AA0)],
      stops: [0, 0.55, 1],
      glow: Color.fromRGBO(235, 165, 110, 0.5),
    ),
    deco: DecoKind.lampLight,
  );

  static const bd = DayfordTokens(
    id: ThemeId.bd,
    brightness: Brightness.dark,
    bg: Color(0xFF1C2030),
    card: Color.fromRGBO(255, 255, 255, 0.05),
    ink: Color(0xFFF1ECE3),
    ink2: Color(0xFFB9B3AA),
    ink3: Color(0xFF8A8693),
    accent: Color(0xFFF2B880),
    accentText: Color(0xFFF2B880),
    chip: Color.fromRGBO(241, 236, 227, 0.07),
    buttonFg: Color(0xFF2A2230),
    buttonSolid: null,
    buttonGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFF6C894), Color(0xFFEBA56E)],
    ),
    buttonBorder: null,
    buttonShadow: [
      BoxShadow(
        color: Color.fromRGBO(242, 184, 128, 0.16),
        blurRadius: 18,
        offset: Offset(0, 6),
      ),
    ],
    cardBorder: Border.fromBorderSide(
      BorderSide(color: Color.fromRGBO(255, 255, 255, 0.06)),
    ),
    cardShadow: [],
    line: Color.fromRGBO(255, 255, 255, 0.07),
    line2: Color.fromRGBO(255, 255, 255, 0.12),
    danger: Color(0xFFE59AA0),
    tagBg: Color.fromRGBO(242, 184, 128, 0.16),
    tagFg: Color(0xFFF6C894),
    rule: Color(0x00000000),
    showRule: false,
    lined: false,
    monoDots: false,
    dots: [
      Color(0xFFF2B880),
      Color(0xFFE59AA0),
      Color(0xFF9CC5A1),
      Color(0xFFAFC3E6),
    ],
    segOn: Color.fromRGBO(255, 255, 255, 0.12),
    segShadow: [],
    orb: OrbSpec(
      kind: OrbKind.radial,
      center: Alignment(-0.2, -0.3),
      colors: [Color(0xFFFFE6C2), Color(0xFFF2B880), Color(0xFFE59AA0)],
      stops: [0, 0.55, 1],
      glow: Color.fromRGBO(242, 184, 128, 0.45),
    ),
    deco: DecoKind.lampDark,
  );

  static const c = DayfordTokens(
    id: ThemeId.c,
    brightness: Brightness.light,
    bg: Color(0xFFFBF9F4),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF2F2D2A),
    ink2: Color(0xFF6A655E),
    ink3: Color(0xFF7C766C),
    accent: Color(0xFFE58D7A),
    accentText: Color(0xFFB05A48),
    chip: Color.fromRGBO(47, 45, 42, 0.05),
    buttonFg: Color(0xFFFFFFFF),
    buttonSolid: null,
    buttonGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFC66C59), Color(0xFFB65F4D)],
    ),
    buttonBorder: null,
    buttonShadow: [
      BoxShadow(
        color: Color.fromRGBO(191, 103, 84, 0.20),
        blurRadius: 16,
        offset: Offset(0, 6),
      ),
    ],
    cardBorder: null,
    cardShadow: [
      BoxShadow(
        color: Color.fromRGBO(60, 40, 20, 0.05),
        blurRadius: 2,
        offset: Offset(0, 1),
      ),
      BoxShadow(
        color: Color.fromRGBO(60, 40, 20, 0.05),
        blurRadius: 14,
        offset: Offset(0, 4),
      ),
    ],
    line: Color.fromRGBO(47, 45, 42, 0.07),
    line2: Color.fromRGBO(47, 45, 42, 0.12),
    danger: Color(0xFFA84E3C),
    tagBg: Color.fromRGBO(229, 141, 122, 0.18),
    tagFg: Color(0xFF9A4B3B),
    rule: Color(0x00000000),
    showRule: false,
    lined: true,
    monoDots: false,
    dots: [
      Color(0xFFE58D7A),
      Color(0xFF6FB3B8),
      Color(0xFFE9C46A),
      Color(0xFFB39DDB),
    ],
    segOn: Color(0xFFFFFFFF),
    segShadow: [
      BoxShadow(
        color: Color.fromRGBO(60, 40, 20, 0.12),
        blurRadius: 3,
        offset: Offset(0, 1),
      ),
    ],
    orb: OrbSpec(
      kind: OrbKind.sweep,
      colors: [
        Color(0xFFE58D7A),
        Color(0xFFE9C46A),
        Color(0xFF6FB3B8),
        Color(0xFFB39DDB),
        Color(0xFFE58D7A),
      ],
      stops: [0, 0.25, 0.5, 0.75, 1],
      glow: Color.fromRGBO(229, 141, 122, 0.4),
      startAngle: math.pi / 6,
    ),
    deco: DecoKind.watercolor,
  );

  static const d = DayfordTokens(
    id: ThemeId.d,
    brightness: Brightness.light,
    bg: Color(0xFFFBFAF8),
    card: Color(0xFFFFFFFF),
    ink: Color(0xFF141414),
    ink2: Color(0xFF5C5C5C),
    ink3: Color(0xFF767676),
    accent: Color(0xFF141414),
    accentText: Color(0xFF141414),
    chip: Color.fromRGBO(20, 20, 20, 0.05),
    buttonFg: Color(0xFFFBFAF8),
    buttonSolid: Color(0xFF141414),
    buttonGradient: null,
    buttonBorder: null,
    buttonShadow: [],
    cardBorder: Border.fromBorderSide(
      BorderSide(color: Color.fromRGBO(20, 20, 20, 0.08)),
    ),
    cardShadow: [],
    line: Color.fromRGBO(20, 20, 20, 0.08),
    line2: Color.fromRGBO(20, 20, 20, 0.14),
    danger: Color(0xFF8C3B2E),
    tagBg: Color(0xFF141414),
    tagFg: Color(0xFFFBFAF8),
    rule: Color(0xFF141414),
    showRule: true,
    lined: false,
    monoDots: true,
    dots: [],
    segOn: Color(0xFFFFFFFF),
    segShadow: [
      BoxShadow(color: Color.fromRGBO(20, 20, 20, 0.10), spreadRadius: 1),
    ],
    orb: OrbSpec(
      kind: OrbKind.radial,
      colors: [Color(0xFFFFFFFF), Color(0xFF141414), Color(0xFF141414)],
      stops: [0, 0.7, 1],
      glow: Color.fromRGBO(20, 20, 20, 0.18),
    ),
    deco: DecoKind.none,
  );

  static const e = DayfordTokens(
    id: ThemeId.e,
    brightness: Brightness.dark,
    bg: Color(0xFF0C0C0C),
    card: Color(0xFF151515),
    ink: Color(0xFFE9E9E6),
    ink2: Color(0xFF9A9A96),
    ink3: Color(0xFF7A7671),
    accent: Color(0xFFE9E9E6),
    accentText: Color(0xFFE9E9E6),
    chip: Color.fromRGBO(255, 255, 255, 0.06),
    buttonFg: Color(0xFFE9E9E6),
    buttonSolid: Color(0x00000000),
    buttonGradient: null,
    buttonBorder: Border.fromBorderSide(
      BorderSide(color: Color(0xFFE9E9E6), width: 1.5),
    ),
    buttonShadow: [],
    cardBorder: Border.fromBorderSide(
      BorderSide(color: Color.fromRGBO(255, 255, 255, 0.08)),
    ),
    cardShadow: [],
    line: Color.fromRGBO(255, 255, 255, 0.07),
    line2: Color.fromRGBO(255, 255, 255, 0.14),
    danger: Color(0xFFD99A8F),
    tagBg: Color.fromRGBO(255, 255, 255, 0.10),
    tagFg: Color(0xFFE9E9E6),
    rule: Color.fromRGBO(233, 233, 230, 0.6),
    showRule: true,
    lined: false,
    monoDots: true,
    dots: [],
    segOn: Color(0xFF262626),
    segShadow: [
      BoxShadow(color: Color.fromRGBO(255, 255, 255, 0.10), spreadRadius: 1),
    ],
    orb: OrbSpec(
      kind: OrbKind.radial,
      colors: [Color(0xFFFFFFFF), Color(0xFF5E5E5B), Color(0xFF5E5E5B)],
      stops: [0, 0.75, 1],
      glow: Color.fromRGBO(233, 233, 230, 0.18),
    ),
    deco: DecoKind.none,
  );

  static DayfordTokens lerp(DayfordTokens a, DayfordTokens b, double t) {
    if (t <= 0) return a;
    if (t >= 1) return b;
    Color mix(Color x, Color y) => Color.lerp(x, y, t)!;
    final useB = t >= 0.5;
    final source = useB ? b : a;
    return DayfordTokens(
      id: source.id,
      brightness: source.brightness,
      bg: mix(a.bg, b.bg),
      card: mix(a.card, b.card),
      ink: mix(a.ink, b.ink),
      ink2: mix(a.ink2, b.ink2),
      ink3: mix(a.ink3, b.ink3),
      accent: mix(a.accent, b.accent),
      accentText: mix(a.accentText, b.accentText),
      chip: mix(a.chip, b.chip),
      buttonFg: mix(a.buttonFg, b.buttonFg),
      buttonSolid: _lerpColorN(a.buttonSolid, b.buttonSolid, t),
      buttonGradient: _lerpGradient(a.buttonGradient, b.buttonGradient, t),
      buttonBorder: useB ? b.buttonBorder : a.buttonBorder,
      buttonShadow: useB ? b.buttonShadow : a.buttonShadow,
      cardBorder: useB ? b.cardBorder : a.cardBorder,
      cardShadow: useB ? b.cardShadow : a.cardShadow,
      line: mix(a.line, b.line),
      line2: mix(a.line2, b.line2),
      danger: mix(a.danger, b.danger),
      tagBg: mix(a.tagBg, b.tagBg),
      tagFg: mix(a.tagFg, b.tagFg),
      rule: mix(a.rule, b.rule),
      showRule: source.showRule,
      lined: source.lined,
      monoDots: source.monoDots,
      dots: source.dots,
      segOn: mix(a.segOn, b.segOn),
      segShadow: useB ? b.segShadow : a.segShadow,
      orb: source.orb,
      deco: source.deco,
    );
  }
}

Color? _lerpColorN(Color? a, Color? b, double t) {
  if (a == null && b == null) return null;
  if (a == null || b == null) return t < 0.5 ? a : b;
  return Color.lerp(a, b, t);
}

LinearGradient? _lerpGradient(LinearGradient? a, LinearGradient? b, double t) {
  if (a == null && b == null) return null;
  if (a == null || b == null) return t < 0.5 ? a : b;
  final count = math.max(a.colors.length, b.colors.length);
  final colors = <Color>[];
  for (var i = 0; i < count; i++) {
    final left = a.colors[math.min(i, a.colors.length - 1)];
    final right = b.colors[math.min(i, b.colors.length - 1)];
    colors.add(Color.lerp(left, right, t)!);
  }
  return LinearGradient(begin: a.begin, end: a.end, colors: colors);
}

class DecoPainter extends CustomPainter {
  DecoPainter(this.tokens);

  final DayfordTokens tokens;

  @override
  void paint(Canvas canvas, Size size) {
    switch (tokens.deco) {
      case DecoKind.none:
        return;
      case DecoKind.mist:
        _mist(canvas, size);
      case DecoKind.lampLight:
        _lamp(canvas, size, light: true);
      case DecoKind.lampDark:
        _lamp(canvas, size, light: false);
      case DecoKind.watercolor:
        _watercolor(canvas, size);
    }
  }

  void _mist(Canvas canvas, Size size) {
    canvas.saveLayer(
      Offset.zero & size,
      Paint()..color = const Color.fromRGBO(255, 255, 255, 0.55),
    );
    final blur = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);
    void blob(double x, double y, double r, Color color) {
      blur.color = color;
      canvas.drawCircle(
        Offset(size.width * x, size.height * y),
        r * size.width / 353,
        blur,
      );
    }

    blob(300 / 353, 90 / 790, 90, const Color(0xFFF3CDBB));
    blob(40 / 353, 300 / 790, 80, const Color(0xFFD6E3D5));
    blob(320 / 353, 640 / 790, 100, const Color(0xFFDCD4EC));
    canvas.restore();
  }

  void _lamp(Canvas canvas, Size size, {required bool light}) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.7, -0.96),
        radius: light ? 0.8 : 0.75,
        colors: [
          const Color(0xFFF2B880).withValues(alpha: light ? 0.34 : 0.32),
          const Color(0xFFE59AA0).withValues(alpha: light ? 0.10 : 0.08),
          const Color(0x00000000),
        ],
        stops: const [0, 0.45, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);
    if (light) return;
    final star = Paint()
      ..color = const Color(0xFFF1ECE3).withValues(alpha: 0.35);
    const stars = [
      [40.0, 120.0, 1.4],
      [90.0, 60.0, 1.0],
      [200.0, 140.0, 1.4],
      [60.0, 420.0, 1.0],
      [300.0, 380.0, 1.4],
      [150.0, 700.0, 1.0],
      [280.0, 560.0, 1.4],
    ];
    for (final item in stars) {
      canvas.drawCircle(
        Offset(size.width * item[0] / 353, size.height * item[1] / 790),
        item[2],
        star,
      );
    }
  }

  void _watercolor(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    void blob(double x, double y, double rx, double ry, Color color) {
      paint.color = color;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * x, size.height * y),
          width: rx * 2 * size.width / 353,
          height: ry * 2 * size.height / 790,
        ),
        paint,
      );
    }

    blob(
      318 / 353,
      70 / 790,
      70,
      46,
      const Color(0xFFF5C9BD).withValues(alpha: 0.55),
    );
    blob(
      282 / 353,
      42 / 790,
      34,
      24,
      const Color(0xFFF6E2A6).withValues(alpha: 0.60),
    );
    blob(
      22 / 353,
      760 / 790,
      80,
      50,
      const Color(0xFFC6E3E2).withValues(alpha: 0.75),
    );
    blob(
      82 / 353,
      780 / 790,
      40,
      26,
      const Color(0xFFDCD0EF).withValues(alpha: 0.75),
    );
  }

  @override
  bool shouldRepaint(DecoPainter oldDelegate) =>
      oldDelegate.tokens.id != tokens.id;
}
