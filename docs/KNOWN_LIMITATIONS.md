# Known limitations

- Engine is OpenTTD 14.1, not OpenTTD 15.3 or 16. The Android port that builds is pelya's 14.1 tree.
- Graphics, sounds, and music are the upstream base sets. Cities, industries, vehicles, and terrain were not redrawn. OpenGFX2 is not included. Terrain variety now defaults to High, which uses the existing OpenGFX sprites.
- Quick Start and the town-count warning are in 1.1. They were not clicked on a device in this environment.
- There is no separate curated-map menu. Quick Start generates a 256×256 map. World Generation, scenarios, and the scenario editor remain available.
- The main menu is still the OpenTTD window layout. Quick Start, World Generation, and the First Route story script are the new first-run path.
- Touch controls are the existing SDL Android port (tap, two-finger gestures, pinch via that port). They were not retested on a device in this environment.
- No phone or emulator completed a game launch. KVM is present but the Android emulator guest stayed offline, so install, input, frame time, and memory were not measured. Do not treat the APK checksum as a play test.
- The APK is debug-signed. Release signing is not set up.
- Only arm64-v8a and x86_64 are in the APK.
- Graphics quality profiles (Low / Balanced / High) are not separate settings beyond what OpenTTD already exposes.
- Multiplayer, AI, save/load, and NewGRF are the OpenTTD 14.1 implementations. They were not exercised on Android here.
