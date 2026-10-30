#!/usr/bin/env python3
"""Add the career Game Script to an existing APK without changing native code.

The result is unsigned. Run zipalign and apksigner before installing it.
This deliberately does not claim to include native menu patches.
"""
import argparse
import io
import lzma
from pathlib import Path
import zipfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("base", type=Path)
parser.add_argument("output", type=Path)
parser.add_argument("--script", type=Path, default=Path(__file__).resolve().parents[1] / "assets/game/industry-empire-career")
args = parser.parse_args()
if args.output.exists():
    parser.error("output already exists; choose a new artifact path")
for name in ("info.nut", "main.nut"):
    if not (args.script / name).is_file():
        parser.error(f"missing career script: {name}")
data_path = "assets/openttd-data-14.1-0.zip.xz"
prefix = "game/industry-empire-career/"
with zipfile.ZipFile(args.base) as base:
    packed = io.BytesIO(lzma.decompress(base.read(data_path)))
    updated = io.BytesIO()
    with zipfile.ZipFile(packed) as old, zipfile.ZipFile(updated, "w", compression=zipfile.ZIP_STORED) as new:
        for item in old.infolist():
            if not item.filename.removeprefix("./").startswith(prefix):
                new.writestr(item, old.read(item))
        for file in sorted(args.script.rglob("*")):
            if file.is_file():
                new.write(file, prefix + file.relative_to(args.script).as_posix())
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(args.output, "x") as apk:
        for item in base.infolist():
            if item.filename.startswith("META-INF/"):
                continue
            data = lzma.compress(updated.getvalue(), preset=6) if item.filename == data_path else base.read(item)
            apk.writestr(item, data)
print(f"Unsigned APK: {args.output}; native code unchanged; career available through Game Script selection")
