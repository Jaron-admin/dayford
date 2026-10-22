import 'dart:ui' as ui;

import 'package:dayford/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await DecoAssets.ensureLoaded();
  });

  testWidgets('mist wash matches the prototype', (tester) async {
    await _expectWash(
      tester,
      DayfordTokens.a,
      {
        (0.85, 0.06): (245, 225, 214),
        (0.12, 0.38): (231, 235, 226),
        (0.85, 0.80): (232, 226, 236),
        (0.50, 0.40): (246, 242, 237),
      },
    );
  });

  testWidgets('lamp light is an ellipse, not a tight circle', (tester) async {
    await _expectWash(
      tester,
      DayfordTokens.bl,
      {
        (0.85, 0.06): (247, 224, 202),
        (0.70, 0.20): (247, 229, 218),
        (0.50, 0.40): (250, 241, 231),
        (0.12, 0.38): (251, 244, 234),
      },
    );
  });

  testWidgets('lamp dark is not a bright pink spot', (tester) async {
    await _expectWash(
      tester,
      DayfordTokens.bd,
      {
        (0.85, 0.06): (90, 75, 72),
        (0.70, 0.20): (63, 54, 65),
        (0.50, 0.40): (35, 36, 52),
        (0.12, 0.38): (28, 32, 48),
      },
    );
  });

  testWidgets('watercolor matches the handoff svg', (tester) async {
    await _expectWash(
      tester,
      DayfordTokens.c,
      {
        (0.85, 0.06): (248, 225, 185),
        (0.75, 0.05): (248, 236, 199),
        (0.92, 0.04): (250, 241, 235),
        (0.05, 0.96): (211, 233, 230),
      },
    );
  });
}

Future<void> _expectWash(
  WidgetTester tester,
  DayfordTokens tokens,
  Map<(double, double), (int, int, int)> samples,
) async {
  tester.view.devicePixelRatio = 1;
  await tester.binding.setSurfaceSize(const Size(353, 790));
  addTearDown(tester.view.reset);
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: RepaintBoundary(
        key: const Key('deco'),
        child: ColoredBox(
          color: tokens.bg,
          child: CustomPaint(
            painter: DecoPainter(tokens),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const Key('deco')),
  );
  final image = await boundary.toImage(pixelRatio: 1);
  final data = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  final width = image.width;
  final height = image.height;
  image.dispose();
  final bytes = data!.buffer.asUint8List();
  for (final entry in samples.entries) {
    final x = (entry.key.$1 * (width - 1)).round();
    final y = (entry.key.$2 * (height - 1)).round();
    final i = (y * width + x) * 4;
    final got = (bytes[i], bytes[i + 1], bytes[i + 2]);
    final want = entry.value;
    for (var channel = 0; channel < 3; channel++) {
      final delta = (got.$1 - want.$1).abs();
      final values = [got.$1, got.$2, got.$3];
      final targets = [want.$1, want.$2, want.$3];
      expect(
        (values[channel] - targets[channel]).abs(),
        lessThan(12),
        reason:
            '${tokens.id.wire} ${entry.key} got $got want $want (channel $channel delta $delta)',
      );
    }
  }
}
