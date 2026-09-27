package com.ekansh.maala_app

import android.os.*
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val HAPTIC_CHANNEL = "maala/haptic"
    private val SCREEN_CHANNEL = "maala/screen"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Haptic feedback channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HAPTIC_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "vibrate") {
                try {
                    // StandardMethodCodec may decode the Dart int as Int,
                    // Long or Double depending on the value — accept all.
                    val duration = when (val arg = call.argument<Any>("duration")) {
                        is Int -> arg
                        is Long -> arg.toInt()
                        is Double -> arg.toInt()
                        is Number -> arg.toInt()
                        else -> 30
                    }.coerceIn(1, 5000)

                    val vibrator: Vibrator? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        try {
                            val vibratorManager = getSystemService(VibratorManager::class.java)
                            vibratorManager?.defaultVibrator
                        } catch (e: Exception) {
                            @Suppress("DEPRECATION")
                            getSystemService(VIBRATOR_SERVICE) as? Vibrator
                        }
                    } else {
                        @Suppress("DEPRECATION")
                        getSystemService(VIBRATOR_SERVICE) as? Vibrator
                    }

                    if (vibrator == null || !vibrator.hasVibrator()) {
                        result.success(false)
                        return@setMethodCallHandler
                    }

                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        // DEFAULT_AMPLITUDE is scaled by the OEM touch-intensity
                        // slider (and muted by Battery Saver on some skins), so
                        // long/completion buzzes use full amplitude while short
                        // taps prefer a crisp predefined click on resonant
                        // motors (API 29+) with a one-shot fallback.
                        var played = false
                        if (Build.VERSION.SDK_INT >= 29 && duration < 150) {
                            try {
                                vibrator.vibrate(
                                    VibrationEffect.createPredefined(
                                        VibrationEffect.EFFECT_CLICK
                                    )
                                )
                                played = true
                            } catch (e: Exception) {
                                // Fall through to the one-shot below.
                            }
                        }
                        if (!played) {
                            val amplitude =
                                if (duration >= 150 || !vibrator.hasAmplitudeControl()) 255
                                else VibrationEffect.DEFAULT_AMPLITUDE
                            val effect = VibrationEffect.createOneShot(
                                duration.toLong(),
                                amplitude
                            )
                            if (Build.VERSION.SDK_INT >= 33) {
                                vibrator.vibrate(
                                    effect,
                                    VibrationAttributes.createForUsage(
                                        VibrationAttributes.USAGE_ALARM
                                    )
                                )
                            } else {
                                vibrator.vibrate(effect)
                            }
                        }
                    } else {
                        @Suppress("DEPRECATION")
                        vibrator.vibrate(duration.toLong())
                    }
                    result.success(true)
                } catch (e: Exception) {
                    try {
                        result.error("VIBRATE_FAILED", e.message, null)
                    } catch (_: Exception) {
                        // Result already consumed — nothing left to report.
                    }
                }
            } else {
                result.notImplemented()
            }
        }

        // Keep screen on channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SCREEN_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableScreenOn" -> {
                    window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    result.success(true)
                }
                "disableScreenOn" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
}
