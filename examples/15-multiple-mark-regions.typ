#import "@preview/sheetwise:0.1.0": impose, marks-only

#impose(
  marks-only(
    regions: (
      (x: 18mm, y: 20mm, width: 50mm, height: 30mm, label: "A"),
      (x: 82mm, y: 20mm, width: 50mm, height: 30mm, label: "B"),
      (x: 146mm, y: 20mm, width: 50mm, height: 30mm, label: "C"),
    ),
  ),
  paper: "a4",
  bleed: 2mm,
  marks: (crop: true, registration: true, color-bar: true),
  proof: true,
  slug: (job: "multiple independent mark regions", sheet: true),
)
