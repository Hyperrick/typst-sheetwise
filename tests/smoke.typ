#import "../lib.typ": gangup, grid-plan, paper-size, saddle-stitch-plan

#let a4 = paper-size("a4")
#assert.eq(a4.width, 210mm)
#assert.eq(a4.height, 297mm)

#let landscape = paper-size("a4", orientation: "landscape")
#assert.eq(landscape.width, 297mm)
#assert.eq(landscape.height, 210mm)

#let plan = grid-plan(
  paper: "a4",
  item-size: (85mm, 55mm),
  margin: 12mm,
  gap: 4mm,
)
#assert.eq(plan.columns, 2)
#assert.eq(plan.rows, 4)
#assert.eq(plan.slots, 8)

#let auto-plan = grid-plan(
  paper: "a4",
  item-size: (125mm, 40mm),
  item-orientation: "auto",
  margin: 10mm,
  gap: 4mm,
)
#assert.eq(auto-plan.item.width, 40mm)
#assert.eq(auto-plan.item.height, 125mm)

#let booklet = saddle-stitch-plan(8)
#assert.eq(booklet.len(), 2)
#assert.eq(booklet.at(0).front.left, 8)
#assert.eq(booklet.at(0).front.right, 1)
#assert.eq(booklet.at(0).back.left, 2)
#assert.eq(booklet.at(0).back.right, 7)
#assert.eq(booklet.at(1).front.left, 6)
#assert.eq(booklet.at(1).front.right, 3)
#assert.eq(booklet.at(1).back.left, 4)
#assert.eq(booklet.at(1).back.right, 5)

#let padded = saddle-stitch-plan(10, blank-policy: "end")
#assert.eq(padded.len(), 3)
#assert.eq(padded.at(0).front.left, 12)
#assert.eq(padded.at(0).front.right, 1)

Smoke tests passed.

#pagebreak()

#gangup(
  paper: "a6",
  item-size: (35mm, 20mm),
  rows: 2,
  columns: 2,
  margin: 10mm,
  gap: 0mm,
  cut-mode: "single",
  marks: (crop: true),
)[
  #rect(width: 100%, height: 100%, fill: rgb("#fff8eb"))
]
