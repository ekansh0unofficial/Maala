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

  /// Derives and publishes the theme from the currently selected background
  /// image. Call once during app startup after [SharedPrefHelper.init].
  static Future<void> initFromBackground() async {
    final path = SharedPrefHelper.getBackgroundImage();
    if (path == null) return;
    try {
      final scheme = await computeColorSchemeFromImageProvider(
        imageProviderFor(path),
        Brightness.dark,
      );
      themeNotifier.value = _fromScheme(scheme);
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
