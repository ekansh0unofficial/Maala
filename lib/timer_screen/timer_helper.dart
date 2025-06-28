import 'dart:async';
import 'package:maala_app/services/shared_pref_helper.dart';

class TimerHelper {
  static late Duration _totalDuration;
  static Duration _remaining = const Duration();
  static Timer? _timer;
  static Function()? _onTick;

  static Duration get remaining => _remaining;

  static void initialize(Function() onTick) {
    _onTick = onTick;

    final totalSec = SharedPrefHelper.getTotalSeconds();
    final remainingSec = SharedPrefHelper.getRemainingSeconds();

    _totalDuration = Duration(seconds: totalSec);
    _remaining = Duration(seconds: remainingSec > 0 ? remainingSec : totalSec);

    _onTick?.call();
  }

  static void updateDuration(int hours, int minutes, int seconds) {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    _totalDuration = Duration(seconds: totalSeconds);
    _remaining = _totalDuration;

    SharedPrefHelper.setTotalSeconds(totalSeconds);
    SharedPrefHelper.setRemainingSeconds(totalSeconds);
    _onTick?.call();
  }

  static void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        _remaining -= const Duration(seconds: 1);
        SharedPrefHelper.setRemainingSeconds(_remaining.inSeconds);
        _onTick?.call();
      } else {
        timer.cancel();
        SharedPrefHelper.setTimerRunning(false);
      }
    });
    SharedPrefHelper.setTimerRunning(true);
  }

  static void pause() {
    _timer?.cancel();
    SharedPrefHelper.setTimerRunning(false);
  }

  static void reset() {
    _timer?.cancel();
    _remaining = _totalDuration;
    SharedPrefHelper.setRemainingSeconds(_totalDuration.inSeconds);
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
