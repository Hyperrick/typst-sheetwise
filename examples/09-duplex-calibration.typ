#import "@preview/sheetwise:0.1.0": calibration, impose

#impose(
  calibration(flip: "long-edge", back-rotation: 180deg),
  paper: "a4",
  marks: (registration: true, color-bar: true),
  slug: (job: "duplex calibration", sheet: true),
)
