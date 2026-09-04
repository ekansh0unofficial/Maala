import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../services/shared_pref_helper.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _completionPlayer = AudioPlayer();
  static bool _isPlaying = false;

  static Future<void> play() async {
    try {
      final path = SharedPrefHelper.getSelectedSound();
      debugPrint('Selected soundtrack: $path');
      if (path.isEmpty) return;
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource(path));
      _isPlaying = true;
    } catch (e) {
      debugPrint('Sound playback failed: $e');
      _isPlaying = false;
    }
  }

  static Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Sound pause failed: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
    } catch (e) {
      debugPrint('Sound stop failed: $e');
    }
  }

  static Future<void> playCompletionGong() async {
    try {
      await _completionPlayer.stop();
      await _completionPlayer.play(AssetSource('audio/1.mp3'));
    } catch (e) {
      debugPrint('Completion sound failed: $e');
    }
  }

  static bool get isPlaying => _isPlaying;
}
