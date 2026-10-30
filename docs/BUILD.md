# Android build

Host: Ubuntu with JDK 21, CMake, Ninja, g++, ninja, ImageMagick, and the Android SDK packages below.

```
platforms;android-37.0
build-tools;37.0.0
ndk;29.0.14206865
platform-tools
cmake;3.22.1
```

`compileSdk 37` looks up `platforms/android-37`. If sdkmanager only installed `android-37.0`, symlink it:

```
ln -sfn android-37.0 "$ANDROID_SDK_ROOT/platforms/android-37"
```

## Source

`scripts/bootstrap-android.sh` clones the commits in `SOURCE_CODE.md` and applies `patches/`. The tree used for the APK in `dist/` was built from that layout at `sdl-android/` (not committed; it is several hundred megabytes of upstream source plus build output).

Environment:

```
export ANDROID_SDK_ROOT=/opt/android-sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
export ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk/29.0.14206865
export PATH="$ANDROID_NDK_HOME:$ANDROID_SDK_ROOT/build-tools/37.0.0:$ANDROID_SDK_ROOT/platform-tools:$PATH"
export NCPU=2
```

Create the debug keystore once (do not commit it):

```
keytool -genkey -v -keystore "$HOME/.android/debug.keystore" -storepass android \
  -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 \
  -dname "CN=Debug, OU=Debug, O=Debug, L=Debug, ST=Debug, C=Debug"
```

From `sdl-android/`:

```
ln -sfn openttd project/jni/application/src
./build.sh release openttd
```

`build.sh` signs `project/app/build/outputs/apk/release/app-release.apk` with the debug keystore. ABIs are `arm64-v8a` and `x86_64` (`MultiABI` in `AndroidAppSettings.cfg`). armeabi-v7a and x86 are omitted.

Base sets are pinned in the data directory to OpenGFX 7.1, OpenSFX 1.0.3, and OpenMSX 0.4.2. Do not switch OpenGFX to 8.x for this 14.1 engine without a load test.

## NDK 29 fixes

These are in `patches/sdl-android-portability.patch`:

- OpenSSL header patch matches the headers NDK r29 generates, and selects 32-bit or 64-bit BN config with `__LP64__`.
- `APP_ALLOW_MISSING_DEPS=true` so unused SDL2 modules do not abort the parse.
- Skip `sdl2_mixer/Android.mk` (it includes codec trees this game does not build) and compile libogg from `sdl2_mixer/external/ogg`.
- Nested submodules: FreeType, HarfBuzz, libpng, jpeg, zlib, and libogg.

`patches/transport-empire.patch` disables fmt 9 consteval on Clang 17+ (NDK r29 fails the stock check), replaces OpenTTD branding in the English strings with Transport Empire (the About window keeps the required OpenTTD copyright credit), renames subsidies to contracts, and lowers the starting cash to 20,000 and the default loan limit to 50,000.
