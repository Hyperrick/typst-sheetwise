#import "@preview/sheetwise:0.1.0": impose, booklet

#impose(
  booklet(
    read("build/booklet-source.pdf", encoding: none),
    source-name: "booklet-source.pdf",
    page-count: 8,
    creep: (paper-thickness: 0.12mm),
  ),
  paper: "sra3",
  orientation: "landscape",
  trim-size: (148mm, 210mm),
  margin: 18mm,
  gap: 0mm,
  bleed: 3mm,
  safe: 5mm,
  marks: (crop: true, bleed: true, safe: true, registration: true, color-bar: true, fold: true, file-header: true, page-border: true),
  proof: true,
  slug: (job: "saddle-stitch PDF", sheet: true, bleed: true),
)
