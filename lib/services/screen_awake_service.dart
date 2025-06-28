import 'package:flutter/services.dart';

class ScreenAwakeService {
  static const MethodChannel _channel = MethodChannel('maala/screen');

  static Future<void> enable() async {
    await _channel.invokeMethod('enableScreenOn');
  }

  static Future<void> disable() async {
    await _channel.invokeMethod('disableScreenOn');
  }
}
