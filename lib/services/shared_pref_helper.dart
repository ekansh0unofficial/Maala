import 'package:shared_preferences/shared_preferences.dart';
import '../themes/meditation_themes.dart';
import 'sound_catalog.dart';

class SharedPrefHelper {
  static late SharedPreferences _prefs;

  // Keys
  static const _counterKey = 'counter';
  static const _countLimitKey = 'countLimit';

  static const _totalSecondsKey = 'timer_total_seconds';
  static const _remainingSecondsKey = 'timer_remaining_seconds';
  static const _timerRunningKey = 'is_timer_running';
  static const _timerDeadlineKey = 'timer_deadline_ms';

  static const _hapticKey = 'haptic_enabled';
  static const _screenOnKey = 'keep_screen_on';

  static const _backgroundKey = 'selected_background';

  // Cached derived theme (warm-start fast path)
  static const _themeCacheBgKey = 'theme_cache_bg_path';
  static const _themeCachePrimaryKey = 'theme_cache_primary_accent';
  static const _themeCacheCardKey = 'theme_cache_card';
  static const _themeCacheNavKey = 'theme_cache_nav';
  static const _themeCacheBackgroundKey = 'theme_cache_background_color';
  static const _themeCacheSurfaceKey = 'theme_cache_surface';
  static const _themeCacheSurfaceElevatedKey = 'theme_cache_surface_elevated';
  static const _themeCacheBorderKey = 'theme_cache_border';

  static const _selectedSoundKey = 'selected_sound';

  // New keys
  static const _themeIndexKey = 'theme_index';
  static const _languageCodeKey = 'language_code';
  static const _totalChantsKey = 'total_chants';
  static const _totalMalasKey = 'total_malas';
  static const _sessionMalasKey = 'session_malas';
  static const _streakKey = 'streak';
  static const _lastPracticeDateKey = 'last_practice_date';
  static const _bestStreakKey = 'best_streak';
  static const _mantraTextKey = 'mantra_text';
  static const _focusModeKey = 'focus_mode';
  static const _todayMalasDateKey = 'today_malas_date';
  static const _todayMalasKey = 'today_malas';

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

  static int? getTimerDeadlineMs() => _prefs.getInt(_timerDeadlineKey);
  static void setTimerDeadlineMs(int ms) => _prefs.setInt(_timerDeadlineKey, ms);
  static void clearTimerDeadline() => _prefs.remove(_timerDeadlineKey);

  // Haptic toggle
  static bool getHapticEnabled() => _prefs.getBool(_hapticKey) ?? true;
  static void setHapticEnabled(bool value) => _prefs.setBool(_hapticKey, value);

  // Background image
  static String? getBackgroundImage() =>
      _prefs.getString(_backgroundKey) ?? 'assets/images/1.jpg';
  static void setBackgroundImage(String path) =>
      _prefs.setString(_backgroundKey, path);

  // Cached derived theme (warm-start fast path)
  static String? getThemeCacheBackgroundPath() =>
      _prefs.getString(_themeCacheBgKey);
  static int? getThemeCachePrimaryAccent() =>
      _prefs.getInt(_themeCachePrimaryKey);
  static int? getThemeCacheCard() => _prefs.getInt(_themeCacheCardKey);
  static int? getThemeCacheNav() => _prefs.getInt(_themeCacheNavKey);
  static int? getThemeCacheBackground() => _prefs.getInt(_themeCacheBackgroundKey);
  static int? getThemeCacheSurface() => _prefs.getInt(_themeCacheSurfaceKey);
  static int? getThemeCacheSurfaceElevated() =>
      _prefs.getInt(_themeCacheSurfaceElevatedKey);
  static int? getThemeCacheBorder() => _prefs.getInt(_themeCacheBorderKey);

  static void saveThemeCache({
    required String backgroundPath,
    required MeditationTheme theme,
  }) {
    _prefs.setString(_themeCacheBgKey, backgroundPath);
    _prefs.setInt(_themeCachePrimaryKey, theme.primaryAccent.toARGB32());
    _prefs.setInt(_themeCacheCardKey, theme.cardColor.toARGB32());
    _prefs.setInt(_themeCacheNavKey, theme.navColor.toARGB32());
    _prefs.setInt(
      _themeCacheBackgroundKey,
      theme.background.toARGB32(),
    );
    _prefs.setInt(_themeCacheSurfaceKey, theme.surface.toARGB32());
    _prefs.setInt(
      _themeCacheSurfaceElevatedKey,
      theme.surfaceElevated.toARGB32(),
    );
    _prefs.setInt(_themeCacheBorderKey, theme.border.toARGB32());
  }

  static void clearThemeCache() {
    _prefs.remove(_themeCacheBgKey);
    _prefs.remove(_themeCachePrimaryKey);
    _prefs.remove(_themeCacheCardKey);
    _prefs.remove(_themeCacheNavKey);
    _prefs.remove(_themeCacheBackgroundKey);
    _prefs.remove(_themeCacheSurfaceKey);
    _prefs.remove(_themeCacheSurfaceElevatedKey);
    _prefs.remove(_themeCacheBorderKey);
  }

  //Background Music
  static String getSelectedSound() {
    final saved = _prefs.getString(_selectedSoundKey);
    if (saved != null && isKnownSoundPath(saved)) return saved;
    return defaultSoundPath;
  }
  static void setSelectedSound(String path) =>
      _prefs.setString(_selectedSoundKey, path);

  // Keep screen on
  static bool getKeepScreenOn() => _prefs.getBool(_screenOnKey) ?? false;
  static void setKeepScreenOn(bool value) =>
      _prefs.setBool(_screenOnKey, value);

  // Theme
  static int getThemeIndex() => _prefs.getInt(_themeIndexKey) ?? 0;
  static void setThemeIndex(int value) => _prefs.setInt(_themeIndexKey, value);

  // Language
  static String? getLanguageCode() => _prefs.getString(_languageCodeKey);
  static void setLanguageCode(String value) =>
      _prefs.setString(_languageCodeKey, value);

  // Total chants (lifetime)
  static int getTotalChants() => _prefs.getInt(_totalChantsKey) ?? 0;
  static void setTotalChants(int value) => _prefs.setInt(_totalChantsKey, value);
  static void incrementTotalChants([int amount = 1]) {
    setTotalChants(getTotalChants() + amount);
  }

  // Total malas (lifetime)
  static int getTotalMalas() => _prefs.getInt(_totalMalasKey) ?? 0;
  static void setTotalMalas(int value) => _prefs.setInt(_totalMalasKey, value);
  static void incrementTotalMalas() {
    setTotalMalas(getTotalMalas() + 1);
  }

  // Session malas (resets each time app is freshly opened or counter manually reset)
  static int getSessionMalas() => _prefs.getInt(_sessionMalasKey) ?? 0;
  static void setSessionMalas(int value) => _prefs.setInt(_sessionMalasKey, value);
  static void incrementSessionMalas() {
    setSessionMalas(getSessionMalas() + 1);
  }
  static void resetSessionMalas() => _prefs.setInt(_sessionMalasKey, 0);

  // Today malas (date-scoped, rolls over at midnight)
  static String? getTodayMalasDate() => _prefs.getString(_todayMalasDateKey);
  static void setTodayMalasDate(String value) =>
      _prefs.setString(_todayMalasDateKey, value);
  static int getTodayMalas() => _prefs.getInt(_todayMalasKey) ?? 0;
  static void setTodayMalas(int value) => _prefs.setInt(_todayMalasKey, value);

  // Streak
  static int getStreak() => _prefs.getInt(_streakKey) ?? 0;
  static void setStreak(int value) => _prefs.setInt(_streakKey, value);

  static int getBestStreak() => _prefs.getInt(_bestStreakKey) ?? 0;
  static void setBestStreak(int value) => _prefs.setInt(_bestStreakKey, value);

  // Last practice date (YYYY-MM-DD)
  static String? getLastPracticeDate() => _prefs.getString(_lastPracticeDateKey);
  static void setLastPracticeDate(String value) =>
      _prefs.setString(_lastPracticeDateKey, value);

  // Mantra text
  static String getMantraText() => _prefs.getString(_mantraTextKey) ?? 'ॐ';
  static void setMantraText(String value) =>
      _prefs.setString(_mantraTextKey, value);

  // Focus mode
  static bool getFocusMode() => _prefs.getBool(_focusModeKey) ?? false;
  static void setFocusMode(bool value) => _prefs.setBool(_focusModeKey, value);
}
