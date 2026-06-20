#import "../lib.typ": booklet, impose

#impose(
  booklet("missing.pdf", page-count: 4),
  trim-size: (50mm, 90mm),
  bleed: -1mm,
)
