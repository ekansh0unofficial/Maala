import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:maala_app/home.dart';
import 'package:maala_app/services/localization_service.dart';
import 'package:maala_app/services/screen_awake_service.dart';
import 'package:maala_app/services/shared_pref_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefHelper.init();
  if (SharedPrefHelper.getKeepScreenOn()) {
    await ScreenAwakeService.enable();
  }
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: AppLocalizations.languageNotifier,
      builder: (context, langCode, _) {
        return MaterialApp(
          home: const HomeScreen(),
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
