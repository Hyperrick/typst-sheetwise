#import "../lib.typ": impose, repeat
#import "_design.typ": brand-card

#impose(
  repeat()[
    #brand-card()
  ],
  paper: "a4",
  trim-size: (85mm, 55mm),
  margin: 12mm,
  gap: 6mm,
  cut-mode: "double",
  bleed: 3mm,
  safe: 4mm,
  marks: (crop: true, bleed: true, safe: true, color-bar: true),
  proof: true,
  slug: (
    job: "auto gangup with double cut",
    sheet: true,
    grid: true,
    bleed: true,
    cut-mode: true,
  ),
)
