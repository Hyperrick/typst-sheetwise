#import "../lib.typ": impose, sequence
#import "_design.typ": ticket

#impose(
  sequence(
    count: 36,
    flow: "cut-stack",
    stack-flow: ("deep", "right", "down"),
    item: n => ticket(n),
  ),
  paper: "a4",
  trim-size: (70mm, 35mm),
  rows: 6,
  columns: 2,
  margin: 10mm,
  gap: 4mm,
  bleed: 2mm,
  safe: 3mm,
  marks: (crop: true, registration: true, color-bar: true),
  proof: true,
  slug: (job: "cut-and-stack tickets", sheet: true, grid: true),
)
