import 'package:flutter/services.dart';
import '../services/shared_pref_helper.dart';

class VibrationService {
  static const MethodChannel _channel = MethodChannel('maala/haptic');

  static Future<void> vibrate({int durationMs = 30}) async {
    if (!SharedPrefHelper.getHapticEnabled()) return;

    try {
      await _channel.invokeMethod('vibrate', {'duration': durationMs});
    } catch (_) {}
  }
}
