#import "../lib.typ": cut-stack

#cut-stack(
  paper: "a6",
  item-size: (35mm, 20mm),
  rows: 2,
  columns: 2,
  count: 5,
  stack-size: 1,
  item: n => [#n],
)
