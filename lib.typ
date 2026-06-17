#let _paper-sizes = (
  a6: (width: 105mm, height: 148mm),
  a5: (width: 148mm, height: 210mm),
  a4: (width: 210mm, height: 297mm),
  a3: (width: 297mm, height: 420mm),
  sra3: (width: 320mm, height: 450mm),
  letter: (width: 8.5in, height: 11in),
  legal: (width: 8.5in, height: 14in),
  tabloid: (width: 11in, height: 17in),
)

#let _default-mark-style = (
  color: black,
  length: 5mm,
  offset: auto,
  bleed-offset: 0pt,
  no-bleed-offset: 2mm,
  thickness: 0.25pt,
  knockout: true,
  knockout-color: white,
  knockout-padding: 0.7pt,
)

#let _proof-color = rgb("#1070c9")
#let _bleed-color = rgb("#c94510")
#let _safe-color = rgb("#10a35a")
#let _label-color = rgb("#555555")
#let _registration-color = rgb("#222222")

#let _default-marks = (
  crop: true,
  crop-mode: "auto",
  bleed: false,
  safe: false,
  registration: false,
  color-bar: false,
  fold: false,
)

#let _positive(value, name) = {
  if value <= 0pt {
    panic("sheetwise: `" + name + "` must be greater than zero.")
  }
  value
}

#let _non-negative(value, name) = {
  if value < 0pt {
    panic("sheetwise: `" + name + "` must not be negative.")
  }
  value
}

#let _has-key(dict, key) = dict.keys().contains(key)

#let _get(dict, key, default) = {
  if _has-key(dict, key) {
    dict.at(key)
  } else {
    default
  }
}

#let _merge(defaults, overrides) = {
  let result = defaults
  for key in overrides.keys() {
    result.insert(key, overrides.at(key))
  }
  result
}

#let _normalize-marks(marks, proof: false) = {
  if marks == true {
    _default-marks
  } else if marks == false or marks == none {
    (
      crop: false,
      crop-mode: "auto",
      bleed: false,
      safe: false,
      registration: false,
      color-bar: false,
      fold: false,
    )
  } else if type(marks) == dictionary {
    _merge(_default-marks, marks)
  } else {
    panic("sheetwise: `marks` must be a boolean, `none`, or a dictionary.")
  }
}

#let _crop-mode(marks, plan, cut-mode) = {
  let mode = _get(marks, "crop-mode", _default-marks.at("crop-mode"))
  if mode == "auto" {
    if cut-mode == "single" and plan.gap.width == 0pt and plan.gap.height == 0pt {
      "grid"
    } else {
      "per-item"
    }
  } else if mode == "per-item" or mode == "grid" {
    mode
  } else {
    panic("sheetwise: `marks.crop-mode` must be `auto`, `per-item`, or `grid`.")
  }
}

#let _normalize-slug(slug, meta: (:)) = {
  if slug == none or slug == false {
    none
  } else if type(slug) == str {
    slug
  } else if type(slug) == dictionary {
    if _has-key(slug, "enabled") and not slug.enabled {
      return none
    }

    let parts = ()
    if _has-key(slug, "job") {
      parts.push(slug.job)
    }
    if _has-key(slug, "date") and slug.date != false {
      let date = if slug.date == auto { datetime.today() } else { slug.date }
      parts.push(repr(date))
    }
    if _get(slug, "sheet", false) and _has-key(meta, "sheet-number") {
      parts.push("sheet " + str(meta.at("sheet-number")) + "/" + str(meta.at("sheet-count")))
    }
    if _has-key(meta, "side") {
      parts.push(str(meta.side))
    }
    if _get(slug, "grid", false) and _has-key(meta, "plan") {
      let plan = meta.plan
      parts.push(str(plan.columns) + " x " + str(plan.rows))
    }
    if _get(slug, "bleed", false) and _has-key(meta, "bleed") {
      parts.push("bleed " + repr(meta.bleed))
    }
    if _get(slug, "cut-mode", false) and _has-key(meta, "cut-mode") {
      parts.push("cut " + meta.at("cut-mode"))
    }
    if _has-key(slug, "text") {
      parts.push(slug.text)
    }

    if parts.len() == 0 {
      none
    } else {
      parts.join(" | ")
    }
  } else {
    panic("sheetwise: `slug` must be `none`, a string, or a dictionary.")
  }
}

#let _checked-dimension(value, name, positive) = {
  if positive {
    _positive(value, name)
  } else {
    _non-negative(value, name)
  }
}

#let _size(value, name, positive: true) = {
  if type(value) == dictionary {
    if _has-key(value, "width") and _has-key(value, "height") {
      return (
        width: _checked-dimension(value.width, name + ".width", positive),
        height: _checked-dimension(value.height, name + ".height", positive),
      )
    }
  }

  if type(value) == array and value.len() == 2 {
    return (
      width: _checked-dimension(value.at(0), name + ".width", positive),
      height: _checked-dimension(value.at(1), name + ".height", positive),
    )
  }

  panic("sheetwise: `" + name + "` must be `(width: ..., height: ...)` or `(width, height)`.")
}

#let _pair(value, name, positive: false) = {
  if type(value) == dictionary or type(value) == array {
    _size(value, name, positive: positive)
  } else {
    (
      width: _checked-dimension(value, name + ".width", positive),
      height: _checked-dimension(value, name + ".height", positive),
    )
  }
}

#let _orient-item(item, item-orientation) = {
  if item-orientation == "original" {
    item
  } else if item-orientation == "portrait" {
    if item.width <= item.height {
      item
    } else {
      (width: item.height, height: item.width)
    }
  } else if item-orientation == "landscape" {
    if item.width >= item.height {
      item
    } else {
      (width: item.height, height: item.width)
    }
  } else if item-orientation == "auto" {
    item
  } else {
    panic("sheetwise: `item-orientation` must be `auto`, `original`, `portrait`, or `landscape`.")
  }
}

#let paper-size(paper, orientation: "portrait") = {
  let size = if type(paper) == str {
    if not _paper-sizes.keys().contains(paper) {
      panic("sheetwise: unknown paper size `" + paper + "`.")
    }
    _paper-sizes.at(paper)
  } else {
    _size(paper, "paper")
  }

  if orientation == "portrait" {
    size
  } else if orientation == "landscape" {
    (width: size.height, height: size.width)
  } else {
    panic("sheetwise: `orientation` must be `portrait` or `landscape`.")
  }
}

#let _grid-plan(
  sheet,
  item-size,
  margin,
  gap,
  rows,
  columns,
  item-orientation: "original",
) = {
  let base-item = _size(item-size, "item-size")
  let margin = _size(margin, "margin", positive: false)
  let gap = _size(gap, "gap", positive: false)
  let usable-width = sheet.width - margin.width * 2
  let usable-height = sheet.height - margin.height * 2

  let candidate-items = if item-orientation == "auto" and base-item.width != base-item.height {
    (
      base-item,
      (width: base-item.height, height: base-item.width),
    )
  } else {
    (_orient-item(base-item, item-orientation),)
  }

  let best = none
  for item in candidate-items {
    if usable-width >= item.width and usable-height >= item.height {
      let auto-columns = calc.floor((usable-width + gap.width) / (item.width + gap.width))
      let auto-rows = calc.floor((usable-height + gap.height) / (item.height + gap.height))
      let candidate-columns = if columns == auto { auto-columns } else { columns }
      let candidate-rows = if rows == auto { auto-rows } else { rows }

      if candidate-columns >= 1 and candidate-rows >= 1 {
        let grid-width = candidate-columns * item.width + (candidate-columns - 1) * gap.width
        let grid-height = candidate-rows * item.height + (candidate-rows - 1) * gap.height

        if grid-width <= usable-width and grid-height <= usable-height {
          let plan = (
            item: item,
            margin: margin,
            gap: gap,
            rows: candidate-rows,
            columns: candidate-columns,
            slots: candidate-rows * candidate-columns,
            grid-width: grid-width,
            grid-height: grid-height,
            origin-x: margin.width + (usable-width - grid-width) / 2,
            origin-y: margin.height + (usable-height - grid-height) / 2,
            item-rotated: item.width != base-item.width or item.height != base-item.height,
          )

          if best == none or plan.slots > best.slots {
            best = plan
          }
        }
      }
    }
  }

  if best == none {
    panic("sheetwise: item/grid does not fit into the sheet after margins.")
  }

  best
}

#let _slot-position(plan, slot) = {
  let col = calc.rem(slot, plan.columns)
  let row = calc.floor(slot / plan.columns)

  (
    row: row,
    column: col,
    x: plan.origin-x + col * (plan.item.width + plan.gap.width),
    y: plan.origin-y + row * (plan.item.height + plan.gap.height),
  )
}

#let _slot-from-row-column(plan, row, col) = row * plan.columns + col

#let _duplex-slot(plan, slot, flip) = {
  let col = calc.rem(slot, plan.columns)
  let row = calc.floor(slot / plan.columns)

  if flip == "long-edge" {
    _slot-from-row-column(plan, row, plan.columns - 1 - col)
  } else if flip == "short-edge" {
    _slot-from-row-column(plan, plan.rows - 1 - row, col)
  } else if flip == "none" {
    slot
  } else {
    panic("sheetwise: `flip` must be `long-edge`, `short-edge`, or `none`.")
  }
}

#let _validate-cut-mode(cut-mode, plan, bleed) = {
  if cut-mode == "single" {
    return
  }

  if cut-mode != "double" {
    panic("sheetwise: `cut-mode` must be `single` or `double`.")
  }

  if plan.columns > 1 {
    if plan.gap.width <= 0pt {
      panic("sheetwise: `cut-mode: \"double\"` needs a horizontal gap for the removable strip.")
    }
    if bleed > 0pt and plan.gap.width < bleed * 2 {
      panic("sheetwise: `cut-mode: \"double\"` needs horizontal `gap >= 2 * bleed`.")
    }
  }

  if plan.rows > 1 {
    if plan.gap.height <= 0pt {
      panic("sheetwise: `cut-mode: \"double\"` needs a vertical gap for the removable strip.")
    }
    if bleed > 0pt and plan.gap.height < bleed * 2 {
      panic("sheetwise: `cut-mode: \"double\"` needs vertical `gap >= 2 * bleed`.")
    }
  }
}

#let _rotated(body, angle) = {
  if angle == 0deg {
    body
  } else {
    rotate(angle)[#body]
  }
}

#let _hline(x, y, width, color, thickness) = {
  place(top + left, dx: x, dy: y)[
    #rect(width: width, height: thickness, fill: color)
  ]
}

#let _vline(x, y, height, color, thickness) = {
  place(top + left, dx: x, dy: y)[
    #rect(width: thickness, height: height, fill: color)
  ]
}

#let _outline(x, y, width, height, color, thickness: 0.25pt) = {
  _hline(x, y, width, color, thickness)
  _hline(x, y + height, width, color, thickness)
  _vline(x, y, height, color, thickness)
  _vline(x + width, y, height, color, thickness)
}

#let _crop-mark-offset(bleed, style) = {
  let explicit = _get(style, "offset", _default-mark-style.offset)
  if explicit != auto {
    return _non-negative(explicit, "mark-style.offset")
  }

  if bleed > 0pt {
    bleed + _non-negative(_get(style, "bleed-offset", _default-mark-style.at("bleed-offset")), "mark-style.bleed-offset")
  } else {
    _non-negative(_get(style, "no-bleed-offset", _default-mark-style.at("no-bleed-offset")), "mark-style.no-bleed-offset")
  }
}

#let _backed-hline(x, y, width, color, thickness, style) = {
  if _get(style, "knockout", _default-mark-style.knockout) {
    let padding = _non-negative(_get(style, "knockout-padding", _default-mark-style.at("knockout-padding")), "mark-style.knockout-padding")
    let backing = _get(style, "knockout-color", _default-mark-style.at("knockout-color"))
    _hline(x - padding, y - padding, width + padding * 2, backing, thickness + padding * 2)
  }
  _hline(x, y, width, color, thickness)
}

#let _backed-vline(x, y, height, color, thickness, style) = {
  if _get(style, "knockout", _default-mark-style.knockout) {
    let padding = _non-negative(_get(style, "knockout-padding", _default-mark-style.at("knockout-padding")), "mark-style.knockout-padding")
    let backing = _get(style, "knockout-color", _default-mark-style.at("knockout-color"))
    _vline(x - padding, y - padding, height + padding * 2, backing, thickness + padding * 2)
  }
  _vline(x, y, height, color, thickness)
}

#let _crop-marks(x, y, width, height, bleed, style) = {
  let mark-length = _get(style, "length", _default-mark-style.length)
  let color = _get(style, "color", _default-mark-style.color)
  let thickness = _get(style, "thickness", _default-mark-style.thickness)
  let offset = _crop-mark-offset(bleed, style)

  _backed-hline(x - offset - mark-length, y, mark-length, color, thickness, style)
  _backed-hline(x + width + offset, y, mark-length, color, thickness, style)
  _backed-hline(x - offset - mark-length, y + height, mark-length, color, thickness, style)
  _backed-hline(x + width + offset, y + height, mark-length, color, thickness, style)

  _backed-vline(x, y - offset - mark-length, mark-length, color, thickness, style)
  _backed-vline(x + width, y - offset - mark-length, mark-length, color, thickness, style)
  _backed-vline(x, y + height + offset, mark-length, color, thickness, style)
  _backed-vline(x + width, y + height + offset, mark-length, color, thickness, style)
}

#let _push-unique(values, value) = {
  if not values.contains(value) {
    values.push(value)
  }
  values
}

#let _grid-crop-marks(plan, bleed, style) = {
  let mark-length = _get(style, "length", _default-mark-style.length)
  let color = _get(style, "color", _default-mark-style.color)
  let thickness = _get(style, "thickness", _default-mark-style.thickness)
  let offset = _crop-mark-offset(bleed, style)
  let grid-left = plan.origin-x
  let grid-top = plan.origin-y
  let grid-right = plan.origin-x + plan.grid-width
  let grid-bottom = plan.origin-y + plan.grid-height

  let x-lines = ()
  for col in range(plan.columns) {
    let left = plan.origin-x + col * (plan.item.width + plan.gap.width)
    let right = left + plan.item.width
    x-lines = _push-unique(x-lines, left)
    x-lines = _push-unique(x-lines, right)
  }

  let y-lines = ()
  for row in range(plan.rows) {
    let top = plan.origin-y + row * (plan.item.height + plan.gap.height)
    let bottom = top + plan.item.height
    y-lines = _push-unique(y-lines, top)
    y-lines = _push-unique(y-lines, bottom)
  }

  for x in x-lines {
    _backed-vline(x, grid-top - offset - mark-length, mark-length, color, thickness, style)
    _backed-vline(x, grid-bottom + offset, mark-length, color, thickness, style)
  }

  for y in y-lines {
    _backed-hline(grid-left - offset - mark-length, y, mark-length, color, thickness, style)
    _backed-hline(grid-right + offset, y, mark-length, color, thickness, style)
  }
}

#let _registration-mark(x, y, size: 5mm, thickness: 0.25pt, color: _registration-color) = {
  _hline(x - size / 2, y, size, color, thickness)
  _vline(x, y - size / 2, size, color, thickness)
  _outline(x - size / 4, y - size / 4, size / 2, size / 2, color, thickness: thickness)
}

#let _sheet-registration-marks(sheet, margin: 6mm) = {
  _registration-mark(margin, margin)
  _registration-mark(sheet.width - margin, margin)
  _registration-mark(margin, sheet.height - margin)
  _registration-mark(sheet.width - margin, sheet.height - margin)
}

#let _color-bar(x: 8mm, y: 4mm, width: 5mm, height: 3mm) = {
  let colors = (
    cmyk(100%, 0%, 0%, 0%),
    cmyk(0%, 100%, 0%, 0%),
    cmyk(0%, 0%, 100%, 0%),
    cmyk(0%, 0%, 0%, 100%),
    rgb("#ffffff"),
    rgb("#808080"),
  )

  for i in range(colors.len()) {
    place(top + left, dx: x + i * width, dy: y)[
      #rect(width: width, height: height, fill: colors.at(i), stroke: 0.2pt + black)
    ]
  }
}

#let _fold-mark(sheet, x: auto, y: auto, size: 6mm, color: _registration-color, thickness: 0.25pt) = {
  if x != auto {
    _vline(x, 3mm, size, color, thickness)
    _vline(x, sheet.height - 3mm - size, size, color, thickness)
  }
  if y != auto {
    _hline(3mm, y, size, color, thickness)
    _hline(sheet.width - 3mm - size, y, size, color, thickness)
  }
}

#let _sheet-marks(sheet, marks, fold-x: auto, fold-y: auto) = {
  if marks.registration {
    _sheet-registration-marks(sheet)
  }
  if marks.color-bar {
    _color-bar()
  }
  if marks.fold {
    _fold-mark(sheet, x: fold-x, y: fold-y)
  }
}

#let _slug(sheet, message) = {
  if message != none {
    place(top + left, dx: 4mm, dy: sheet.height - 7mm)[
      #text(size: 6pt, fill: _label-color)[#message]
    ]
  }
}

#let _slot-label(pos, label) = {
  if label != none {
    place(top + left, dx: pos.x + 1.5mm, dy: pos.y + 1.2mm)[
      #text(size: 5pt, fill: _label-color)[#label]
    ]
  }
}

#let _draw-slot(
  pos,
  plan,
  body,
  bleed: 0pt,
  safe: 0pt,
  marks: true,
  proof: false,
  mark-style: _default-mark-style,
  label: none,
  crop-mode: "per-item",
) = {
  let marks = _normalize-marks(marks)

  if (proof or marks.bleed) and bleed > 0pt {
    _outline(pos.x - bleed, pos.y - bleed, plan.item.width + bleed * 2, plan.item.height + bleed * 2, _bleed-color)
  }

  place(top + left, dx: pos.x, dy: pos.y)[
    #box(width: plan.item.width, height: plan.item.height)[#body]
  ]

  if proof {
    _outline(pos.x, pos.y, plan.item.width, plan.item.height, _proof-color)
    _slot-label(pos, label)
  }

  if (proof or marks.safe) and safe > 0pt {
    _outline(
      pos.x + safe,
      pos.y + safe,
      plan.item.width - safe * 2,
      plan.item.height - safe * 2,
      _safe-color,
    )
  }

  if marks.crop and crop-mode == "per-item" {
    _crop-marks(pos.x, pos.y, plan.item.width, plan.item.height, bleed, mark-style)
  }
}

#let _sheet(sheet, body, slug: none, meta: (:), marks: false, fold-x: auto, fold-y: auto) = {
  let marks = _normalize-marks(marks)
  block(width: sheet.width, height: sheet.height)[
    #body
    #_sheet-marks(sheet, marks, fold-x: fold-x, fold-y: fold-y)
    #_slug(sheet, _normalize-slug(slug, meta: meta))
  ]
}

#let grid-plan(
  paper: "a4",
  orientation: "portrait",
  item-size: auto,
  item-orientation: "original",
  margin: 10mm,
  gap: 3mm,
  rows: auto,
  columns: auto,
) = {
  let sheet = paper-size(paper, orientation: orientation)
  let margin = if type(margin) == dictionary or type(margin) == array {
    margin
  } else {
    (margin, margin)
  }
  let gap = if type(gap) == dictionary or type(gap) == array {
    gap
  } else {
    (gap, gap)
  }
  _grid-plan(sheet, item-size, margin, gap, rows, columns, item-orientation: item-orientation)
}

#let gangup(
  paper: "a4",
  orientation: "portrait",
  item-size: auto,
  item-orientation: "original",
  margin: 10mm,
  gap: 3mm,
  rows: auto,
  columns: auto,
  copies: auto,
  cut-mode: "single",
  bleed: 0pt,
  safe: 0pt,
  marks: true,
  mark-style: _default-mark-style,
  proof: false,
  slug: none,
  duplex: false,
  back: none,
  back-rotation: 180deg,
  flip: "long-edge",
  body,
) = {
  let sheet = paper-size(paper, orientation: orientation)
  let margin = _pair(margin, "margin")
  let gap = _pair(gap, "gap")
  let bleed = _non-negative(bleed, "bleed")
  let safe = _non-negative(safe, "safe")
  let plan = _grid-plan(sheet, item-size, margin, gap, rows, columns, item-orientation: item-orientation)
  _validate-cut-mode(cut-mode, plan, bleed)
  let copies = if copies == auto { plan.slots } else { copies }
  let sheet-marks = _normalize-marks(marks)
  let crop-mode = _crop-mode(sheet-marks, plan, cut-mode)

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  _sheet(
    sheet,
    slug: slug,
    marks: sheet-marks,
    meta: (sheet-number: 1, sheet-count: if duplex and back != none { 2 } else { 1 }, side: "front", plan: plan, bleed: bleed, cut-mode: cut-mode),
  )[
    #for slot in range(plan.slots) {
      if slot < copies {
        let pos = _slot-position(plan, slot)
        _draw-slot(
          pos,
          plan,
          body,
          bleed: bleed,
          safe: safe,
          marks: sheet-marks,
          proof: proof,
          mark-style: mark-style,
          label: str(slot + 1),
          crop-mode: crop-mode,
        )
      }
    }
    #if sheet-marks.crop and crop-mode == "grid" {
      _grid-crop-marks(plan, bleed, mark-style)
    }
  ]

  if duplex and back != none {
    pagebreak()
    _sheet(
      sheet,
      slug: slug,
      marks: sheet-marks,
      meta: (sheet-number: 2, sheet-count: 2, side: "back", plan: plan, bleed: bleed, cut-mode: cut-mode),
    )[
      #for slot in range(plan.slots) {
        if slot < copies {
          let back-slot = _duplex-slot(plan, slot, flip)
          let pos = _slot-position(plan, back-slot)
          _draw-slot(
            pos,
            plan,
            _rotated(back, back-rotation),
            bleed: bleed,
            safe: safe,
            marks: sheet-marks,
            proof: proof,
            mark-style: mark-style,
            label: str(slot + 1) + " back",
            crop-mode: crop-mode,
          )
        }
      }
      #if sheet-marks.crop and crop-mode == "grid" {
        _grid-crop-marks(plan, bleed, mark-style)
      }
    ]
  }
}

#let gangup-pdf(
  source,
  page: 1,
  fit: "stretch",
  alt: none,
  paper: "a4",
  orientation: "portrait",
  item-size: auto,
  item-orientation: "original",
  margin: 10mm,
  gap: 3mm,
  rows: auto,
  columns: auto,
  copies: auto,
  cut-mode: "single",
  bleed: 0pt,
  safe: 0pt,
  marks: true,
  mark-style: _default-mark-style,
  proof: false,
  slug: none,
  duplex: false,
  back-source: none,
  back-page: 1,
  back-fit: auto,
  back-alt: none,
  back-rotation: 180deg,
  flip: "long-edge",
) = {
  if duplex and back-source == none {
    panic("sheetwise: `gangup-pdf` needs `back-source` when `duplex: true`.")
  }

  let front = image(source, page: page, width: 100%, height: 100%, fit: fit, alt: alt)
  let back = if back-source == none {
    none
  } else {
    let resolved-fit = if back-fit == auto { fit } else { back-fit }
    image(back-source, page: back-page, width: 100%, height: 100%, fit: resolved-fit, alt: back-alt)
  }

  gangup(
    paper: paper,
    orientation: orientation,
    item-size: item-size,
    item-orientation: item-orientation,
    margin: margin,
    gap: gap,
    rows: rows,
    columns: columns,
    copies: copies,
    cut-mode: cut-mode,
    bleed: bleed,
    safe: safe,
    marks: marks,
    mark-style: mark-style,
    proof: proof,
    slug: slug,
    duplex: duplex,
    back: back,
    back-rotation: back-rotation,
    flip: flip,
  )[
    #front
  ]
}

#let _total-copies(items) = {
  let total = 0
  for item in items {
    total += _get(item, "copies", 1)
  }
  total
}

#let _item-at(index, items) = {
  let pos = index
  for item in items {
    let copies = _get(item, "copies", 1)
    if pos < copies {
      return item
    }
    pos -= copies
  }
  none
}

#let mixed-gangup(
  paper: "a4",
  orientation: "portrait",
  item-size: auto,
  item-orientation: "original",
  margin: 10mm,
  gap: 3mm,
  rows: auto,
  columns: auto,
  cut-mode: "single",
  bleed: 0pt,
  safe: 0pt,
  marks: true,
  mark-style: _default-mark-style,
  proof: false,
  order: "forward",
  slug: none,
  duplex: false,
  back-rotation: 180deg,
  flip: "long-edge",
  items: auto,
) = {
  if items == auto {
    panic("sheetwise: `items` is required.")
  }

  let sheet = paper-size(paper, orientation: orientation)
  let margin = _pair(margin, "margin")
  let gap = _pair(gap, "gap")
  let bleed = _non-negative(bleed, "bleed")
  let safe = _non-negative(safe, "safe")
  let plan = _grid-plan(sheet, item-size, margin, gap, rows, columns, item-orientation: item-orientation)
  _validate-cut-mode(cut-mode, plan, bleed)
  let sheet-marks = _normalize-marks(marks)
  let crop-mode = _crop-mode(sheet-marks, plan, cut-mode)
  let total = _total-copies(items)
  let sheet-count = calc.ceil(total / plan.slots)

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  for sheet-index in range(sheet-count) {
    if sheet-index > 0 {
      pagebreak()
    }

    _sheet(
      sheet,
      slug: slug,
      marks: sheet-marks,
      meta: (sheet-number: sheet-index + 1, sheet-count: sheet-count, side: "front", plan: plan, bleed: bleed, cut-mode: cut-mode),
    )[
      #for slot in range(plan.slots) {
        let index = sheet-index * plan.slots + slot
        let source-index = if order == "reverse" { total - 1 - index } else { index }
        let item = _item-at(source-index, items)

        if item != none {
          let pos = _slot-position(plan, slot)
          let label = _get(item, "label", str(source-index + 1))
          _draw-slot(
            pos,
            plan,
            item.body,
            bleed: bleed,
            safe: safe,
            marks: sheet-marks,
            proof: proof,
            mark-style: mark-style,
            label: label,
            crop-mode: crop-mode,
          )
        }
      }
      #if sheet-marks.crop and crop-mode == "grid" {
        _grid-crop-marks(plan, bleed, mark-style)
      }
    ]

    if duplex {
      pagebreak()
      _sheet(
        sheet,
        slug: slug,
        marks: sheet-marks,
        meta: (sheet-number: sheet-index + 1, sheet-count: sheet-count, side: "back", plan: plan, bleed: bleed, cut-mode: cut-mode),
      )[
        #for slot in range(plan.slots) {
          let index = sheet-index * plan.slots + slot
          let source-index = if order == "reverse" { total - 1 - index } else { index }
          let item = _item-at(source-index, items)

          if item != none and _has-key(item, "back") {
            let back-slot = _duplex-slot(plan, slot, flip)
            let pos = _slot-position(plan, back-slot)
            let label = _get(item, "label", str(source-index + 1))
            _draw-slot(
              pos,
              plan,
              _rotated(item.back, back-rotation),
              bleed: bleed,
              safe: safe,
              marks: sheet-marks,
              proof: proof,
              mark-style: mark-style,
              label: label + " back",
              crop-mode: crop-mode,
            )
          }
        }
        #if sheet-marks.crop and crop-mode == "grid" {
          _grid-crop-marks(plan, bleed, mark-style)
        }
      ]
    }
  }
}

#let _flow-from-name(flow) = {
  if flow == "cut-stack" or flow == "deep-right-down" {
    ("deep", "right", "down")
  } else if flow == "n-up" or flow == "right-down-deep" {
    ("right", "down", "deep")
  } else if flow == "down-right-deep" {
    ("down", "right", "deep")
  } else if flow == "deep-down-right" {
    ("deep", "down", "right")
  } else {
    panic("sheetwise: unknown `flow`.")
  }
}

#let _validate-stack-flow(stack-flow) = {
  if type(stack-flow) != array or stack-flow.len() != 3 {
    panic("sheetwise: `stack-flow` must be an array like `(\"deep\", \"right\", \"down\")`.")
  }

  for key in ("deep", "right", "down") {
    if not stack-flow.contains(key) {
      panic("sheetwise: `stack-flow` must contain `deep`, `right`, and `down` exactly once.")
    }
  }

  stack-flow
}

#let _record-index(sheet-index, slot, sheet-count, plan, flow, stack-flow) = {
  let col = calc.rem(slot, plan.columns)
  let row = calc.floor(slot / plan.columns)
  let stack-flow = if stack-flow == auto {
    _flow-from-name(flow)
  } else {
    stack-flow
  }
  let stack-flow = _validate-stack-flow(stack-flow)

  let record = 0
  let stride = 1
  for key in stack-flow {
    let coordinate = if key == "deep" {
      sheet-index
    } else if key == "right" {
      col
    } else {
      row
    }

    record += coordinate * stride

    stride *= if key == "deep" {
      sheet-count
    } else if key == "right" {
      plan.columns
    } else {
      plan.rows
    }
  }

  record
}

#let cut-stack(
  paper: "a4",
  orientation: "portrait",
  item-size: auto,
  item-orientation: "original",
  margin: 10mm,
  gap: 3mm,
  rows: auto,
  columns: auto,
  count: auto,
  flow: "cut-stack",
  stack-flow: auto,
  order: "forward",
  stack-size: auto,
  cut-mode: "single",
  bleed: 0pt,
  safe: 0pt,
  marks: true,
  mark-style: _default-mark-style,
  proof: false,
  slug: none,
  item: auto,
) = {
  if count == auto {
    panic("sheetwise: `count` is required.")
  }

  if item == auto {
    panic("sheetwise: `item` is required.")
  }

  let sheet = paper-size(paper, orientation: orientation)
  let margin = _pair(margin, "margin")
  let gap = _pair(gap, "gap")
  let bleed = _non-negative(bleed, "bleed")
  let safe = _non-negative(safe, "safe")
  let plan = _grid-plan(sheet, item-size, margin, gap, rows, columns, item-orientation: item-orientation)
  _validate-cut-mode(cut-mode, plan, bleed)
  let sheet-marks = _normalize-marks(marks)
  let crop-mode = _crop-mode(sheet-marks, plan, cut-mode)
  let sheet-count = if stack-size == auto {
    calc.ceil(count / plan.slots)
  } else {
    if stack-size < 1 {
      panic("sheetwise: `stack-size` must be at least 1.")
    }
    stack-size
  }

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  for sheet-index in range(sheet-count) {
    if sheet-index > 0 {
      pagebreak()
    }

    _sheet(
      sheet,
      slug: slug,
      marks: sheet-marks,
      meta: (sheet-number: sheet-index + 1, sheet-count: sheet-count, side: flow, plan: plan, bleed: bleed, cut-mode: cut-mode),
    )[
      #for slot in range(plan.slots) {
        let record = _record-index(sheet-index, slot, sheet-count, plan, flow, stack-flow)
        let record = if order == "reverse" { count - 1 - record } else { record }

        if record >= 0 and record < count {
          let pos = _slot-position(plan, slot)
          _draw-slot(
            pos,
            plan,
            item(record + 1),
            bleed: bleed,
            safe: safe,
            marks: sheet-marks,
            proof: proof,
            mark-style: mark-style,
            label: str(record + 1),
            crop-mode: crop-mode,
          )
        }
      }
      #if sheet-marks.crop and crop-mode == "grid" {
        _grid-crop-marks(plan, bleed, mark-style)
      }
    ]
  }
}

#let _saddle-pair(page-count, sheet-index, side) = {
  if calc.rem(page-count, 4) != 0 {
    panic("sheetwise: saddle-stitch page count must be a multiple of 4.")
  }

  if side == "front" {
    (left: page-count - 2 * sheet-index, right: 1 + 2 * sheet-index)
  } else if side == "back" {
    (left: 2 + 2 * sheet-index, right: page-count - 1 - 2 * sheet-index)
  } else {
    panic("sheetwise: booklet side must be `front` or `back`.")
  }
}

#let _padded-page-count(page-count, blank-policy) = {
  let remainder = calc.rem(page-count, 4)
  if remainder == 0 {
    page-count
  } else if blank-policy == "end" {
    page-count + (4 - remainder)
  } else if blank-policy == "error" {
    panic("sheetwise: saddle-stitch page count must be a multiple of 4.")
  } else {
    panic("sheetwise: `blank-policy` must be `error` or `end`.")
  }
}

#let _mirror-booklet(binding, reading-direction) = {
  if binding != "left" and binding != "right" {
    panic("sheetwise: `binding` must be `left` or `right`.")
  }
  if reading-direction != "ltr" and reading-direction != "rtl" {
    panic("sheetwise: `reading-direction` must be `ltr` or `rtl`.")
  }
  binding == "right" or reading-direction == "rtl"
}

#let _creep-amount(creep, sheet-index, sheets) = {
  if sheets <= 1 {
    return 0pt
  }

  let max-creep = if type(creep) == dictionary {
    if _has-key(creep, "paper-thickness") {
      creep.at("paper-thickness") * (sheets - 1)
    } else {
      _get(creep, "amount", 0pt)
    }
  } else {
    creep
  }

  max-creep * sheet-index / (sheets - 1)
}

#let _blank-page(width, height) = {
  box(width: width, height: height)[]
}

#let _pdf-page(source, number, width, height, dx: 0pt, source-page-count: auto) = {
  if source-page-count != auto and number > source-page-count {
    return _blank-page(width, height)
  }

  box(width: width, height: height)[
    #move(dx: dx)[#image(source, page: number, width: width, height: height, fit: "stretch")]
  ]
}

#let saddle-stitch-plan(page-count, blank-policy: "error", binding: "left", reading-direction: "ltr") = {
  let padded-count = _padded-page-count(page-count, blank-policy)
  let mirror = _mirror-booklet(binding, reading-direction)

  let sheets = calc.floor(padded-count / 4)
  let result = ()
  for i in range(sheets) {
    let front = _saddle-pair(padded-count, i, "front")
    let back = _saddle-pair(padded-count, i, "back")
    if mirror {
      front = (left: front.right, right: front.left)
      back = (left: back.right, right: back.left)
    }
    result.push((
      sheet: i + 1,
      front: front,
      back: back,
    ))
  }
  result
}

#let saddle-stitch-report(page-count, blank-policy: "error", binding: "left", reading-direction: "ltr") = {
  let plan = saddle-stitch-plan(
    page-count,
    blank-policy: blank-policy,
    binding: binding,
    reading-direction: reading-direction,
  )

  block[
    #text(weight: "bold")[Saddle-stitch imposition plan]
    #v(4pt)
    #for entry in plan {
      [Sheet #entry.sheet front: #entry.front.left | #entry.front.right]
      linebreak()
      [Sheet #entry.sheet back: #entry.back.left | #entry.back.right]
      linebreak()
    }
  ]
}

#let _calibration-face(title, subtitle, sheet, color) = {
  block(width: sheet.width, height: sheet.height)[
    #place(top + left, dx: 12mm, dy: 12mm)[
      #rect(width: sheet.width - 24mm, height: sheet.height - 24mm, stroke: 1pt + color)[
        #align(center + horizon)[
          #text(size: 28pt, weight: "bold", fill: color)[#title]
          #v(5mm)
          #text(size: 12pt)[#subtitle]
          #v(10mm)
          #text(size: 9pt)[Top edge must stay readable after duplex printing.]
        ]
      ]
    ]
    #place(top + center, dy: 5mm)[#text(size: 10pt, weight: "bold")[TOP]]
    #place(bottom + center, dy: -5mm)[#text(size: 10pt, weight: "bold")[BOTTOM]]
    #place(left + horizon, dx: 5mm)[#rotate(-90deg)[#text(size: 10pt, weight: "bold")[LEFT]]]
    #place(right + horizon, dx: -5mm)[#rotate(90deg)[#text(size: 10pt, weight: "bold")[RIGHT]]]
  ]
}

#let duplex-calibration(
  paper: "a4",
  orientation: "portrait",
  flip: "long-edge",
  back-rotation: 180deg,
  marks: (registration: true, color-bar: true),
  slug: (job: "Duplex calibration", sheet: true),
) = {
  if flip != "long-edge" and flip != "short-edge" and flip != "none" {
    panic("sheetwise: `flip` must be `long-edge`, `short-edge`, or `none`.")
  }

  let sheet = paper-size(paper, orientation: orientation)
  let sheet-marks = _normalize-marks(marks)

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  _sheet(
    sheet,
    slug: slug,
    marks: sheet-marks,
    meta: (sheet-number: 1, sheet-count: 2, side: "front"),
  )[
    #_calibration-face("FRONT", "Print this side first. Flip mode: " + flip, sheet, rgb("#105ea8"))
  ]
  pagebreak()
  _sheet(
    sheet,
    slug: slug,
    marks: sheet-marks,
    meta: (sheet-number: 2, sheet-count: 2, side: "back"),
  )[
    #_rotated(
      _calibration-face("BACK", "If this is upside down, change flip or back-rotation.", sheet, rgb("#a83a10")),
      back-rotation,
    )
  ]
}

#let saddle-stitch-pdf(
  source,
  page-count: auto,
  paper: "a4",
  orientation: "landscape",
  trim-size: auto,
  margin: 10mm,
  gap: 0pt,
  bleed: 0pt,
  safe: 0pt,
  creep: 0pt,
  blank-policy: "error",
  binding: "left",
  reading-direction: "ltr",
  order: "forward",
  marks: true,
  mark-style: _default-mark-style,
  proof: false,
  slug: none,
) = {
  if page-count == auto {
    panic("sheetwise: `page-count` is required.")
  }

  let padded-count = _padded-page-count(page-count, blank-policy)
  let mirror = _mirror-booklet(binding, reading-direction)
  let sheet = paper-size(paper, orientation: orientation)
  let trim = _size(trim-size, "trim-size")
  let margin = _pair(margin, "margin")
  let plan = _grid-plan(sheet, trim, margin, (gap, 0pt), 1, 2)
  let sheets = calc.floor(padded-count / 4)
  let sides = ("front", "back")
  let sheet-marks = _normalize-marks(marks)
  let crop-mode = _crop-mode(sheet-marks, plan, "booklet")

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  for output-index in range(sheets * 2) {
    if output-index > 0 {
      pagebreak()
    }

    let sheet-index-raw = calc.floor(output-index / 2)
    let sheet-index = if order == "reverse" { sheets - 1 - sheet-index-raw } else { sheet-index-raw }
    let side = sides.at(calc.rem(output-index, 2))
    let pair = _saddle-pair(padded-count, sheet-index, side)
    if mirror {
      pair = (left: pair.right, right: pair.left)
    }
    let creep-offset = _creep-amount(creep, sheet-index, sheets)

    _sheet(
      sheet,
      slug: slug,
      marks: sheet-marks,
      fold-x: sheet.width / 2,
      meta: (sheet-number: sheet-index + 1, sheet-count: sheets, side: side, plan: plan, bleed: bleed, cut-mode: "booklet"),
    )[
      #let left-pos = _slot-position(plan, 0)
      #let right-pos = _slot-position(plan, 1)
      #_draw-slot(
        left-pos,
        plan,
        _pdf-page(source, pair.left, trim.width, trim.height, dx: creep-offset, source-page-count: page-count),
        bleed: bleed,
        safe: safe,
        marks: sheet-marks,
        proof: proof,
        mark-style: mark-style,
        label: str(pair.left),
        crop-mode: crop-mode,
      )
      #_draw-slot(
        right-pos,
        plan,
        _pdf-page(source, pair.right, trim.width, trim.height, dx: -creep-offset, source-page-count: page-count),
        bleed: bleed,
        safe: safe,
        marks: sheet-marks,
        proof: proof,
        mark-style: mark-style,
        label: str(pair.right),
        crop-mode: crop-mode,
      )
      #if sheet-marks.crop and crop-mode == "grid" {
        _grid-crop-marks(plan, bleed, mark-style)
      }
    ]
  }
}
