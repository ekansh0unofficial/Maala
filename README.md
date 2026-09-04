# Maala

A japa mala counter and meditation timer app, built with Flutter.

Live on Google Play as `com.ekansh.maala_app`.

## Features

- **Counter** — tap anywhere to count chants; configurable limit (default 108) with haptic feedback and auto-reset.
- **Timer** — meditation countdown that keeps correct time across app restarts; optional looping soundtrack.
- **Personalization** — built-in or custom background images, six ambient soundtracks, haptics and keep-screen-on toggles.

## Development

```bash
flutter pub get
flutter analyze     # must stay at 0 issues
flutter test
flutter build appbundle --release
```

See `AGENTS.md` for repository conventions and release notes.
