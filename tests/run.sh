#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

mkdir -p build examples/build

compile_root() {
  input=$1
  output=$2

  typst compile --root . "$input" "$output"
}

for name in \
  01-single-design \
  02-gangup-auto \
  03-gangup-manual-grid \
  04-mixed-sorts \
  05-cut-stack-tickets
do
  compile_root "examples/${name}.typ" "build/${name}.pdf"
done

cp build/01-single-design.pdf build/business-card-source.pdf

compile_root examples/06-booklet-source.typ examples/build/booklet-source.pdf

for name in \
  07-saddle-stitch-pdf \
  08-duplex-gangup \
  09-duplex-calibration \
  10-auto-orientation \
  11-saddle-report \
  12-crop-mark-knockout \
  13-pdf-input-gangup \
  14-single-cut-grid-crop-marks
do
  compile_root "examples/${name}.typ" "build/${name}.pdf"
done

compile_root tests/smoke.typ build/smoke.pdf

sh tests/guardrails.sh
