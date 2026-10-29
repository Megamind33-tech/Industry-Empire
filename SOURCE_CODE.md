# Corresponding source

Industry Empire is built from these upstream commits. No proprietary Transport Tycoon Deluxe data is included.

| Component | Repository | Commit |
| --- | --- | --- |
| Android SDL port | https://github.com/pelya/commandergenius | `5eef322f67429465c99eabce5f86481d47178321` (branch `sdl_android`) |
| OpenTTD 14.1 Android tree | https://github.com/pelya/openttd-android | `a3163e003f86ff2b4e56e739456b44e2bd34f5b0` (branch `14`, OpenTTD 14.1) |
| libiconv / ICU 62.1 | https://github.com/pelya/libiconv-libicu-android | `1d9e3e389de92818bafbca061d454ec917af9ec0` |
| SDL2 (headers and unused modules) | https://github.com/libsdl-org/SDL | `0efeb82a28795e72594642251f1bddcb881aaa7f` |
| SDL_image, with libpng, jpeg, zlib | https://github.com/libsdl-org/SDL_image | `c91323df2f84352751e68111b70ac3f739cea068` |
| SDL_ttf, with FreeType and HarfBuzz | https://github.com/libsdl-org/SDL_ttf | `3091df328802d15364a30b8fbd5e8f58ce770f9b` |
| SDL_mixer, libogg only | https://github.com/libsdl-org/SDL_mixer | `7808d9afd92bb30dfa96c6b6540b04b161803566` |

Base sets, downloaded at build time from cdn.openttd.org:

| Set | Version | Licence |
| --- | --- | --- |
| OpenGFX | 7.1 | GPL-2.0 |
| OpenSFX | 1.0.3 | CC BY-SA 3.0 |
| OpenMSX | 0.4.2 | GPL-2.0 |

Local changes are `patches/sdl-android-portability.patch` and `patches/openttd-industry-empire.patch`. `scripts/bootstrap-android.sh` clones the commits above and applies those patches.

OpenTTD 15.3 is the newest stable desktop release. The maintained Android port used here is OpenTTD 14.1. The 14.1 simulation still includes rail, road, ships, aircraft, industries, towns, finances, AI companies, scenarios, NewGRF, and multiplayer.
