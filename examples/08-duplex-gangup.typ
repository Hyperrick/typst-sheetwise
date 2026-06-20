#import "../lib.typ": impose, repeat
#import "_design.typ": brand-card, brand-card-back

#impose(
  repeat(
    duplex: true,
    back: brand-card-back(),
    flip: "long-edge",
    back-rotation: 180deg,
  )[
    #brand-card()
  ],
  paper: "a4",
  trim-size: (85mm, 55mm),
  rows: 4,
  columns: 2,
  margin: 12mm,
  gap: 4mm,
  bleed: 2mm,
  safe: 4mm,
  marks: (crop: true, registration: true, color-bar: true),
  proof: true,
  slug: (job: "duplex gangup", sheet: true, grid: true),
)
