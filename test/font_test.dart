import 'dart:ui' as ui;

import 'package:dayford/ui/theme/scope.dart';
import 'package:dayford/ui/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('body font is the bundled Noto Serif SC', () async {
    final body = DayfordStyles(DayfordTokens.d).serif(size: 18, line: 34);
    expect(body.fontFamily, 'Noto Serif SC');
    expect(body.decoration, TextDecoration.none);

    for (final asset in [
      'assets/fonts/NotoSerifSC-Regular.ttf',
      'assets/fonts/NotoSerifSC-SemiBold.ttf',
    ]) {
      final data = await rootBundle.load(asset);
      expect(data.lengthInBytes, greaterThan(100000), reason: asset);
      expect(data.getUint32(0), 0x00010000, reason: asset);
    }
  });

  testWidgets('bundled serif draws hanzi instead of boxes', (tester) async {
    final loader = FontLoader('Noto Serif SC');
    for (final asset in [
      'assets/fonts/NotoSerifSC-Regular.ttf',
      'assets/fonts/NotoSerifSC-SemiBold.ttf',
    ]) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();

    await _expectGlyph(tester, '今', FontWeight.w400);
    await _expectGlyph(tester, '今', FontWeight.w600);
    await _expectGlyph(tester, '写', FontWeight.w400);
    await _expectGlyph(tester, '外', FontWeight.w600);
  });
}

Future<void> _expectGlyph(
  WidgetTester tester,
  String text,
  FontWeight weight,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: RepaintBoundary(
          child: ColoredBox(
            color: const Color(0xFFFFFFFF),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Noto Serif SC',
                fontSize: 48,
                fontWeight: weight,
                color: const Color(0xFF141414),
                decoration: TextDecoration.none,
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byType(RepaintBoundary).last,
  );
  final image = await boundary.toImage(pixelRatio: 1);
  final width = image.width;
  final height = image.height;
  final data = await tester.runAsync(
    () => image.toByteData(format: ui.ImageByteFormat.rawRgba),
  );
  image.dispose();
  final bytes = data!.buffer.asUint8List();
  expect(
    _isMissingGlyphBox(bytes, width, height),
    isFalse,
    reason: '$text $weight rendered as a missing-glyph box',
  );
}

bool _isMissingGlyphBox(Uint8List bytes, int width, int height) {
  bool ink(int x, int y) => bytes[(y * width + x) * 4] < 100;
  var minX = width;
  var minY = height;
  var maxX = 0;
  var maxY = 0;
  var dark = 0;
  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      if (!ink(x, y)) continue;
      dark++;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }
  if (dark < 40) return true;
  final gw = maxX - minX + 1;
  final gh = maxY - minY + 1;
  if (gw < 8 || gh < 8) return true;
  var barRows = 0;
  var railRows = 0;
  var midRows = 0;
  for (var y = minY; y <= maxY; y++) {
    var count = 0;
    var left = false;
    var right = false;
    var mid = false;
    for (var x = minX; x <= maxX; x++) {
      if (!ink(x, y)) continue;
      count++;
      final t = (x - minX) / gw;
      if (t < 0.2) {
        left = true;
      } else if (t > 0.8) {
        right = true;
      } else {
        mid = true;
      }
    }
    if (count > gw * 0.82) barRows++;
    if (y > minY + gh * 0.22 && y < maxY - gh * 0.22) {
      midRows++;
      if (left && right && !mid) railRows++;
    }
  }
  return barRows >= 4 && midRows > 0 && railRows / midRows > 0.45;
}
