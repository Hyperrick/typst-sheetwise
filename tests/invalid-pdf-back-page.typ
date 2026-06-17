#import "../lib.typ": gangup-pdf

#gangup-pdf(
  "front.pdf",
  page: 1,
  duplex: true,
  back-source: "back.pdf",
  back-page: 0,
  paper: "a6",
  item-size: (35mm, 20mm),
  rows: 1,
  columns: 1,
)
