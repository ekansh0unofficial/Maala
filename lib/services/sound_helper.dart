import 'package:audioplayers/audioplayers.dart';
import '../services/shared_pref_helper.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> play() async {
    try {
      final assetPath = SharedPrefHelper.getSelectedSound();
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(assetPath));
      _isPlaying = true;
    } catch (e) {
      print("SoundHelper error while playing: $e");
    }
  }

  static Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      print("SoundHelper error while pausing: $e");
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      print("SoundHelper error while stopping: $e");
    }
  }

  static bool get isPlaying => _isPlaying;
}
