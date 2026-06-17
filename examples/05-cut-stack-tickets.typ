#import "../lib.typ": cut-stack
#import "_design.typ": ticket

#cut-stack(
  paper: "a4",
  item-size: (70mm, 35mm),
  rows: 6,
  columns: 2,
  margin: 10mm,
  gap: 4mm,
  count: 36,
  flow: "cut-stack",
  stack-flow: ("deep", "right", "down"),
  bleed: 2mm,
  safe: 3mm,
  marks: (crop: true, registration: true, color-bar: true),
  proof: true,
  slug: (job: "cut-stack tickets", sheet: true, grid: true),
  item: n => ticket(n),
)
