#import "../lib.typ": impose, pdf

#impose(
  pdf(read("build/business-card-source.pdf", encoding: none)),
  paper: "a4",
  trim-size: (85mm, 55mm),
  margin: 12mm,
  gap: 6mm,
  cut-mode: "double",
  bleed: 0pt,
  safe: 4mm,
  marks: (crop: true, safe: true, registration: true, color-bar: true),
  proof: true,
  slug: (
    job: "finished PDF input",
    sheet: true,
    grid: true,
    cut-mode: true,
  ),
)
