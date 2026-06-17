#import "../lib.typ": gangup
#import "_design.typ": brand-card

#gangup(
  paper: "sra3",
  orientation: "landscape",
  item-size: (85mm, 55mm),
  rows: 4,
  columns: 4,
  margin: 15mm,
  gap: (6mm, 5mm),
  bleed: 3mm,
  safe: 4mm,
  proof: true,
  slug: "sheetwise manual grid: SRA3 landscape, 4 columns x 4 rows",
)[
  #brand-card(accent: rgb("#235789"))
]

