import 'package:flutter/material.dart';
import '../themes/meditation_themes.dart';

/// Catalog of the app's ambient soundtrack assets.
///
/// Audio files follow a snake_case descriptive naming convention (e.g.
/// `Calm_Nighttime_Chirps.mp3`). Display titles are derived from the file
/// names at runtime, so renaming an asset updates the UI automatically.
class SoundOption {
  final String path;
  final String themeName;

  const SoundOption({required this.path, required this.themeName});

  /// Human-readable title derived from the asset's snake_case file name.
  String get title {
    final fileName = path.split('/').last.replaceAll('.mp3', '');
    return fileName
        .split('_')
        .map(
          (word) => word.isEmpty
              ? word
              : word == word.toUpperCase()
                  ? word
                  : word[0].toUpperCase() + word.substring(1),
        )
        .join(' ');
  }

  /// Accent color of the theme this soundtrack pairs best with.
  Color get themeAccent =>
      meditationThemes.firstWhere((t) => t.name == themeName).primaryAccent;
}

const List<SoundOption> soundOptions = [
  SoundOption(path: 'audio/Calm_Nighttime_Chirps.mp3', themeName: 'Cosmos'),
  SoundOption(path: 'audio/Coastal_Cave_Ambience.mp3', themeName: 'Ocean'),
  SoundOption(
    path: 'audio/Gentle_Background_Meditation.mp3',
    themeName: 'Lotus',
  ),
  SoundOption(path: 'audio/Quiet_Bamboo_Forest.mp3', themeName: 'Forest'),
  SoundOption(path: 'audio/Serene_Green_Forest.mp3', themeName: 'Forest'),
  SoundOption(path: 'audio/Silent_Mountain_Calm.mp3', themeName: 'Midnight'),
  SoundOption(path: 'audio/Tibetan_Singing_Bowls.mp3', themeName: 'Dawn'),
  SoundOption(
    path: 'audio/Traditional_Meditation_Tanpura.mp3',
    themeName: 'Midnight',
  ),
];

/// Default soundtrack used when nothing is selected (or a saved selection
/// no longer exists).
const String defaultSoundPath = 'audio/Calm_Nighttime_Chirps.mp3';

/// The ambient drone played when a session completes.
const String completionSoundPath = 'audio/Tibetan_Singing_Bowls.mp3';

bool isKnownSoundPath(String path) =>
    soundOptions.any((option) => option.path == path);