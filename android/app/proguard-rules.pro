# Maala release keep rules (R8 minify + resource shrinking).

# --- Flutter engine + embedding ------------------------------------------
# The Flutter Gradle plugin appends its own keep rules for the engine; these
# are listed defensively so a missing rule can never corrupt the Dart isolate.
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# --- App entry point ------------------------------------------------------
# Keep the whole MainActivity (including its Kotlin method-channel handlers
# for haptics and screen-awake) so R8 can never strip them at minify time —
# a stripped channel handler would silently kill haptic feedback.
-keep class com.ekansh.maala_app.MainActivity { *; }
-keepclassmembers class com.ekansh.maala_app.MainActivity { *; }

# --- AdMob / Google Mobile Ads --------------------------------------------
# The SDK ships consumer keep rules in its AAR; keep defensively so banner
# adapters and listener wiring never get stripped on a future SDK update.
-keep class com.google.android.gms.ads.** { *; }
-keep class com.google.ads.mediation.** { *; }

# --- audioplayers ----------------------------------------------------------
-keep class xyz.luan.audioplayers.** { *; }