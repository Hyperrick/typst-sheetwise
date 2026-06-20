#import "../lib.typ": booklet, impose, marks-only, pdf, repeat, sequence, variants

#let card = rect(width: 100%, height: 100%, fill: rgb("#fff8eb"))[
  #pad(6mm)[
    #text(size: 15pt, weight: "bold")[John Doe]
    #v(2mm)
    Typst print imposition tools
  ]
]

#impose(
  repeat()[#card],
  paper: "a4",
  trim-size: (85mm, 55mm),
  margin: 12mm,
  gap: 6mm,
  cut-mode: "double",
  bleed: 3mm,
  safe: 4mm,
  marks: (crop: true, bleed: true, safe: true, color-bar: true),
  slug: (job: "business cards", sheet: true, grid: true),
)

#pagebreak()

#let card-a = card
#let card-b = rect(width: 100%, height: 100%, fill: rgb("#eef7ff"))[]
#let card-c = rect(width: 100%, height: 100%, fill: rgb("#f1ffe8"))[]

#impose(
  variants(
    items: (
      (label: "A", copies: 3, body: card-a),
      (label: "B", copies: 2, body: card-b),
      (label: "C", copies: 3, body: card-c),
    ),
  ),
  paper: "a4",
  trim-size: (85mm, 55mm),
)

#pagebreak()

#let ticket(n) = rect(width: 100%, height: 100%, fill: rgb("#fff5e6"))[
  #align(center + horizon)[#text(size: 18pt, weight: "bold")[#n]]
]

#impose(
  sequence(
    count: 36,
    stack-flow: ("deep", "right", "down"),
    item: n => ticket(n),
  ),
  paper: "a4",
  trim-size: (70mm, 35mm),
  rows: 6,
  columns: 2,
)

#pagebreak()

#impose(
  pdf(
    read("../build/business-card-source.pdf", encoding: none),
    source-name: "business-card-source.pdf",
  ),
  paper: "a4",
  trim-size: (85mm, 55mm),
  cut-mode: "double",
  marks: (crop: true, registration: true, file-header: true, page-border: true),
)

#pagebreak()

#impose(
  booklet(
    read("../examples/build/booklet-source.pdf", encoding: none),
    source-name: "booklet-source.pdf",
    page-count: 8,
    creep: (paper-thickness: 0.12mm),
  ),
  paper: "sra3",
  orientation: "landscape",
  trim-size: (148mm, 210mm),
  marks: (crop: true, registration: true, color-bar: true, fold: true, file-header: true),
)

#pagebreak()

#impose(
  marks-only(
    regions: (
      (x: 18mm, y: 20mm, width: 50mm, height: 30mm, label: "A"),
      (x: 82mm, y: 20mm, width: 50mm, height: 30mm, label: "B"),
    ),
  ),
  paper: "a4",
  bleed: 2mm,
  marks: (crop: true, registration: true),
  proof: true,
)
