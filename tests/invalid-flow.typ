#import "../lib.typ": cut-stack

#cut-stack(
  paper: "a6",
  item-size: (35mm, 20mm),
  rows: 1,
  columns: 1,
  count: 1,
  flow: "sideways",
  item: n => [#n],
)
