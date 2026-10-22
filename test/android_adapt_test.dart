import 'package:dayford/services/model_manager.dart';
import 'package:dayford/ui/pages/journal_pages.dart';
import 'package:dayford/ui/pages/model_page.dart';
import 'package:dayford/ui/theme/scope.dart';
import 'package:dayford/ui/theme/tokens.dart';
import 'package:dayford/ui/widgets/chrome.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('one non-whitespace character enables 写好了', (tester) async {
    await tester.pumpWidget(
      _host(
        const TodayView(
          dateLine: '10月22日 · 周四',
          title: '今天',
          hint: '写一句也算一篇。',
          placeholder: '今天怎么样？随便写一句就好。',
          text: '好',
        ),
      ),
    );
    final button = tester.widget<DayfordButton>(
      find.byKey(const Key('finish-button')),
    );
    expect(button.enabled, isTrue);

    await tester.pumpWidget(
      _host(
        const TodayView(
          dateLine: '10月22日 · 周四',
          title: '今天',
          hint: '写一句也算一篇。',
          placeholder: '今天怎么样？随便写一句就好。',
          text: '  \n',
        ),
      ),
    );
    final empty = tester.widget<DayfordButton>(
      find.byKey(const Key('finish-button')),
    );
    expect(empty.enabled, isFalse);
  });

  testWidgets('写好了 sits above a gesture-bar inset', (tester) async {
    await _surface(tester, bottom: 48);
    await tester.pumpWidget(
      _host(
        const TodayView(
          dateLine: '10月22日 · 周四',
          title: '今天',
          hint: '写一句也算一篇。',
          placeholder: '今天怎么样？随便写一句就好。',
          text: '好',
        ),
      ),
    );
    final paddings = tester.widgetList<Padding>(find.byType(Padding));
    expect(
      paddings.any(
        (padding) =>
            padding.padding == const EdgeInsets.fromLTRB(26, 12, 26, 48),
      ),
      isTrue,
    );
  });

  testWidgets('an open keyboard drops the bar to 12', (tester) async {
    tester.view.devicePixelRatio = 1;
    await tester.binding.setSurfaceSize(const Size(402, 874));
    addTearDown(tester.view.reset);
    addTearDown(() => tester.binding.setSurfaceSize(null));
    tester.view.viewPadding = const FakeViewPadding(bottom: 48);
    tester.view.padding = const FakeViewPadding(bottom: 48);
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pumpWidget(
      _host(
        const TodayView(
          dateLine: '10月22日 · 周四',
          title: '今天',
          hint: '写一句也算一篇。',
          placeholder: '今天怎么样？随便写一句就好。',
          text: '好',
        ),
      ),
    );
    final paddings = tester.widgetList<Padding>(find.byType(Padding));
    expect(
      paddings.any(
        (padding) =>
            padding.padding == const EdgeInsets.fromLTRB(26, 12, 26, 12),
      ),
      isTrue,
    );
  });

  testWidgets('status bar color matches the page and icons follow the theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(),
        child: AnimatedTokenHost(
          target: DayfordTokens.d,
          animate: false,
          child: SizedBox.expand(),
        ),
      ),
    );
    final light = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(light.value.statusBarColor, DayfordTokens.d.bg);
    expect(light.value.statusBarIconBrightness, Brightness.dark);
    expect(light.value.systemNavigationBarColor, DayfordTokens.d.bg);

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(),
        child: AnimatedTokenHost(
          target: DayfordTokens.e,
          animate: false,
          child: SizedBox.expand(),
        ),
      ),
    );
    final dark = tester.widget<AnnotatedRegion<SystemUiOverlayStyle>>(
      find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
    );
    expect(dark.value.statusBarColor, DayfordTokens.e.bg);
    expect(dark.value.statusBarIconBrightness, Brightness.light);
  });

  testWidgets('Android delete confirmation uses the brick-red token', (
    tester,
  ) async {
    await _surface(tester, bottom: 48);
    await tester.pumpWidget(_modelApp(TargetPlatform.android));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete-model')),
      400,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const Key('delete-model')));
    await tester.pumpAndSettle();

    expect(find.text('删除「均衡」？'), findsOneWidget);
    final text = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const Key('confirm-delete')),
        matching: find.byType(Text),
      ),
    );
    expect(text.style?.color, DayfordTokens.d.danger);
    expect(find.byType(BottomSheet), findsOneWidget);
  });

  testWidgets('iOS delete confirmation stays an action sheet', (tester) async {
    await _surface(tester, bottom: 34);
    await tester.pumpWidget(_modelApp(TargetPlatform.iOS));
    await tester.pump();
    await tester.scrollUntilVisible(
      find.byKey(const Key('delete-model')),
      400,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const Key('delete-model')));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoActionSheet), findsOneWidget);
  });

  testWidgets('the back button and the system back key both pop', (
    tester,
  ) async {
    await _surface(tester, bottom: 34);
    await tester.pumpWidget(_navApp());
    await tester.tap(_settingsButton);
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsOneWidget);

    await tester.tap(find.text('今天'));
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsNothing);

    await tester.tap(_settingsButton);
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsNothing);

    await tester.tap(_settingsButton);
    await tester.pumpAndSettle();
    await tester.flingFrom(const Offset(4, 400), const Offset(180, 0), 2000);
    await tester.pumpAndSettle();
    expect(find.text('设置'), findsNothing);
  });
}

final _settingsButton = find.byWidgetPredicate(
  (widget) => widget is RoundIconButton && widget.label == '设置',
);

Future<void> _surface(WidgetTester tester, {required double bottom}) async {
  tester.view.devicePixelRatio = 1;
  await tester.binding.setSurfaceSize(const Size(402, 874));
  final padding = FakeViewPadding(top: 50, bottom: bottom);
  tester.view
    ..padding = padding
    ..viewPadding = padding;
  addTearDown(tester.view.reset);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

Widget _host(Widget child) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(platform: TargetPlatform.android, useMaterial3: true),
    home: TokenScope(tokens: DayfordTokens.d, child: child),
  );
}

Widget _modelApp(TargetPlatform platform) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(platform: platform, useMaterial3: true),
    home: TokenScope(
      tokens: DayfordTokens.d,
      child: ModelView(
        phase: ModelPhase.ready,
        onBack: () {},
        onDelete: () async {},
      ),
    ),
  );
}

Widget _navApp() {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(platform: TargetPlatform.android, useMaterial3: true),
    home: TokenScope(
      tokens: DayfordTokens.d,
      child: Builder(
        builder: (context) {
          return TodayView(
            dateLine: '10月22日 · 周四',
            title: '今天',
            hint: '写一句也算一篇。',
            placeholder: '今天怎么样？随便写一句就好。',
            text: '',
            onSettings: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (routeContext) => TokenScope(
                    tokens: DayfordTokens.d,
                    child: SettingsView(
                      appearanceLine: '浅色时 素白 · 深色时 墨夜',
                      modelLine: '均衡 · 正在使用',
                      onBack: () => Navigator.of(routeContext).pop(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    ),
  );
}
