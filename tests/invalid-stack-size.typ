#import "../lib.typ": impose, sequence

#impose(
  sequence(
    count: 5,
    stack-size: 1,
    item: n => [#n],
  ),
  paper: "a6",
  trim-size: (35mm, 20mm),
  rows: 2,
  columns: 2,
)
