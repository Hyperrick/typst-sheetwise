#import "../lib.typ": impose, pdf

#impose(
  pdf("front.pdf", page: 0),
  paper: "a6",
  trim-size: (35mm, 20mm),
  rows: 1,
  columns: 1,
)
