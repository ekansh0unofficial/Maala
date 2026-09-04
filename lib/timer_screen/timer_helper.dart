import 'dart:async';
import 'package:maala_app/services/shared_pref_helper.dart';
import 'package:maala_app/services/sound_helper.dart';

/// Countdown timer backed by wall-clock deadlines so it keeps correct time
/// even when the app is backgrounded or the device sleeps.
class TimerHelper {
  static Duration _totalDuration = const Duration();
  static Duration _remaining = const Duration();
  static DateTime? _deadline;
  static Timer? _timer;
  static Function()? _onTick;

  static Duration get remaining => _remaining;
  static bool get isRunning => _timer?.isActive ?? false;

  static void initialize(Function() onTick) {
    _onTick = onTick;

    final totalSec = SharedPrefHelper.getTotalSeconds();
    _totalDuration = Duration(seconds: totalSec);

    final deadlineMs = SharedPrefHelper.getTimerDeadlineMs();
    if (SharedPrefHelper.getTimerRunning() && deadlineMs != null) {
      // App was closed while the timer ran - reconcile against the wall clock.
      final left = deadlineMs - DateTime.now().millisecondsSinceEpoch;
      if (left > 0) {
        _remaining = Duration(milliseconds: left);
        _deadline = DateTime.fromMillisecondsSinceEpoch(deadlineMs);
        _tick();
        return;
      }
      _complete();
      return;
    }

    final remainingSec = SharedPrefHelper.getRemainingSeconds();
    _remaining = Duration(seconds: remainingSec > 0 ? remainingSec : totalSec);
    _onTick?.call();
  }

  static void updateDuration(int hours, int minutes, int seconds) {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    _totalDuration = Duration(seconds: totalSeconds);
    _remaining = _totalDuration;
    _deadline = null;

    SharedPrefHelper.setTotalSeconds(totalSeconds);
    SharedPrefHelper.setRemainingSeconds(totalSeconds);
    SharedPrefHelper.clearTimerDeadline();
    SharedPrefHelper.setTimerRunning(false);
    _onTick?.call();
  }

  static void start() {
    if (_remaining <= Duration.zero) return;
    _timer?.cancel();
    _deadline = DateTime.now().add(_remaining);
    SharedPrefHelper.setTimerDeadlineMs(_deadline!.millisecondsSinceEpoch);
    SharedPrefHelper.setTimerRunning(true);
    _tick();
  }

  static void pause() {
    _timer?.cancel();
    _timer = null;
    if (_deadline != null) {
      _remaining = _deadline!.difference(DateTime.now());
      if (_remaining < Duration.zero) _remaining = Duration.zero;
    }
    _deadline = null;
    SharedPrefHelper.setRemainingSeconds(_remaining.inSeconds);
    SharedPrefHelper.clearTimerDeadline();
    SharedPrefHelper.setTimerRunning(false);
  }

  static void reset() {
    _timer?.cancel();
    _timer = null;
    _deadline = null;
    _remaining = _totalDuration;
    SharedPrefHelper.setRemainingSeconds(_totalDuration.inSeconds);
    SharedPrefHelper.clearTimerDeadline();
    SharedPrefHelper.setTimerRunning(false);
    _onTick?.call();
  }

  static void _tick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_deadline == null) {
        _timer?.cancel();
        return;
      }
      _remaining = _deadline!.difference(DateTime.now());
      if (_remaining <= Duration.zero) {
        _complete();
      } else {
        SharedPrefHelper.setRemainingSeconds(_remaining.inSeconds);
        _onTick?.call();
      }
    });
    _onTick?.call();
  }

  static void _complete() {
    _timer?.cancel();
    _timer = null;
    _deadline = null;
    _remaining = Duration.zero;
    SharedPrefHelper.setRemainingSeconds(0);
    SharedPrefHelper.clearTimerDeadline();
    SharedPrefHelper.setTimerRunning(false);
    SoundHelper.stop();
    _onTick?.call();
  }

  static String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final h = twoDigits(duration.inHours);
    final m = twoDigits(duration.inMinutes.remainder(60));
    final s = twoDigits(duration.inSeconds.remainder(60));
    return "$h:$m:$s";
  }
}
