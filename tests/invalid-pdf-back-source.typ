#import "../lib.typ": impose, pdf

#impose(
  pdf("front.pdf", back-source: "back.pdf"),
  paper: "a6",
  trim-size: (35mm, 20mm),
  rows: 1,
  columns: 1,
)
