#import "@preview/sheetwise:0.1.0": impose, repeat
#import "_design.typ": brand-card

#impose(
  repeat()[
    #brand-card(accent: rgb("#2f8f46"))
  ],
  paper: "a4",
  trim-size: (85mm, 55mm),
  rows: 4,
  columns: 2,
  margin: 12mm,
  gap: 0mm,
  cut-mode: "single",
  bleed: 0pt,
  safe: 4mm,
  marks: (
    crop: true,
    crop-mode: "grid",
    safe: true,
    registration: true,
    color-bar: true,
  ),
  proof: true,
  slug: (
    job: "single cut grid crop marks",
    sheet: true,
    grid: true,
    cut-mode: true,
  ),
)
