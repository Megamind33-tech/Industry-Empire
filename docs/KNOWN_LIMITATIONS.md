# Known limitations

- Engine is OpenTTD 14.1, not OpenTTD 15.3 or 16. The Android port that builds is pelya's 14.1 tree.
- The default art is OpenGFX2 Classic 0.8.1, an 8bpp redraw. OpenGFX 7.1 is still installed and can be selected in Game Options. OpenGFX2 High Def is not included: the set is about 383 MB uncompressed and its extra GRF is about 255 MB, which cannot be published as an APK file on GitHub. High Def was not loaded in a running game. See `docs/GRAPHICS.md`.
- The comparison screenshots are from the Linux SDL build of this source, at the same save and camera. They are not photos of an Android screen.
- Quick Start loads the Coastal Valley scenario. World Generation, heightmaps, and the scenario editor remain available. The 6,144-town figure is still what the Normal town setting does on a 4096×4096 map.
- The main menu is still the OpenTTD window layout. Quick Start, World Generation, and the First Route story script are the new first-run path.
- Touch controls are the existing SDL Android port. They were not retested on a device in this environment.
- No phone or emulator completed a game launch. KVM is present but the Android emulator guest stayed offline, so install, input, frame time, and memory were not measured on Android. The frame rate and memory figures in `docs/GRAPHICS.md` are from the Linux SDL build.
- The APK is debug-signed. Release signing is not set up.
- Only arm64-v8a and x86_64 are in the APK.
- Multiplayer, AI, save/load, and NewGRF are the OpenTTD 14.1 implementations. They were not exercised on Android here.
