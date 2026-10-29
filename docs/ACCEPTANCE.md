# Acceptance

Checked on 29 October 2026 (Africa/Lusaka). Device launch was not possible: the Android emulator process started, KVM reported API version 12, and the guest stayed `offline` with almost no CPU use. No phone was attached.

| Gate | Result | Evidence |
| --- | --- | --- |
| Android APK builds | PASS | `dist/IndustryEmpire-1.0-ottd14.1.apk`, debug-signed, arm64-v8a and x86_64, minSdk 24, targetSdk 37 |
| Baseline APK kept | PASS | `dist/IndustryEmpire-baseline-openttd-14.1.apk`, label OpenTTD, versionName 14.1.rev128 |
| Installs on Android | NOT TESTED | Emulator guest never reached adb |
| Launches | NOT TESTED | Same |
| New game, transport, industries, towns, finances, save/load | NOT TESTED | These are the OpenTTD 14.1 systems in the binary. They were not played |
| Mobile interface usable | NOT TESTED | SDL touch code is in the port. No touch session was run |
| Visual presentation meaningfully improved | FAIL | World art is OpenGFX 7.1. Only the launcher icon and main-menu title changed |
| New assets integrated | PASS for icon and title only | Title bytes are inside `assets/openttd-data-14.1-0.zip.xz` |
| Map presets load | FAIL | No new scenarios were added |
| Performance measured | NOT TESTED | No frame time, memory, or startup numbers |
| Licences and source | PASS with open items | `COMMERCIAL_COMPLIANCE.md`. Debug signature is not Play App Signing |
| Gameplay screenshots | NOT TESTED | No running game |

Checksums (SHA-256):

- Branded: `bcacd7fb8d620fbc91e313850b69d40e021bc3fd75ec9841231d8a56ac0e0f41`
- Baseline: `1afec756ad79dbf74bea27272ba1cb318921169c505a95e4239371f245f1930c`

Upstream OpenTTD Android commit: `a3163e003f86ff2b4e56e739456b44e2bd34f5b0`. SDL port commit: `5eef322f67429465c99eabce5f86481d47178321`.
