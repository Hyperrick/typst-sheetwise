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

#let _mark-black = cmyk(0%, 0%, 0%, 100%)
#let _paper-white = cmyk(0%, 0%, 0%, 0%)

#let _default-mark-style = (
  color: _mark-black,
  length: 5mm,
  offset: auto,
  bleed-offset: 0pt,
  no-bleed-offset: 2mm,
  thickness: 0.25pt,
  knockout: true,
  knockout-color: _paper-white,
  knockout-padding: 0.7pt,
)

#let _proof-color = cmyk(85%, 45%, 0%, 0%)
#let _bleed-color = cmyk(0%, 70%, 90%, 0%)
#let _safe-color = cmyk(70%, 0%, 70%, 0%)
#let _label-color = cmyk(0%, 0%, 0%, 70%)
#let _registration-color = cmyk(100%, 100%, 100%, 100%)

#let _default-marks = (
  crop: true,
  crop-mode: "auto",
  bleed: false,
  safe: false,
  registration: false,
  color-bar: false,
  fold: false,
)

#let _disabled-marks = (
  crop: false,
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

#let _integer(value, name) = {
  if type(value) != int {
    panic("sheetwise: `" + name + "` must be an integer.")
  }
  value
}

#let _non-negative-int(value, name) = {
  let value = _integer(value, name)
  if value < 0 {
    panic("sheetwise: `" + name + "` must not be negative.")
  }
  value
}

#let _positive-int(value, name) = {
  let value = _integer(value, name)
  if value < 1 {
    panic("sheetwise: `" + name + "` must be at least 1.")
  }
  value
}

#let _grid-count(value, name) = {
  if value == auto {
    auto
  } else {
    _positive-int(value, name)
  }
}

#let _one-of(value, allowed, message) = {
  if allowed.contains(value) {
    value
  } else {
    panic(message)
  }
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

#let _normalize-marks(marks) = {
  if marks == true {
    _default-marks
  } else if marks == false or marks == none {
    _disabled-marks
  } else if type(marks) == dictionary {
    _merge(_default-marks, marks)
  } else {
    panic("sheetwise: `marks` must be a boolean, `none`, or a dictionary.")
  }
}

#let _normalize-mark-style(mark-style) = {
  if type(mark-style) == dictionary {
    _merge(_default-mark-style, mark-style)
  } else {
    panic("sheetwise: `mark-style` must be a dictionary.")
  }
}

#let _bleed-only-double-gap(plan, bleed) = {
  if bleed <= 0pt {
    return false
  }

  let tight-horizontal-gap = plan.columns > 1 and plan.gap.width <= bleed * 2
  let tight-vertical-gap = plan.rows > 1 and plan.gap.height <= bleed * 2
  tight-horizontal-gap or tight-vertical-gap
}

#let _crop-mode(marks, plan, cut-mode, bleed) = {
  let mode = _get(marks, "crop-mode", _default-marks.at("crop-mode"))
  if mode == "auto" {
    if cut-mode == "single" and plan.gap.width == 0pt and plan.gap.height == 0pt {
      "grid"
    } else if cut-mode == "double" and _bleed-only-double-gap(plan, bleed) {
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

#let _validate-order(order) = {
  _one-of(order, ("forward", "reverse"), "sheetwise: `order` must be `forward` or `reverse`.")
}

#let _order-index(order, index, total) = {
  if order == "reverse" { total - 1 - index } else { index }
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
  let item-orientation = _one-of(
    item-orientation,
    ("auto", "original", "portrait", "landscape"),
    "sheetwise: `item-orientation` must be `auto`, `original`, `portrait`, or `landscape`.",
  )

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

  let orientation = _one-of(orientation, ("portrait", "landscape"), "sheetwise: `orientation` must be `portrait` or `landscape`.")

  if orientation == "portrait" {
    size
  } else {
    (width: size.height, height: size.width)
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
  let rows = _grid-count(rows, "rows")
  let columns = _grid-count(columns, "columns")
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

#let _validate-flip(flip) = {
  _one-of(flip, ("long-edge", "short-edge", "none"), "sheetwise: `flip` must be `long-edge`, `short-edge`, or `none`.")
}

#let _validate-duplex-back(duplex, back, back-name, function-name) = {
  if duplex and back == none {
    panic("sheetwise: `" + function-name + "` needs `" + back-name + "` when `duplex: true`.")
  }
  if not duplex and back != none {
    panic("sheetwise: `" + back-name + "` requires `duplex: true`.")
  }
}

#let _duplex-slot(plan, slot, flip) = {
  let col = calc.rem(slot, plan.columns)
  let row = calc.floor(slot / plan.columns)

  if flip == "long-edge" {
    _slot-from-row-column(plan, row, plan.columns - 1 - col)
  } else if flip == "short-edge" {
    _slot-from-row-column(plan, plan.rows - 1 - row, col)
  } else if flip == "none" {
    slot
  }
}

#let _validate-cut-mode(cut-mode, plan, bleed) = {
  let cut-mode = _one-of(cut-mode, ("single", "double"), "sheetwise: `cut-mode` must be `single` or `double`.")
  if cut-mode == "single" {
    return
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

#let _validate-safe(plan, safe) = {
  if safe > 0pt and (safe * 2 >= plan.item.width or safe * 2 >= plan.item.height) {
    panic("sheetwise: `safe` must be smaller than half the item size.")
  }
  safe
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
  let explicit = style.offset
  if explicit != auto {
    return _non-negative(explicit, "mark-style.offset")
  }

  if bleed > 0pt {
    bleed + _non-negative(style.at("bleed-offset"), "mark-style.bleed-offset")
  } else {
    _non-negative(style.at("no-bleed-offset"), "mark-style.no-bleed-offset")
  }
}

#let _crop-mark-params(bleed, style) = (
  length: _positive(style.length, "mark-style.length"),
  color: style.color,
  thickness: _positive(style.thickness, "mark-style.thickness"),
  offset: _crop-mark-offset(bleed, style),
)

#let _mark-backing(style) = {
  if style.knockout {
    (
      padding: _non-negative(style.at("knockout-padding"), "mark-style.knockout-padding"),
      color: style.at("knockout-color"),
    )
  } else {
    none
  }
}

#let _backed-hline(x, y, width, color, thickness, style) = {
  let backing = _mark-backing(style)
  if backing != none {
    _hline(x - backing.padding, y - backing.padding, width + backing.padding * 2, backing.color, thickness + backing.padding * 2)
  }
  _hline(x, y, width, color, thickness)
}

#let _backed-vline(x, y, height, color, thickness, style) = {
  let backing = _mark-backing(style)
  if backing != none {
    _vline(x - backing.padding, y - backing.padding, height + backing.padding * 2, backing.color, thickness + backing.padding * 2)
  }
  _vline(x, y, height, color, thickness)
}

#let _crop-marks(x, y, width, height, bleed, style) = {
  let mark = _crop-mark-params(bleed, style)

  _backed-hline(x - mark.offset - mark.length, y, mark.length, mark.color, mark.thickness, style)
  _backed-hline(x + width + mark.offset, y, mark.length, mark.color, mark.thickness, style)
  _backed-hline(x - mark.offset - mark.length, y + height, mark.length, mark.color, mark.thickness, style)
  _backed-hline(x + width + mark.offset, y + height, mark.length, mark.color, mark.thickness, style)

  _backed-vline(x, y - mark.offset - mark.length, mark.length, mark.color, mark.thickness, style)
  _backed-vline(x + width, y - mark.offset - mark.length, mark.length, mark.color, mark.thickness, style)
  _backed-vline(x, y + height + mark.offset, mark.length, mark.color, mark.thickness, style)
  _backed-vline(x + width, y + height + mark.offset, mark.length, mark.color, mark.thickness, style)
}

#let _push-unique(values, value) = {
  if not values.contains(value) {
    values.push(value)
  }
  values
}

#let _grid-crop-marks(plan, bleed, style, slots: auto) = {
  let mark = _crop-mark-params(bleed, style)
  let slots = if slots == auto { range(plan.slots) } else { slots }
  if slots.len() == 0 {
    return
  }

  let x-lines = ()
  let y-lines = ()
  let grid-left = none
  let grid-top = none
  let grid-right = none
  let grid-bottom = none

  for slot in slots {
    if slot >= 0 and slot < plan.slots {
      let pos = _slot-position(plan, slot)
      let right = pos.x + plan.item.width
      let bottom = pos.y + plan.item.height

      x-lines = _push-unique(x-lines, pos.x)
      x-lines = _push-unique(x-lines, right)
      y-lines = _push-unique(y-lines, pos.y)
      y-lines = _push-unique(y-lines, bottom)

      if grid-left == none or pos.x < grid-left {
        grid-left = pos.x
      }
      if grid-top == none or pos.y < grid-top {
        grid-top = pos.y
      }
      if grid-right == none or right > grid-right {
        grid-right = right
      }
      if grid-bottom == none or bottom > grid-bottom {
        grid-bottom = bottom
      }
    }
  }

  if grid-left == none {
    return
  }

  for x in x-lines {
    _backed-vline(x, grid-top - mark.offset - mark.length, mark.length, mark.color, mark.thickness, style)
    _backed-vline(x, grid-bottom + mark.offset, mark.length, mark.color, mark.thickness, style)
  }

  for y in y-lines {
    _backed-hline(grid-left - mark.offset - mark.length, y, mark.length, mark.color, mark.thickness, style)
    _backed-hline(grid-right + mark.offset, y, mark.length, mark.color, mark.thickness, style)
  }
}

#let _occupied-slots-from-count(plan, count) = {
  let slots = ()
  for slot in range(plan.slots) {
    if slot < count {
      slots.push(slot)
    }
  }
  slots
}

#let _draw-grid-crop-marks(plan, bleed, mark-style, sheet-marks, crop-mode, slots) = {
  if sheet-marks.crop and crop-mode == "grid" {
    _grid-crop-marks(plan, bleed, mark-style, slots: slots)
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
    _paper-white,
    cmyk(0%, 0%, 0%, 50%),
  )

  for i in range(colors.len()) {
    place(top + left, dx: x + i * width, dy: y)[
      #rect(width: width, height: height, fill: colors.at(i), stroke: 0.2pt + _mark-black)
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
  marks: _default-marks,
  proof: false,
  mark-style: _default-mark-style,
  label: none,
  crop-mode: "per-item",
) = {
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

#let _draw-plan-slot(
  plan,
  slot,
  body,
  bleed: 0pt,
  safe: 0pt,
  marks: _default-marks,
  proof: false,
  mark-style: _default-mark-style,
  label: none,
  crop-mode: "per-item",
) = {
  _draw-slot(
    _slot-position(plan, slot),
    plan,
    body,
    bleed: bleed,
    safe: safe,
    marks: marks,
    proof: proof,
    mark-style: mark-style,
    label: label,
    crop-mode: crop-mode,
  )
}

#let _sheet(sheet, body, slug: none, meta: (:), marks: _disabled-marks, fold-x: auto, fold-y: auto) = {
  block(width: sheet.width, height: sheet.height)[
    #body
    #_sheet-marks(sheet, marks, fold-x: fold-x, fold-y: fold-y)
    #_slug(sheet, _normalize-slug(slug, meta: meta))
  ]
}

#let _sheet-meta(sheet-number, sheet-count, side, plan: none, bleed: none, cut-mode: none) = {
  let meta = (sheet-number: sheet-number, sheet-count: sheet-count, side: side)
  if plan != none {
    meta.insert("plan", plan)
  }
  if bleed != none {
    meta.insert("bleed", bleed)
  }
  if cut-mode != none {
    meta.insert("cut-mode", cut-mode)
  }
  meta
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
  let margin = _pair(margin, "margin")
  let gap = _pair(gap, "gap")
  _grid-plan(sheet, item-size, margin, gap, rows, columns, item-orientation: item-orientation)
}

#let _draw-context(sheet, plan, bleed, safe, marks, mark-style, crop-mode) = (
  sheet: sheet,
  plan: plan,
  bleed: bleed,
  safe: safe,
  marks: marks,
  mark-style: mark-style,
  crop-mode: crop-mode,
)

#let _imposition-context(
  paper,
  orientation,
  item-size,
  item-orientation,
  margin,
  gap,
  rows,
  columns,
  cut-mode,
  bleed,
  safe,
  marks,
  mark-style,
) = {
  let sheet = paper-size(paper, orientation: orientation)
  let margin = _pair(margin, "margin")
  let gap = _pair(gap, "gap")
  let bleed = _non-negative(bleed, "bleed")
  let safe = _non-negative(safe, "safe")
  let plan = _grid-plan(sheet, item-size, margin, gap, rows, columns, item-orientation: item-orientation)
  _validate-cut-mode(cut-mode, plan, bleed)
  let safe = _validate-safe(plan, safe)
  let marks = _normalize-marks(marks)
  let mark-style = _normalize-mark-style(mark-style)
  _draw-context(sheet, plan, bleed, safe, marks, mark-style, _crop-mode(marks, plan, cut-mode, bleed))
}

#let _draw-imposed-slot(
  ctx,
  slot,
  body,
  proof: false,
  label: none,
) = {
  _draw-plan-slot(
    ctx.plan,
    slot,
    body,
    bleed: ctx.bleed,
    safe: ctx.safe,
    marks: ctx.marks,
    proof: proof,
    mark-style: ctx.mark-style,
    label: label,
    crop-mode: ctx.crop-mode,
  )
}

#let _draw-imposed-grid-marks(ctx, occupied-slots) = {
  _draw-grid-crop-marks(ctx.plan, ctx.bleed, ctx.mark-style, ctx.marks, ctx.crop-mode, occupied-slots)
}

#let _imposed-sheet(
  ctx,
  body,
  slug: none,
  meta: (:),
  fold-x: auto,
  fold-y: auto,
) = {
  _sheet(
    ctx.sheet,
    body,
    slug: slug,
    meta: meta,
    marks: ctx.marks,
    fold-x: fold-x,
    fold-y: fold-y,
  )
}

#let _copy-count(copies, plan) = {
  let copies = if copies == auto {
    plan.slots
  } else {
    _non-negative-int(copies, "copies")
  }

  if copies > plan.slots {
    panic("sheetwise: `copies` cannot exceed the selected grid slots.")
  }
  copies
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
  _validate-duplex-back(duplex, back, "back", "gangup")

  let ctx = _imposition-context(
    paper,
    orientation,
    item-size,
    item-orientation,
    margin,
    gap,
    rows,
    columns,
    cut-mode,
    bleed,
    safe,
    marks,
    mark-style,
  )
  let sheet = ctx.sheet
  let plan = ctx.plan
  let copies = _copy-count(copies, plan)
  let flip = if duplex { _validate-flip(flip) } else { flip }

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  _imposed-sheet(
    ctx,
    slug: slug,
    meta: _sheet-meta(1, if duplex { 2 } else { 1 }, "front", plan: plan, bleed: ctx.bleed, cut-mode: cut-mode),
  )[
    #let occupied-slots = _occupied-slots-from-count(plan, copies)
    #for slot in range(plan.slots) {
      if slot < copies {
        _draw-imposed-slot(
          ctx,
          slot,
          body,
          proof: proof,
          label: str(slot + 1),
        )
      }
    }
    #_draw-imposed-grid-marks(ctx, occupied-slots)
  ]

  if duplex {
    pagebreak()
    _imposed-sheet(
      ctx,
      slug: slug,
      meta: _sheet-meta(2, 2, "back", plan: plan, bleed: ctx.bleed, cut-mode: cut-mode),
    )[
      #let occupied-slots = ()
      #for slot in range(plan.slots) {
        if slot < copies {
          let back-slot = _duplex-slot(plan, slot, flip)
          occupied-slots.push(back-slot)
          _draw-imposed-slot(
            ctx,
            back-slot,
            _rotated(back, back-rotation),
            proof: proof,
            label: str(slot + 1) + " back",
          )
        }
      }
      #_draw-imposed-grid-marks(ctx, occupied-slots)
    ]
  }
}

#let _pdf-image(source, page, width, height, fit: "stretch", alt: none, name: "page") = {
  let page = _positive-int(page, name)
  image(source, page: page, width: width, height: height, fit: fit, alt: alt)
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
  _validate-duplex-back(duplex, back-source, "back-source", "gangup-pdf")
  let page = _positive-int(page, "page")
  let back-page = if duplex {
    _positive-int(back-page, "back-page")
  } else {
    back-page
  }

  let front = _pdf-image(source, page, 100%, 100%, fit: fit, alt: alt)
  let back = if duplex {
    let resolved-fit = if back-fit == auto { fit } else { back-fit }
    _pdf-image(back-source, back-page, 100%, 100%, fit: resolved-fit, alt: back-alt, name: "back-page")
  } else {
    none
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

#let _expanded-items(items) = {
  if type(items) != array {
    panic("sheetwise: `items` must be an array of dictionaries.")
  }

  let records = ()
  for item in items {
    if type(item) != dictionary {
      panic("sheetwise: every `items` entry must be a dictionary.")
    }
    if not _has-key(item, "body") {
      panic("sheetwise: every `items` entry must include `body`.")
    }
    let copies = _non-negative-int(_get(item, "copies", 1), "items.copies")
    for copy in range(copies) {
      records.push(item)
    }
  }

  if records.len() == 0 {
    panic("sheetwise: `items` must include at least one copy.")
  }
  records
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

  let ctx = _imposition-context(
    paper,
    orientation,
    item-size,
    item-orientation,
    margin,
    gap,
    rows,
    columns,
    cut-mode,
    bleed,
    safe,
    marks,
    mark-style,
  )
  let sheet = ctx.sheet
  let plan = ctx.plan
  let order = _validate-order(order)
  let flip = if duplex { _validate-flip(flip) } else { flip }
  let records = _expanded-items(items)
  let total = records.len()
  let sheet-count = calc.ceil(total / plan.slots)

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  for sheet-index in range(sheet-count) {
    if sheet-index > 0 {
      pagebreak()
    }

    _imposed-sheet(
      ctx,
      slug: slug,
      meta: _sheet-meta(sheet-index + 1, sheet-count, "front", plan: plan, bleed: ctx.bleed, cut-mode: cut-mode),
    )[
      #let occupied-slots = ()
      #for slot in range(plan.slots) {
        let index = sheet-index * plan.slots + slot
        let source-index = _order-index(order, index, total)
        let item = if source-index >= 0 and source-index < total { records.at(source-index) } else { none }

        if item != none {
          occupied-slots.push(slot)
          let label = _get(item, "label", str(source-index + 1))
          _draw-imposed-slot(
            ctx,
            slot,
            item.body,
            proof: proof,
            label: label,
          )
        }
      }
      #_draw-imposed-grid-marks(ctx, occupied-slots)
    ]

    if duplex {
      pagebreak()
      _imposed-sheet(
        ctx,
        slug: slug,
        meta: _sheet-meta(sheet-index + 1, sheet-count, "back", plan: plan, bleed: ctx.bleed, cut-mode: cut-mode),
      )[
        #let occupied-slots = ()
        #for slot in range(plan.slots) {
          let index = sheet-index * plan.slots + slot
          let source-index = _order-index(order, index, total)
          let item = if source-index >= 0 and source-index < total { records.at(source-index) } else { none }

          if item != none and _has-key(item, "back") {
            let back-slot = _duplex-slot(plan, slot, flip)
            occupied-slots.push(back-slot)
            let label = _get(item, "label", str(source-index + 1))
            _draw-imposed-slot(
              ctx,
              back-slot,
              _rotated(item.back, back-rotation),
              proof: proof,
              label: label + " back",
            )
          }
        }
        #_draw-imposed-grid-marks(ctx, occupied-slots)
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

#let _resolve-stack-flow(flow, stack-flow) = {
  let stack-flow = if stack-flow == auto {
    _flow-from-name(flow)
  } else {
    stack-flow
  }
  _validate-stack-flow(stack-flow)
}

#let _record-index(sheet-index, slot, sheet-count, plan, stack-flow) = {
  let col = calc.rem(slot, plan.columns)
  let row = calc.floor(slot / plan.columns)

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
  let count = _positive-int(count, "count")

  let ctx = _imposition-context(
    paper,
    orientation,
    item-size,
    item-orientation,
    margin,
    gap,
    rows,
    columns,
    cut-mode,
    bleed,
    safe,
    marks,
    mark-style,
  )
  let sheet = ctx.sheet
  let plan = ctx.plan
  let order = _validate-order(order)
  let resolved-stack-flow = _resolve-stack-flow(flow, stack-flow)
  let minimum-sheet-count = calc.ceil(count / plan.slots)
  let sheet-count = if stack-size == auto {
    minimum-sheet-count
  } else {
    let stack-size = _positive-int(stack-size, "stack-size")
    if stack-size < minimum-sheet-count {
      panic("sheetwise: `stack-size` is too small for `count` and the selected grid.")
    }
    stack-size
  }

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  for sheet-index in range(sheet-count) {
    if sheet-index > 0 {
      pagebreak()
    }

    _imposed-sheet(
      ctx,
      slug: slug,
      meta: _sheet-meta(sheet-index + 1, sheet-count, flow, plan: plan, bleed: ctx.bleed, cut-mode: cut-mode),
    )[
      #let occupied-slots = ()
      #for slot in range(plan.slots) {
        let record = _record-index(sheet-index, slot, sheet-count, plan, resolved-stack-flow)
        let record = _order-index(order, record, count)

        if record >= 0 and record < count {
          occupied-slots.push(slot)
          _draw-imposed-slot(
            ctx,
            slot,
            item(record + 1),
            proof: proof,
            label: str(record + 1),
          )
        }
      }
      #_draw-imposed-grid-marks(ctx, occupied-slots)
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
  let page-count = _positive-int(page-count, "page-count")
  let blank-policy = _one-of(blank-policy, ("error", "end"), "sheetwise: `blank-policy` must be `error` or `end`.")
  let remainder = calc.rem(page-count, 4)
  if remainder == 0 {
    page-count
  } else if blank-policy == "end" {
    page-count + (4 - remainder)
  } else {
    panic("sheetwise: saddle-stitch page count must be a multiple of 4.")
  }
}

#let _mirror-booklet(binding, reading-direction) = {
  let binding = _one-of(binding, ("left", "right"), "sheetwise: `binding` must be `left` or `right`.")
  let reading-direction = _one-of(reading-direction, ("ltr", "rtl"), "sheetwise: `reading-direction` must be `ltr` or `rtl`.")
  binding == "right" or reading-direction == "rtl"
}

#let _creep-max(creep, sheets) = {
  let value = if type(creep) == dictionary {
    if _has-key(creep, "paper-thickness") {
      creep.at("paper-thickness") * (sheets - 1)
    } else {
      _get(creep, "amount", 0pt)
    }
  } else {
    creep
  }

  _non-negative(value, "creep")
}

#let _creep-amount(max-creep, sheet-index, sheets) = {
  if sheets <= 1 {
    return 0pt
  }

  max-creep * sheet-index / (sheets - 1)
}

#let _blank-page(width, height) = {
  box(width: width, height: height)[]
}

#let _pdf-page(source, number, width, height, dx: 0pt, source-page-count: auto, fit: "stretch", alt: none) = {
  let number = _positive-int(number, "page")
  if source-page-count != auto and number > source-page-count {
    return _blank-page(width, height)
  }

  box(width: width, height: height)[
    #move(dx: dx)[#_pdf-image(source, number, width, height, fit: fit, alt: alt)]
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
  let flip = _validate-flip(flip)
  let sheet = paper-size(paper, orientation: orientation)
  let sheet-marks = _normalize-marks(marks)

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  _sheet(
    sheet,
    slug: slug,
    marks: sheet-marks,
    meta: _sheet-meta(1, 2, "front"),
  )[
    #_calibration-face("FRONT", "Print this side first. Flip mode: " + flip, sheet, rgb("#105ea8"))
  ]
  pagebreak()
  _sheet(
    sheet,
    slug: slug,
    marks: sheet-marks,
    meta: _sheet-meta(2, 2, "back"),
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
  fit: "stretch",
  alt: none,
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
  if trim-size == auto {
    panic("sheetwise: `trim-size` is required.")
  }

  let padded-count = _padded-page-count(page-count, blank-policy)
  let mirror = _mirror-booklet(binding, reading-direction)
  let sheet = paper-size(paper, orientation: orientation)
  let trim = _size(trim-size, "trim-size")
  let margin = _pair(margin, "margin")
  let plan = _grid-plan(sheet, trim, margin, (gap, 0pt), 1, 2)
  let bleed = _non-negative(bleed, "bleed")
  let safe = _validate-safe(plan, _non-negative(safe, "safe"))
  let sheets = calc.floor(padded-count / 4)
  let sides = ("front", "back")
  let sheet-marks = _normalize-marks(marks)
  let mark-style = _normalize-mark-style(mark-style)
  let crop-mode = _crop-mode(sheet-marks, plan, "booklet", bleed)
  let ctx = _draw-context(sheet, plan, bleed, safe, sheet-marks, mark-style, crop-mode)
  let order = _validate-order(order)
  let max-creep = _creep-max(creep, sheets)

  set page(width: sheet.width, height: sheet.height, margin: 0pt)
  for output-index in range(sheets * 2) {
    if output-index > 0 {
      pagebreak()
    }

    let sheet-index-raw = calc.floor(output-index / 2)
    let sheet-index = _order-index(order, sheet-index-raw, sheets)
    let side = sides.at(calc.rem(output-index, 2))
    let pair = _saddle-pair(padded-count, sheet-index, side)
    if mirror {
      pair = (left: pair.right, right: pair.left)
    }
    let creep-offset = _creep-amount(max-creep, sheet-index, sheets)

    _imposed-sheet(
      ctx,
      slug: slug,
      fold-x: sheet.width / 2,
      meta: _sheet-meta(sheet-index + 1, sheets, side, plan: plan, bleed: ctx.bleed, cut-mode: "booklet"),
    )[
      #_draw-imposed-slot(
        ctx,
        0,
        _pdf-page(source, pair.left, trim.width, trim.height, dx: creep-offset, source-page-count: page-count, fit: fit, alt: alt),
        proof: proof,
        label: str(pair.left),
      )
      #_draw-imposed-slot(
        ctx,
        1,
        _pdf-page(source, pair.right, trim.width, trim.height, dx: -creep-offset, source-page-count: page-count, fit: fit, alt: alt),
        proof: proof,
        label: str(pair.right),
      )
      #_draw-imposed-grid-marks(ctx, (0, 1))
    ]
  }
}
