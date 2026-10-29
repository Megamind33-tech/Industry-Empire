# Industry Empire

Industry Empire is a transport-company game for Android. It keeps the OpenTTD 14.1 simulation and packages it with the free OpenGFX, OpenSFX, and OpenMSX base sets.

It is an independent release. It is not made or endorsed by the OpenTTD developers.

The playable build is a debug-signed release APK (arm64-v8a and x86_64) for Android 7.0 and newer. A Play Store upload key is not in this repository.

## Download

[IndustryEmpire-1.1-ottd14.1.apk](https://github.com/Megamind33-tech/Industry-Empire/raw/cursor/mobile-quickstart-781c/dist/IndustryEmpire-1.1-ottd14.1.apk) (83 MB)

Install that file on an Android device. The launcher name is Industry Empire. The first button is Quick Start. Android may ask you to allow installs from the browser. Upgrading replaces the old configuration file so a previous 4096×4096 map is not kept. Saved games stay.

The first launch downloads nothing else: graphics, sound, and music are inside the APK.

## Build

See `docs/BUILD.md`. The Android port is pelya's SDL build of OpenTTD 14.1, with the compiler fixes in `patches/`.

## Licences

Source code is GPL-2.0. Graphics and music base sets are GPL-2.0. Sound effects are CC BY-SA 3.0. See `COMMERCIAL_COMPLIANCE.md` and `THIRD_PARTY_NOTICES.md`. Corresponding source is this repository plus the upstream commits named in `SOURCE_CODE.md`.
