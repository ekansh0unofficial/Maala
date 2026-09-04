import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ScreenAwakeService {
  static const MethodChannel _channel = MethodChannel('maala/screen');

  static Future<void> enable() async {
    try {
      await _channel.invokeMethod('enableScreenOn');
    } catch (e) {
      debugPrint('Keep-screen-on enable failed: $e');
    }
  }

  static Future<void> disable() async {
    try {
      await _channel.invokeMethod('disableScreenOn');
    } catch (e) {
      debugPrint('Keep-screen-on disable failed: $e');
    }
  }
}
