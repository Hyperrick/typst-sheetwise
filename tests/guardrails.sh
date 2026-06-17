#!/usr/bin/env sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
mkdir -p build

expect_failure() {
  name=$1
  needle=$2
  input="tests/${name}.typ"
  output="build/${name}.pdf"

  set +e
  log=$(typst compile --root . "$input" "$output" 2>&1)
  code=$?
  set -e

  if [ "$code" -eq 0 ]; then
    printf '%s unexpectedly passed\n' "$name" >&2
    exit 1
  fi

  case "$log" in
    *"$needle"*) printf '%s failed as expected\n' "$name" ;;
    *)
      printf '%s failed with the wrong error\n%s\n' "$name" "$log" >&2
      exit 1
      ;;
  esac
}

while IFS='|' read -r name needle; do
  [ -n "$name" ] || continue
  expect_failure "$name" "$needle"
done <<'CASES'
invalid-copies|`copies` cannot exceed the selected grid slots.
invalid-binding|`binding` must be `left` or `right`.
invalid-bleed|`bleed` must not be negative.
invalid-blank-policy|`blank-policy` must be `error` or `end`.
invalid-columns|`columns` must be at least 1.
invalid-crop-mode|`marks.crop-mode` must be `auto`, `per-item`, or `grid`.
invalid-cut-mode|`cut-mode` must be `single` or `double`.
invalid-creep|`creep` must not be negative.
invalid-duplex-back|`gangup` needs `back` when `duplex: true`.
invalid-flip|`flip` must be `long-edge`, `short-edge`, or `none`.
invalid-flow|unknown `flow`.
invalid-gangup-flip|`flip` must be `long-edge`, `short-edge`, or `none`.
invalid-items|every `items` entry must include `body`.
invalid-item-orientation|`item-orientation` must be `auto`, `original`, `portrait`, or `landscape`.
invalid-marks|`marks` must be a boolean, `none`, or a dictionary.
invalid-mark-style|`mark-style` must be a dictionary.
invalid-order|`order` must be `forward` or `reverse`.
invalid-orientation|`orientation` must be `portrait` or `landscape`.
invalid-pdf-back-page|`back-page` must be at least 1.
invalid-pdf-back-source|`back-source` requires `duplex: true`.
invalid-pdf-page|`page` must be at least 1.
invalid-reading-direction|`reading-direction` must be `ltr` or `rtl`.
invalid-rows|`rows` must be at least 1.
invalid-safe|`safe` must be smaller than half the item size.
invalid-stack-flow|`stack-flow` must contain `deep`, `right`, and `down` exactly once.
invalid-stack-size|`stack-size` is too small for `count` and the selected grid.
invalid-trim-size|`trim-size` is required.
CASES
