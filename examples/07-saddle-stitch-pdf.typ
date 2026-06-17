#import "../lib.typ": saddle-stitch-pdf

#saddle-stitch-pdf(
  "examples/build/booklet-source.pdf",
  page-count: 8,
  paper: "sra3",
  orientation: "landscape",
  trim-size: (148mm, 210mm),
  margin: 18mm,
  gap: 0mm,
  bleed: 3mm,
  safe: 5mm,
  creep: (paper-thickness: 0.12mm),
  marks: (crop: true, bleed: true, safe: true, registration: true, color-bar: true, fold: true),
  proof: true,
  slug: (job: "saddle-stitch PDF", sheet: true, bleed: true),
)
