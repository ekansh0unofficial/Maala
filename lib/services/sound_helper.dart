import 'package:audioplayers/audioplayers.dart';
import '../services/shared_pref_helper.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> play() async {
    try {
      final path = SharedPrefHelper.getSelectedSound();
      print("Selected Path: $path");
      if (path.isEmpty) return;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(path));
      _isPlaying = true;
    } catch (_) {}
  }

  static Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (_) {}
  }

  static bool get isPlaying => _isPlaying;
}
