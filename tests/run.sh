#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

mkdir -p build examples/build
PACKAGE_PATH="$ROOT/build/package-path"
PACKAGE_DIR="$PACKAGE_PATH/preview/sheetwise/0.1.0"
rm -rf "$PACKAGE_PATH"
mkdir -p "$PACKAGE_DIR"
cp lib.typ typst.toml "$PACKAGE_DIR/"
cp -R src "$PACKAGE_DIR/"

compile_root() {
  input=$1
  output=$2

  typst compile --root . --package-path "$PACKAGE_PATH" "$input" "$output"
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
  14-single-cut-grid-crop-marks \
  15-multiple-mark-regions \
  16-asymmetric-margins
do
  compile_root "examples/${name}.typ" "build/${name}.pdf"
done

compile_root tests/smoke.typ build/smoke.pdf
compile_root tests/readme-smoke.typ build/readme-smoke.pdf

sh tests/guardrails.sh
