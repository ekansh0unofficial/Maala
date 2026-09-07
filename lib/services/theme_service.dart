import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_color_scheme/image_color_scheme.dart';
import 'package:maala_app/services/shared_pref_helper.dart';
import 'package:maala_app/themes/meditation_themes.dart';

/// Derives the app theme from the user-selected background image using
/// Material's dynamic color algorithm, so the accent/surface palette follows
/// the picture naturally.
class ThemeService {
  /// Fallback theme shown while the image-derived theme is computing (or if
  /// derivation fails). Uses the first curated theme as a neutral base.
  static final MeditationTheme _fallback = meditationThemes.first;

  static final ValueNotifier<MeditationTheme> themeNotifier =
      ValueNotifier<MeditationTheme>(_fallback);

  static MeditationTheme get current => themeNotifier.value;

  /// Builds an [ImageProvider] from a stored background path (asset or file).
  static ImageProvider imageProviderFor(String path) =>
      path.startsWith('assets/') ? AssetImage(path) : FileImage(File(path));

  /// Applies a previously cached derived theme (keyed by background path) if
  /// present and still matching. Call once during startup before [runApp].
  /// Returns true when the cache was used.
  static bool applyCachedTheme() {
    final path = SharedPrefHelper.getBackgroundImage();
    if (path == null) return false;
    final cachedPath = SharedPrefHelper.getThemeCacheBackgroundPath();
    if (cachedPath == null || cachedPath != path) return false;

    final primary = SharedPrefHelper.getThemeCachePrimaryAccent();
    final card = SharedPrefHelper.getThemeCacheCard();
    final nav = SharedPrefHelper.getThemeCacheNav();
    final background = SharedPrefHelper.getThemeCacheBackground();
    final surface = SharedPrefHelper.getThemeCacheSurface();
    final surfaceElevated = SharedPrefHelper.getThemeCacheSurfaceElevated();
    final border = SharedPrefHelper.getThemeCacheBorder();
    if (primary == null ||
        card == null ||
        nav == null ||
        background == null ||
        surface == null ||
        surfaceElevated == null ||
        border == null) {
      return false;
    }

    themeNotifier.value = _fromCached(ints: {
      'primary': primary,
      'card': card,
      'nav': nav,
      'background': background,
      'surface': surface,
      'surfaceElevated': surfaceElevated,
      'border': border,
    });
    return true;
  }

  static MeditationTheme _fromCached({required Map<String, int> ints}) =>
      MeditationTheme(
        name: 'Adaptive',
        primaryAccent: Color(ints['primary']!),
        overlayColor: Colors.black.withValues(alpha: 0.38),
        cardColor: Color(ints['card']!),
        navColor: Color(ints['nav']!),
        background: Color(ints['background']!),
        surface: Color(ints['surface']!),
        surfaceElevated: Color(ints['surfaceElevated']!),
        border: Color(ints['border']!),
        greeting: 'Adapted to your image',
      );

  /// Derives and publishes the theme from the currently selected background
  /// image. Call once during app startup after [SharedPrefHelper.init].
  static Future<void> initFromBackground() async {
    final path = SharedPrefHelper.getBackgroundImage();
    if (path == null) return;
    // Decode a small thumbnail instead of the full-resolution image. The
    // derived palette barely changes past ~64px and this keeps startup (and
    // memory) dramatically cheaper.
    final thumbnail = ResizeImage(
      imageProviderFor(path),
      width: 64,
      allowUpscaling: false,
    );
    try {
      final scheme = await computeColorSchemeFromImageProvider(
        thumbnail,
        Brightness.dark,
      );
      final theme = _fromScheme(scheme);
      themeNotifier.value = theme;
      SharedPrefHelper.saveThemeCache(backgroundPath: path, theme: theme);
    } catch (e) {
      debugPrint('Failed to derive theme from background image: $e');
    }
  }

  static MeditationTheme _fromScheme(ColorScheme s) => MeditationTheme(
    name: 'Adaptive',
    primaryAccent: s.primary,
    overlayColor: Colors.black.withValues(alpha: 0.38),
    cardColor: s.surfaceContainer.withValues(alpha: 0.9),
    navColor: s.surfaceContainer.withValues(alpha: 0.6),
    background: s.surface,
    surface: s.surfaceContainer,
    surfaceElevated: s.surfaceContainerHigh,
    border: s.outlineVariant,
    greeting: 'Adapted to your image',
  );
}
