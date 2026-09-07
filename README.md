# Maala

**Maala** — the japa mala counter and meditation timer that turns your phone into a personal sanctuary. Every tap, every bead, every breath, crafted with obsessive care. Built with **Flutter**, engineered for **Android**, and **live on Google Play** (`com.ekansh.maala_app`).

This is meditation for people who love software that just *feels* right.

---

## The Counter — built around your mala

- **Tap anywhere, count forever.** The full screen is your mala bead. No buttons to find, no distractions — just tap, tap, tap, in flow.
- **Configurable limit, chaos-free.** Default 108 beads, changeable in seconds. Hit the limit and the counter **auto-resets** for the next round.
- **Haptic feedback on every bead.** A satisfying, calibrated vibration — feel the count in your hands even with your eyes closed.
- **Completion chime.** A Tibetan singing bowl rings when a mala is complete. Because finishing deserves a sound that hits your soul.
- **Focus mode.** Long-press to strip the interface down to silence. Just you, the counter, and the count.
- **Lifetime memory.** Session malas, today's malas, total malas, total chants — and a beautifully animated **streak card** that celebrates your daily consistency.
- **Private by design.** Delete the app, and every trace of your practice disappears with it. No accounts. No cloud. No way to track you.

## The Timer — meditation on a deadline that bends to reality

- **Set any duration, not just presets.** Hour, minute, and second dials — from a 10-second breath reset to a 3-hour deep sit.
- **Wall-clock accuracy.** The countdown is anchored to the real clock, not flaky timers. A notification, a system hiccup, even a force-close cannot corrupt it.
- **Auto-pauses when you step away.** Hide the app or swipe it away? The timer pauses and the music stops, so your session never silently drains while you're gone.
- **Looping ambient soundtrack** — eight professionally curated soundscapes (cricket-filled nights, coastal caves, bamboo forests, singing bowls, tanpura drones…), playable or paused with one tap while the time ticks down.

## Personalization — make it yours, down to the pixels

- **Your photo, your sanctuary.** Pick any photo from your gallery (via the privacy-respecting **Android Photo Picker**) or choose from a curated library of full-bleed backgrounds.
- **A theme that adapts to your art.** The entire color palette — accents, surfaces, borders — is **derived live from your background image** using Material's dynamic color engine. Nothing matches your wallpaper like this.
- **Eight soundscapes across six moods** — Dawn, Ocean, Forest, Cosmos, Lotus, and Midnight — each with a title derived from the audio itself.
- **English or हिन्दी**, one tap to switch. The whole app, not just a phrasebook.
- **Keep-screen-on toggle.** Let the timer hold the screen awake through long sits.
- **Haptics on/off**, so you decide whether every bead speaks to your fingertips.

## The Detail — software that sweats the small stuff

- **Truly adaptive.** Rotate the phone mid-session and the layout reflows instantly — portrait toolbar becomes a side rail, nothing falls off screen, the timer keeps ticking exactly where you left it.
- **Instant launches.** Bundled fonts (no network round-trips ever), a cached adaptive theme, and thumbnail-based color extraction mean the app opens *fast* — then your theme snaps in from memory before you blink.
- **Fully offline.** Fonts, sounds, images, and logic are all on-device. The only network touch is a respectfully quiet banner ad. A still pond, not a data mine.
- **Dark-first design.** Transparent scaffolds over full-bleed imagery, elegant Cormorant Garamond, crisp Inter, and generous Montserrat — typography that reads like a meditation manual, not a settings menu.
- **Zero surveillance.** No analytics. No crash reporters. No accounts. No permission creep — just vibration and internet-for-ads. Google's own Photo Picker means your gallery is never exposed. The privacy policy is boring on purpose.

---

## Development

```bash
flutter pub get                      # install dependencies
flutter analyze                      # must stay at 0 issues
flutter test                         # run tests
flutter build appbundle --release    # release AAB for Play Store
```

Repository conventions, release flow, and the CI/CD boundary live in `AGENTS.md`.

## Privacy

A tl;dr of `PRIVACY_POLICY.txt`: everything you do stays on your device. The app collects nothing about you, ever. Ads come from Google AdMob under Google's own policies.

---

*Maala — because the journey of ten thousand beads begins with a single tap.*