import 'dart:async';

class TimerHelper {
  static late Duration _totalDuration;
  static Duration _remaining = const Duration();
  static Timer? _timer;
  static Function()? _onTick;

  static Duration get remaining => _remaining;

  static void initialize(
    Function() onTick, {
    int hours = 0,
    int minutes = 0,
    int seconds = 0,
  }) {
    _totalDuration = Duration(hours: hours, minutes: minutes, seconds: seconds);
    _remaining = _totalDuration;
    _onTick = onTick;
  }

  static void updateDuration(int hours, int minutes, int seconds) {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    _totalDuration = Duration(seconds: totalSeconds);
    _remaining = _totalDuration;
    _onTick?.call();
  }

  static void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining.inSeconds > 0) {
        _remaining -= const Duration(seconds: 1);
        _onTick?.call();
      } else {
        timer.cancel();
      }
    });
  }

  static void pause() {
    _timer?.cancel();
  }

  static void reset() {
    _timer?.cancel();
    _remaining = _totalDuration;
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
