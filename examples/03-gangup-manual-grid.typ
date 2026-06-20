#import "../lib.typ": impose, repeat
#import "_design.typ": brand-card

#impose(
  repeat()[
    #brand-card(accent: rgb("#235789"))
  ],
  paper: "sra3",
  orientation: "landscape",
  trim-size: (85mm, 55mm),
  rows: 4,
  columns: 4,
  margin: 15mm,
  gap: (6mm, 5mm),
  bleed: 3mm,
  safe: 4mm,
  proof: true,
  slug: "sheetwise manual grid: SRA3 landscape, 4 columns x 4 rows",
)
