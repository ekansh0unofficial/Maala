import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/shared_pref_helper.dart';

class VibrationService {
  static const MethodChannel _channel = MethodChannel('maala/haptic');

  static Future<void> vibrate({int durationMs = 30}) async {
    if (!SharedPrefHelper.getHapticEnabled()) return;

    try {
      await _channel.invokeMethod('vibrate', {'duration': durationMs});
    } on MissingPluginException catch (_) {
      // No native handler (iOS-unpatched, desktop, web): fall back to the
      // framework haptics so the cue is not silently lost.
      await _fallback(durationMs);
    } catch (e) {
      debugPrint('Haptic feedback failed: $e');
      await _fallback(durationMs);
    }
  }

  /// Framework-provided haptics used when the platform channel is missing
  /// or the native vibrate call throws. Never rethrows.
  static Future<void> _fallback(int durationMs) async {
    try {
      if (durationMs >= 150) {
        await HapticFeedback.heavyImpact();
      } else if (durationMs >= 60) {
        await HapticFeedback.mediumImpact();
      } else {
        await HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint('Haptic fallback failed: $e');
    }
  }
}
