import 'dart:io';

import 'package:dayford/constants/sample_copy.dart';
import 'package:dayford/services/model_manager.dart';
import 'package:dayford/ui/pages/journal_pages.dart';
import 'package:dayford/ui/pages/model_page.dart';
import 'package:dayford/ui/preview/state_catalog.dart';
import 'package:dayford/ui/theme/scope.dart';
import 'package:dayford/ui/theme/tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final sans = FontLoader('Noto Sans CJK SC');
    for (final name in ['NotoSansSC-Regular.ttf', 'NotoSansSC-SemiBold.ttf']) {
      final bytes = await File('third_party/fonts/noto-sans-sc/$name')
          .readAsBytes();
      sans.addFont(Future<ByteData>.value(ByteData.sublistView(bytes)));
    }
    await sans.load();
    // flutter test passes --disable-asset-fonts, so the pubspec family is
    // not registered unless we load the same bundled files ourselves.
    final serif = FontLoader('Noto Serif SC');
    for (final asset in [
      'assets/fonts/NotoSerifSC-Regular.ttf',
      'assets/fonts/NotoSerifSC-SemiBold.ttf',
    ]) {
      serif.addFont(rootBundle.load(asset));
    }
    await serif.load();
    goldenFileComparator = LocalFileComparator(
      Uri.parse('${Directory.current.path}/docs/screenshots/0.1/goldens.dart'),
    );
  });

  for (final theme in [ThemeId.d, ThemeId.e]) {
    for (final state in kPreviewStates) {
      testWidgets('$state-${theme.wire}', (tester) async {
        await _onAndroid(() async {
          await _pumpState(tester, state, theme);
          await _expectShot(
            tester,
            find.byType(StatePreview),
            '$state-${theme.wire}.png',
          );
        });
      });
    }
  }

  for (final theme in [ThemeId.a, ThemeId.bl, ThemeId.bd, ThemeId.c]) {
    for (final state in kExtraStates) {
      testWidgets('$state-${theme.wire}', (tester) async {
        await _onAndroid(() async {
          await _pumpState(tester, state, theme);
          await _expectShot(
            tester,
            find.byType(StatePreview),
            '$state-${theme.wire}.png',
          );
        });
      });
    }
  }

  testWidgets('android-delete-sheet', (tester) async {
    await _onAndroid(() async {
      await _prepareView(tester, bottom: 48);
      await tester.pumpWidget(
        _frame(
          home: TokenScope(
            tokens: DayfordTokens.d,
            child: ModelView(
              phase: ModelPhase.ready,
              onBack: () {},
              onDelete: () async {},
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.scrollUntilVisible(
        find.byKey(const Key('delete-model')),
        400,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.byKey(const Key('delete-model')));
      await tester.pumpAndSettle();
      await _expectShot(
        tester,
        find.byType(MaterialApp),
        'android-delete-sheet.png',
      );
    });
  });

  testWidgets('android-editor-inset', (tester) async {
    await _onAndroid(() async {
      await _prepareView(tester, bottom: 48);
      await tester.pumpWidget(
        _frame(
          home: const _GestureInset(
            child: TokenScope(
              tokens: DayfordTokens.d,
              child: TodayView(
                dateLine: '10月22日 · 周四',
                title: '今天',
                hint: '写一句也算一篇。',
                placeholder: '今天怎么样？随便写一句就好。',
                text: SampleCopy.entry,
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await _expectShot(
        tester,
        find.byType(MaterialApp),
        'android-editor-inset.png',
      );
    });
  });
}

Future<void> _expectShot(
  WidgetTester tester,
  Finder finder,
  String name,
) async {
  final element = tester.element(finder);
  var renderObject = element.renderObject!;
  while (!renderObject.isRepaintBoundary) {
    renderObject = renderObject.parent!;
  }
  final layer = renderObject.debugLayer! as OffsetLayer;
  final image = await layer.toImage(renderObject.paintBounds, pixelRatio: 3);
  try {
    await expectLater(image, matchesGoldenFile(name));
  } finally {
    image.dispose();
  }
}

Future<void> _onAndroid(Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.android;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

Future<void> _pumpState(
  WidgetTester tester,
  String state,
  ThemeId theme,
) async {
  await _prepareView(tester, bottom: 34);
  await tester.pumpWidget(
    _frame(
      home: StatePreview(stateId: state, themeId: theme),
    ),
  );
  await tester.pump();
}

Future<void> _prepareView(WidgetTester tester, {required double bottom}) async {
  tester.view.devicePixelRatio = 3;
  await tester.binding.setSurfaceSize(const Size(402, 874));
  final padding = FakeViewPadding(top: 50 * 3, bottom: bottom * 3);
  tester.view
    ..padding = padding
    ..viewPadding = padding;
  addTearDown(tester.view.reset);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _frame({required Widget home}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(platform: TargetPlatform.android, useMaterial3: true),
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(disableAnimations: true, textScaler: TextScaler.noScaling),
        child: child ?? const SizedBox.shrink(),
      );
    },
    home: home,
  );
}

/// Test-only stand-in for the Android gesture bar, drawn over the page inset.
class _GestureInset extends StatelessWidget {
  const _GestureInset({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        child,
        const Positioned(
          left: 0,
          right: 0,
          bottom: 8,
          child: IgnorePointer(
            child: Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0x47000000),
                  borderRadius: BorderRadius.all(Radius.circular(3)),
                ),
                child: SizedBox(width: 134, height: 5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
