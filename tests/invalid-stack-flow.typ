#import "../lib.typ": impose, sequence

#impose(
  sequence(
    count: 1,
    stack-flow: ("deep", "deep", "right"),
    item: n => [#n],
  ),
  paper: "a6",
  trim-size: (35mm, 20mm),
  rows: 1,
  columns: 1,
)
