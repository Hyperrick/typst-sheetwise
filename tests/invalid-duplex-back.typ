#import "../lib.typ": impose, repeat

#impose(
  repeat(duplex: true)[x],
  paper: "a6",
  trim-size: (35mm, 20mm),
  rows: 1,
  columns: 1,
)
