#import "../lib.typ": impose, repeat
#import "_design.typ": brand-card

#impose(
  repeat()[
    #brand-card(accent: rgb("#7a3db8"))
  ],
  paper: "a4",
  trim-size: (85mm, 55mm),
  margin: (left: 18mm, right: 8mm, top: 12mm, bottom: 28mm),
  gap: 4mm,
  marks: (crop: true, safe: true, registration: true),
  safe: 4mm,
  proof: true,
  slug: (job: "asymmetric margins", sheet: true, grid: true),
)
