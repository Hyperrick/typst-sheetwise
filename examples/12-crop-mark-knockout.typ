#import "@preview/sheetwise:0.1.0": impose, repeat

#set page(fill: rgb("#151515"))

#impose(
  repeat()[
    #rect(width: 100%, height: 100%, fill: rgb("#222222"))[
      #pad(7mm)[
        #text(size: 15pt, weight: "bold", fill: white)[John Doe]
        #v(2mm)
        #text(size: 8pt, fill: rgb("#dddddd"))[Crop marks stay visible on dark artwork.]
      ]
    ]
  ],
  paper: "a4",
  trim-size: (85mm, 55mm),
  rows: 2,
  columns: 2,
  margin: 12mm,
  gap: 8mm,
  bleed: 0pt,
  marks: (crop: true),
  mark-style: (
    offset: 0pt,
    length: 8mm,
    thickness: 0.35pt,
    knockout: true,
    knockout-padding: 1.1pt,
  ),
  slug: (job: "crop mark knockout", sheet: true),
)
