import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'sound_catalog.dart';
import 'shared_pref_helper.dart';

class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();
  static final List<AudioPlayer> _completionPlayers = List.generate(
    completionRingCount,
    (_) => AudioPlayer(),
  );
  static bool _isPlaying = false;

  /// Completes when the timer-end alarm has finished playing its final ring.
  /// Null until [playTimerAlarm] is called for the current session.
  static Completer<void>? _alarmCompleter;

  /// Bumped to invalidate any in-flight alarm sequence (e.g. on explicit
  /// dismiss), so a stale run can never complete a newer session's cue.
  static int _alarmGeneration = 0;

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
      await _stopCompletionPlayers();
      await _completionPlayers[0].play(AssetSource(completionSoundPath));
    } catch (e) {
      debugPrint('Completion sound failed: $e');
    }
  }

  /// Plays the three completion bells as one atomic cue. Each bell has its
  /// own AudioPlayer so the 1-second overlap is real; starting the next bell
  /// does not stop the previous one. The returned Future completes only after
  /// the third bell has finished.
  static Future<void> playTimerAlarm() {
    final generation = ++_alarmGeneration;
    final completer = Completer<void>();
    _alarmCompleter = completer;

    unawaited(_runTimerAlarm(completer, generation));
    return completer.future;
  }

  static Future<void> get alarmEnd =>
      _alarmCompleter?.future ?? Future<void>.value();

  static Duration get _alarmTimeout {
    final gap = completionSoundLengthSeconds - completionRingOverlapSeconds;
    final totalSeconds =
        completionSoundLengthSeconds + (completionRingCount - 1) * gap;
    return Duration(seconds: totalSeconds + 5);
  }

  /// Stops every completion player and cancels the rest of the alarm sequence.
  static Future<void> stopTimerAlarm() async {
    ++_alarmGeneration;

    await _stopCompletionPlayers();

    final completer = _alarmCompleter;
    _alarmCompleter = null;
    if (completer != null && !completer.isCompleted) {
      completer.complete();
    }
  }

  static Future<void> _stopCompletionPlayers() async {
    for (final player in _completionPlayers) {
      try {
        await player.stop();
      } catch (e) {
        debugPrint('Stop completion sound failed: $e');
      }
    }
  }

  static Future<void> _runTimerAlarm(
    Completer<void> completer,
    int generation,
  ) async {
    try {
      final gap = completionSoundLengthSeconds - completionRingOverlapSeconds;

      // Start each bell on its own player. This is essential for overlap.
      for (var i = 0; i < completionRingCount; i++) {
        if (generation != _alarmGeneration) return;

        if (i > 0) {
          await Future<void>.delayed(Duration(seconds: gap));
          if (generation != _alarmGeneration) return;
        }

        await _completionPlayers[i].play(AssetSource(completionSoundPath));
      }

      // The third bell starts after the two gaps. Keep the completion future
      // pending until its full configured duration has elapsed.
      await Future<void>.delayed(
        Duration(seconds: completionSoundLengthSeconds),
      ).timeout(_alarmTimeout);

      if (generation == _alarmGeneration && !completer.isCompleted) {
        completer.complete();
        _alarmCompleter = null;
      }
    } catch (e) {
      debugPrint('Timer alarm failed: $e');
      if (!completer.isCompleted) completer.complete();
      if (generation == _alarmGeneration) {
        _alarmCompleter = null;
      }
    }
  }

  static bool get isPlaying => _isPlaying;
}
