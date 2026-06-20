#import "../lib.typ": booklet-plan, grid-plan, impose, marks-only, paper-size, registration-color, repeat, sequence, variants

#let a4 = paper-size("a4")
#assert.eq(a4.width, 210mm)
#assert.eq(a4.height, 297mm)

#let landscape = paper-size("a4", orientation: "landscape")
#assert.eq(landscape.width, 297mm)
#assert.eq(landscape.height, 210mm)

#assert.eq(registration-color, cmyk(100%, 100%, 100%, 100%))

#let plan = grid-plan(
  paper: "a4",
  trim-size: (85mm, 55mm),
  margin: 12mm,
  gap: 4mm,
)
#assert.eq(plan.columns, 2)
#assert.eq(plan.rows, 4)
#assert.eq(plan.slots, 8)
#assert.eq(plan.margin.left, 12mm)
#assert.eq(plan.margin.right, 12mm)

#let side-plan = grid-plan(
  paper: "a4",
  trim-size: (85mm, 55mm),
  margin: (left: 20mm, right: 5mm, top: 12mm, bottom: 18mm),
  gap: 4mm,
)
#assert.eq(side-plan.margin.left, 20mm)
#assert.eq(side-plan.margin.right, 5mm)
#assert.eq(side-plan.margin.top, 12mm)
#assert.eq(side-plan.margin.bottom, 18mm)

#let auto-plan = grid-plan(
  paper: "a4",
  trim-size: (125mm, 40mm),
  item-orientation: "auto",
  margin: 10mm,
  gap: 4mm,
)
#assert.eq(auto-plan.item.width, 40mm)
#assert.eq(auto-plan.item.height, 125mm)

#let booklet = booklet-plan(8)
#assert.eq(booklet.len(), 2)
#assert.eq(booklet.at(0).front.left, 8)
#assert.eq(booklet.at(0).front.right, 1)
#assert.eq(booklet.at(0).back.left, 2)
#assert.eq(booklet.at(0).back.right, 7)
#assert.eq(booklet.at(1).front.left, 6)
#assert.eq(booklet.at(1).front.right, 3)
#assert.eq(booklet.at(1).back.left, 4)
#assert.eq(booklet.at(1).back.right, 5)

#let padded = booklet-plan(10, blank-policy: "end")
#assert.eq(padded.len(), 3)
#assert.eq(padded.at(0).front.left, 12)
#assert.eq(padded.at(0).front.right, 1)

Smoke tests passed.

#pagebreak()

#impose(
  repeat(copies: 1)[
    #rect(width: 100%, height: 100%, fill: rgb("#fff8eb"))
  ],
  paper: "a6",
  trim-size: (35mm, 20mm),
  rows: 2,
  columns: 2,
  margin: 10mm,
  gap: 0mm,
  cut-mode: "single",
  marks: (crop: true),
)

#pagebreak()

#impose(
  variants(
    order: "reverse",
    items: (
      (label: "A", copies: 2, body: [#rect(width: 100%, height: 100%, fill: rgb("#eef7ff"))]),
      (label: "B", copies: 1, body: [#rect(width: 100%, height: 100%, fill: rgb("#f1ffe8"))]),
    ),
  ),
  paper: "a6",
  trim-size: (35mm, 20mm),
  rows: 2,
  columns: 2,
  margin: 10mm,
  gap: 0mm,
  marks: (crop: true, crop-mode: "grid"),
)

#pagebreak()

#impose(
  sequence(
    count: 5,
    stack-size: 2,
    order: "reverse",
    item: n => [
      #rect(width: 100%, height: 100%, fill: rgb("#fff0f0"))
      #align(center + horizon)[#n]
    ],
  ),
  paper: "a6",
  trim-size: (35mm, 20mm),
  rows: 2,
  columns: 2,
  margin: 10mm,
  gap: 0mm,
  marks: (crop: true, crop-mode: "grid"),
)

#pagebreak()

#impose(
  marks-only(
    regions: (
      (x: 10mm, y: 10mm, width: 20mm, height: 15mm),
      (x: 40mm, y: 10mm, width: 20mm, height: 15mm),
    ),
  ),
  paper: "a6",
  marks: (crop: true, registration: true),
  proof: true,
)
