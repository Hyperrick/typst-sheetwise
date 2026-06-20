#import "../lib.typ": impose, variants
#import "_design.typ": brand-card

#let red = brand-card(name: "Sort A", accent: rgb("#e5482d"))
#let blue = brand-card(name: "Sort B", accent: rgb("#235789"))
#let green = brand-card(name: "Sort C", accent: rgb("#2f8f46"))

#impose(
  variants(
    items: (
      (label: "A", copies: 3, body: red),
      (label: "B", copies: 2, body: blue),
      (label: "C", copies: 3, body: green),
    ),
  ),
  paper: "a4",
  trim-size: (85mm, 55mm),
  rows: 4,
  columns: 2,
  margin: 12mm,
  gap: 4mm,
  bleed: 3mm,
  safe: 4mm,
  marks: (crop: true, registration: true, color-bar: true),
  proof: true,
  slug: (job: "mixed versions", sheet: true, grid: true),
)
