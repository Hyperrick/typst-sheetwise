#import "../lib.typ": impose, repeat

#let tag = rect(width: 100%, height: 100%, fill: rgb("#f2fff2"))[
  #align(center + horizon)[
    #text(size: 16pt, weight: "bold")[AUTO]
    #v(2mm)
    Sheetwise may rotate the item format to fit more pieces.
  ]
]

#impose(
  repeat()[
    #tag
  ],
  paper: "a4",
  trim-size: (95mm, 45mm),
  item-orientation: "auto",
  margin: 10mm,
  gap: 4mm,
  bleed: 2mm,
  marks: (crop: true, bleed: true, safe: true),
  safe: 4mm,
  proof: true,
  slug: (job: "auto orientation", sheet: true, grid: true),
)
