import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static late SharedPreferences _prefs;

  // Keys
  static const _counterKey = 'counter';
  static const _countLimitKey = 'countLimit';

  static const _totalSecondsKey = 'timer_total_seconds';
  static const _remainingSecondsKey = 'timer_remaining_seconds';
  static const _timerRunningKey = 'is_timer_running';

  static const _hapticKey = 'haptic_enabled';
  static const _screenOnKey = 'keep_screen_on';

  static const _backgroundKey = 'selected_background';

  /// Call this once in app initialization or first screen
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Counter
  static int getCounter() => _prefs.getInt(_counterKey) ?? 0;
  static void setCounter(int value) => _prefs.setInt(_counterKey, value);
  static int? getCountLimit() => _prefs.getInt(_countLimitKey);
  static void setCountLimit(int value) => _prefs.setInt(_countLimitKey, value);

  //Timer
  static int getTotalSeconds() => _prefs.getInt(_totalSecondsKey) ?? 0;
  static void setTotalSeconds(int seconds) =>
      _prefs.setInt(_totalSecondsKey, seconds);

  static int getRemainingSeconds() => _prefs.getInt(_remainingSecondsKey) ?? 0;
  static void setRemainingSeconds(int seconds) =>
      _prefs.setInt(_remainingSecondsKey, seconds);

  static bool getTimerRunning() => _prefs.getBool(_timerRunningKey) ?? false;
  static void setTimerRunning(bool value) =>
      _prefs.setBool(_timerRunningKey, value);

  // Haptic toggle
  static bool getHapticEnabled() => _prefs.getBool(_hapticKey) ?? true;
  static void setHapticEnabled(bool value) => _prefs.setBool(_hapticKey, value);

  // Background image
  static String? getBackgroundImage() =>
      _prefs.getString(_backgroundKey) ?? 'assets/images/1.jpg';
  static void setBackgroundImage(String path) =>
      _prefs.setString(_backgroundKey, path);

  // Keep screen on
  static bool getKeepScreenOn() => _prefs.getBool(_screenOnKey) ?? false;
  static void setKeepScreenOn(bool value) =>
      _prefs.setBool(_screenOnKey, value);
}
