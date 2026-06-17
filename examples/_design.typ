#let brand-card(name: "John Doe", accent: rgb("#e5482d")) = {
  rect(width: 100%, height: 100%, fill: rgb("#fff8eb"))[
    #pad(x: 7mm, y: 6mm)[
      #text(size: 8pt, fill: accent, weight: "bold")[SHEETWISE]
      #v(5.5mm)
      #text(size: 15pt, weight: "bold")[#name]
      #v(2mm)
      #text(size: 7pt)[Typst print imposition tools]
      #v(1.5mm)
      #text(size: 5.7pt, fill: rgb("#444"))[john.doe\@example.com]
      #v(3.5mm)
      #rect(width: 100%, height: 0.8pt, fill: accent)
    ]
  ]
}

#let brand-card-back(accent: rgb("#235789")) = {
  rect(width: 100%, height: 100%, fill: rgb("#eef6ff"))[
    #pad(x: 6mm, y: 5mm)[
      #text(size: 8pt, fill: accent, weight: "bold")[BACK SIDE]
      #v(10mm)
      #text(size: 18pt, weight: "bold")[sheetwise]
      #v(3mm)
      #text(size: 7pt)[Duplex imposition test]
    ]
  ]
}

#let ticket(number) = {
  rect(width: 100%, height: 100%, fill: rgb("#f4fbff"))[
    #pad(x: 5mm, y: 5mm)[
      #text(size: 7pt, fill: rgb("#207090"), weight: "bold")[ADMIT ONE]
      #v(2mm)
      #text(size: 18pt, weight: "bold")[#numbering("0001", number)]
    ]
  ]
}
