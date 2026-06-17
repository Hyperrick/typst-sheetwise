#set page(width: 148mm, height: 210mm, margin: 15mm)
#set text(font: "New Computer Modern", size: 13pt)

#for n in range(1, 9) {
  align(center + horizon)[
    #text(size: 42pt, weight: "bold")[Page #n]
    #v(8mm)
    This is the reader-order source page.
  ]
  if n < 8 {
    pagebreak()
  }
}

