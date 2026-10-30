#!/usr/bin/env bash
# Render, pack and compile the Transport Empire vehicle NewGRF.
# usage: BLENDER=/path/to/blender art/build.sh [samples]
set -euo pipefail
ART="$(cd "$(dirname "$0")" && pwd)"
BLENDER="${BLENDER:-blender}"
SAMPLES="${1:-128}"
cd "$ART"
for model in starter_car; do
  "$BLENDER" -b -P blender/te_render.py -- --model "$model" --out "build/$model" --samples "$SAMPLES"
  python3 -I tools/pack_vehicle.py "build/$model" grf/gfx "$model"
done
cd grf
cpp -P -nostdinc transport_empire.pnml > ../build/transport_empire.nml
nmlc -c --lang-dir=lang --grf=../build/transport_empire.grf ../build/transport_empire.nml
echo "Built $ART/build/transport_empire.grf"
