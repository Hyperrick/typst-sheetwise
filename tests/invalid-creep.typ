#import "../lib.typ": booklet, impose

#impose(
  booklet("booklet.pdf", page-count: 8, creep: -1mm),
  trim-size: (35mm, 20mm),
)
