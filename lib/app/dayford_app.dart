import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../ui/theme/scope.dart';
import 'diary_controller.dart';
import 'diary_screens.dart';

class DayfordApp extends StatefulWidget {
  const DayfordApp({super.key, required this.controller});

  final DiaryController controller;

  @override
  State<DayfordApp> createState() => _DayfordAppState();
}

class _DayfordAppState extends State<DayfordApp> with WidgetsBindingObserver {
  DiaryController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    controller.removeListener(_rebuild);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      controller.flush();
    }
    if (state == AppLifecycleState.resumed) {
      controller.checkBoundary();
    }
  }

  @override
  void didChangePlatformBrightness() {
    controller.setBrightness(
      WidgetsBinding.instance.platformDispatcher.platformBrightness,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = controller.brightness == Brightness.dark;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dayford',
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      supportedLocales: const [Locale('zh'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale?.languageCode == 'zh') return const Locale('zh');
        if (locale == null) return const Locale('zh');
        return const Locale('en');
      },
      onGenerateTitle: (context) {
        final code = Localizations.localeOf(context).languageCode;
        return code == 'zh' ? '日济' : 'Dayford';
      },
      scrollBehavior: const DayfordScrollBehavior(),
      builder: (context, child) {
        return AnimatedTokenHost(
          target: controller.tokens,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: DiaryShell(controller: controller),
    );
  }
}

ThemeData _theme(Brightness brightness) {
  final light = brightness == Brightness.light;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    splashFactory: NoSplash.splashFactory,
    highlightColor: const Color(0x00000000),
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: light ? const Color(0xFF141414) : const Color(0xFFFBFAF8),
      onPrimary: light ? const Color(0xFFFBFAF8) : const Color(0xFF141414),
      secondary: light ? const Color(0xFF5C5C5C) : const Color(0xFFB5B5B5),
      onSecondary: light ? const Color(0xFFFBFAF8) : const Color(0xFF141414),
      error: const Color(0xFFA84E3C),
      onError: const Color(0xFFFFFFFF),
      surface: light ? const Color(0xFFFBFAF8) : const Color(0xFF0C0C0C),
      onSurface: light ? const Color(0xFF141414) : const Color(0xFFE8E8E6),
    ),
  );
}

class DayfordScrollBehavior extends MaterialScrollBehavior {
  const DayfordScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class DiaryShell extends StatelessWidget {
  const DiaryShell({super.key, required this.controller});

  final DiaryController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.loaded) {
      return const ColoredBox(color: Color(0xFFFBFAF8));
    }
    final sealed = controller.sealedFocus;
    if (sealed != null) {
      return SealedScreen(
        controller: controller,
        dayKey: sealed,
        startEditing: controller.appendComposer,
        navLabel: '今天',
        onBack: controller.leaveSealed,
      );
    }
    return TodayScreen(controller: controller);
  }
}
