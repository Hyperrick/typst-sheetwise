#import "../lib.typ": duplex-calibration

#duplex-calibration(
  paper: "a4",
  flip: "long-edge",
  back-rotation: 180deg,
  marks: (registration: true, color-bar: true),
  slug: (job: "duplex calibration", sheet: true),
)

