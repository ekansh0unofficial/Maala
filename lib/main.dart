import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maala_app/home.dart';
import 'package:maala_app/services/ad_service.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/screen_awake_service.dart';
import 'package:maala_app/services/shared_pref_helper.dart';
import 'package:maala_app/services/sound_helper.dart';
import 'package:maala_app/services/theme_service.dart';
import 'package:maala_app/timer_screen/timer_helper.dart';
import 'package:maala_app/widgets/background_image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefHelper.init();
  final themeCached = ThemeService.applyCachedTheme();
  runApp(MainApp(themeCached: themeCached));
}

class MainApp extends StatelessWidget {
  final bool themeCached;

  const MainApp({super.key, required this.themeCached});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.languageNotifier,
      builder: (context, langCode, _) {
        return MaterialApp(
          home: _StartupInitializer(themeCached: themeCached),
          debugShowCheckedModeBanner: false,
          locale: Locale(langCode),
          supportedLocales: const [
            Locale('en'),
            Locale('hi'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }
}

/// Kicks off the remaining background work after the first frame so nothing
/// blocks initial render: derived theme, ads, keep-screen-on.
class _StartupInitializer extends StatefulWidget {
  final bool themeCached;

  const _StartupInitializer({required this.themeCached});

  @override
  State<_StartupInitializer> createState() => _StartupInitializerState();
}

class _StartupInitializerState extends State<_StartupInitializer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _postFrame());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause the meditation timer and silence the soundtrack whenever the app
    // leaves focus (backgrounded, app switcher, or closed).
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      if (TimerHelper.isRunning) TimerHelper.pause();
      if (SoundHelper.isPlaying) unawaited(SoundHelper.stop());
    }
  }

  void _postFrame() {
    unawaited(_postFrameTasks());
  }

  Future<void> _postFrameTasks() async {
    if (!widget.themeCached) {
      await _safeRun(ThemeService.initFromBackground);
    }
    // Warm the background image decode so the first screen appears (and the
    // first tap/swipe after launch) never pays a full decode on the UI thread.
    await _safeRun(_precacheBackground);
    await _safeRun(AdService.init);
    if (SharedPrefHelper.getKeepScreenOn()) {
      await _safeRun(ScreenAwakeService.enable);
    }
  }

  Future<void> _precacheBackground() async {
    final background = SharedPrefHelper.getBackgroundImage();
    if (background == null) return;
    final size = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final target =
        (math.max(size.width, size.height) * dpr).round();
    await precacheImage(
      BackgroundImage.providerFor(background, target: target),
      context,
    );
  }

  Future<void> _safeRun(Future<void> Function() task) async {
    try {
      await task();
    } catch (e) {
      debugPrint('Post-frame init failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}