# Industry Empire

Industry Empire is a transport-company game for Android. It keeps the OpenTTD 14.1 simulation. Version 1.2 uses OpenGFX2 Classic for the terrain, buildings, and vehicles, and still includes OpenGFX 7.1 so the older look can be selected in Game Options.

It is an independent release. It is not made or endorsed by the OpenTTD developers.

The playable build is a debug-signed release APK (arm64-v8a and x86_64) for Android 7.0 and newer. A Play Store upload key is not in this repository.

## Download

[IndustryEmpire-1.2-ottd14.1.apk](https://github.com/Megamind33-tech/Industry-Empire/raw/cursor/mobile-quickstart-781c/dist/IndustryEmpire-1.2-ottd14.1.apk) (91 MB)

SHA-256: `ba98e9ee3d0162e4c44dbe38110d52c3d8259545d95464f0ba862817c2feba45`

Install that file on an Android device. The launcher name is Industry Empire. Quick Start opens the Coastal Valley scenario: a coast, a river, hills, forests, a few towns, and a sample bus route. Android may ask you to allow installs from the browser. Upgrading replaces the old configuration file so a previous 4096×4096 map is not kept. Saved games stay.

The 1.0 and 1.1 APKs remain in `dist/` if you want the previous graphics.

The first launch downloads nothing else: both graphics sets, sound, and music are inside the APK. To use the older OpenGFX look, open Game Options and choose the OpenGFX base set.

## Build

See `docs/BUILD.md`. The Android port is pelya's SDL build of OpenTTD 14.1, with the compiler fixes in `patches/`.

## Licences

Source code is GPL-2.0. OpenGFX, OpenGFX2 Classic, and the music base set are GPL-2.0. Sound effects are CC BY-SA 3.0. See `COMMERCIAL_COMPLIANCE.md`, `THIRD_PARTY_NOTICES.md`, and `docs/GRAPHICS.md`. Corresponding source is this repository plus the upstream commits named in `SOURCE_CODE.md`.
