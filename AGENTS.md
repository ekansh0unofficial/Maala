# AGENTS.md — Maala

Guidance for AI coding agents working in this repository.

## Project

Maala is a Flutter japa-mala counter + meditation timer app, **live on Google Play**
(package `com.ekansh.maala_app`). Treat the codebase as production software.

## Commands

```bash
flutter pub get                      # after changing pubspec.yaml
flutter analyze                      # MUST stay clean (0 issues) before finishing any change
flutter test                         # run if tests exist
flutter build appbundle --release    # release AAB for Play Store
```

Build environment notes:
- Flutter is pinned to JDK 21 via `flutter config --jdk-dir "C:\Program Files\Java\jdk-21"`.
  Do NOT let builds use Android Studio's bundled JBR (JDK 25) — Gradle 8.10.2's Kotlin DSL
  compiler crashes on it with a cryptic `What went wrong: 25.0.2` error.
- Release signing reads `android/key.properties` + `android/app/keystore.jks`
  (both gitignored). Never commit them, never print their contents.

## Versioning / releases

- App is published on Google Play using **Play App Signing**; the local keystore is the
  *upload key* only.
- Before any release build: bump `version:` in `pubspec.yaml` (both name and build number;
  Play requires strictly increasing versionCode).
- `secure_backup.7z` is an encrypted personal backup kept locally only — never commit
  archives (`*.7z` is gitignored).

## Code conventions

- Lints: `package:flutter_lints/flutter.yaml`. Keep `flutter analyze` at zero issues.
- No `print()` — use `debugPrint`.
- Dark UI theme: screens use transparent Scaffolds over full-bleed background images with
  white text/icons; follow existing patterns in `lib/counter_screen/`, `lib/timer_screen/`,
  `lib/settings_screen/`.
- Persistence goes through `SharedPrefHelper` (static init in `main.dart`); timers/sound go
  through `TimerHelper` / `SoundHelper` static services.
- Platform channels live in `MainActivity.kt` (`maala/haptic`, `maala/screen`) with Dart
  wrappers in `lib/services/`. Wrap channel calls in try/catch so desktop/web targets don't
  crash.
