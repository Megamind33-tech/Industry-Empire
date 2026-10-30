#!/usr/bin/env bash
# Clone the pinned Android port and apply the Industry Empire patches.
# Does not start the APK build. See docs/BUILD.md.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="${1:-$ROOT/sdl-android}"

if [ -e "$DEST" ]; then
  echo "Refusing to overwrite $DEST"
  exit 1
fi

git clone --depth 1 --branch sdl_android https://github.com/pelya/commandergenius.git "$DEST"
cd "$DEST"
git fetch --depth 1 origin 5eef322f67429465c99eabce5f86481d47178321
git checkout 5eef322f67429465c99eabce5f86481d47178321

git submodule update --init --depth 1 \
  project/jni/application/openttd/src \
  project/jni/iconv/src \
  project/jni/sdl2 \
  project/jni/sdl2_image \
  project/jni/sdl2_mixer \
  project/jni/sdl2_ttf

git -C project/jni/sdl2_ttf submodule update --init --depth 1 external/freetype external/harfbuzz
git -C project/jni/sdl2_image submodule update --init --depth 1 external/jpeg external/libpng external/zlib
git -C project/jni/sdl2_mixer submodule update --init --depth 1 external/ogg

git apply "$ROOT/patches/sdl-android-portability.patch"
git apply --binary "$ROOT/patches/industry-empire-icon.patch"
git -C project/jni/application/openttd/src apply "$ROOT/patches/openttd-industry-empire.patch"
git -C project/jni/application/openttd/src apply "$ROOT/patches/first-contract-integration.patch"
git apply "$ROOT/patches/first-contract-packaging.patch"

# Keep career source tracked in the product repository, separate from upstream.
mkdir -p project/jni/application/openttd/industry-empire-career
cp -a "$ROOT/assets/game/industry-empire-career/." project/jni/application/openttd/industry-empire-career/

ln -sfn openttd project/jni/application/src
echo "Source tree ready at $DEST"
