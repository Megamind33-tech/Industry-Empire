#!/usr/bin/env bash
# Render, pack and compile the Transport Empire vehicle NewGRF.
# usage: BLENDER=/path/to/blender art/build.sh [samples]
set -euo pipefail
ART="$(cd "$(dirname "$0")" && pwd)"
BLENDER="${BLENDER:-blender}"
SAMPLES="${1:-128}"
cd "$ART"
# Renders every vehicle row in assets.csv that has a model; unchanged ones are skipped.
BLENDER="$BLENDER" python3 -I tools/render_all.py $([ "$SAMPLES" -lt 64 ] && echo --draft)
cd grf
cpp -P -nostdinc transport_empire.pnml > ../build/transport_empire.nml
nmlc -c --lang-dir=lang --grf=../build/transport_empire.grf ../build/transport_empire.nml
echo "Built $ART/build/transport_empire.grf"
