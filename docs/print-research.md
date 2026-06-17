# Print Workflow Research Notes

This file records the print-production concepts that shaped Sheetwise.

## Terms

- **Finished piece / print item**: one final trimmed item placed on a larger
  press sheet.
- **Press sheet**: the larger printed sheet that is later cut, folded, or bound.
- **Trim size**: the final size after cutting.
- **Trim line / cut line**: the line where the sheet is cut to the final size.
- **Gutter / gap**: space or a removable strip between adjacent items. Sheetwise
  models this as `gap`.
- **Bleed**: extra artwork beyond the final trim.
- **Safety margin / safe area**: inner area where important content should stay.
- **Crop marks / trim marks**: printer marks showing where the final trim lands.
- **Registration marks**: printer marks used to align color separations.
- **Color bars**: printer marks used for color/control checking.
- **Slug**: job or production information printed outside the trim area.
- **Cut-and-stack**: records are placed so printed sheets can be stacked, cut,
  and restacked without manual sorting.
- **N-up**: multiple pages or items placed on one sheet.
- **Gang-up**: grouping repeated or different print items onto a larger sheet.
- **Saddle-stitch**: folded sheets nested and stitched on the spine.
- **Creep / shingling**: inner booklet pages protrude farther after nesting and
  need progressive content shift toward the spine.

## Feature Plan

Implemented in `0.1.0`:

- Auto-fit rows and columns.
- Manual rows and columns.
- Portrait/landscape sheet orientation.
- Built-in common sheet sizes, including A-series, SRA3, Letter, Legal, and
  Tabloid.
- Gutter/gap between adjacent print items.
- Repeating one design across a sheet.
- Mixed versions with copy counts.
- Forward and reverse filling for mixed versions.
- Cut-and-stack sequencing and ordinary n-up sequencing.
- Explicit `cut-mode: "single" | "double"` semantics. Single-cut layouts share a
  trim line between adjacent items; double-cut layouts use a removable gutter
  between items.
- Crop marks, bleed proof box, trim proof box, safe-area proof box,
  registration marks, color bars, and fold marks.
- Structured slug/job-info text on the sheet.
- Basic duplex back-side sheet generation and a calibration sheet.
- Saddle-stitch PDF imposition with page pairing, blank padding,
  right-binding/RTL mirroring, and optional creep offset.
- Saddle-stitch report output for checking printer spreads before rendering.

Planned after `0.1.0`:

- More flow modes: `down-right-deep`, `right-down-deep`,
  `deep-down-right`, and custom page-flow arrays.
- Work-and-turn / work-and-tumble sheet handling.
- Dutch-cut / mixed orientation optimization.
- Barcode/slug metadata.
- Separate trim-box, bleed-box, media-box metadata when Typst exposes PDF page
  boxes to package code.
- PDF/X and ICC-profile checks if Typst exposes export/preflight hooks.

## Researched API Requirements

- `sheet-size` and `sheet-orientation` must be separate from `item-size` and
  item rotation. This matches real press-sheet planning: stock size is a press
  and finishing decision, not just the finished product format.
- `rows`/`columns` should be explicit but can default to auto-fit. Printers
  sometimes request a fixed grid even when more items would fit.
- `gap` should be measured between trim boxes. This makes it usable for both
  shared-trim and removable-gutter workflows.
- `cut-stack` needs a page-flow concept. Professional tools describe this with
  dimensions such as `deep`, `right`, and `down`: deep means the next record is
  placed on the next sheet in the stack.
- Mixed versions need copy counts per version. This supports workflows like
  several business-card names or sticker variants on one sheet.
- Saddle-stitch inputs should remain in reader order. Imposition should happen
  as an export/second-pass step, pairing pages like `8 | 1`, `2 | 7`, `6 | 3`,
  `4 | 5` for an eight-page booklet.
- Saddle-stitch page counts should be multiples of four or padded with blanks.
- Creep should stay explicit because printers calculate it differently. A
  practical first model is progressive sheet shift from outside to inside.
- Duplex/back-side handling needs calibration output because printer drivers
  differ in long-edge/short-edge flip behavior.
- PDF/X, output ICC profiles, automatic image-resolution checks, and PDF page
  box rewriting are outside pure Typst package scope today.

## Sources

- [Typst image docs](https://typst.app/docs/reference/visualize/image/): PDF
  files can be placed as images, and `page` selects the embedded PDF page.
- [Typst PDF docs](https://typst.app/docs/reference/pdf/): Typst supports
  PDF/A and PDF/UA export standards, but not PDF/X export as a package-level
  option.
- [Typst `page` docs](https://typst.app/docs/reference/layout/page/): Typst has
  native page setup and PDF page-box concepts such as bleed/trim behavior.
- [Fiery Gangup printing](https://help.fiery.com/jobmaster/4.8/en-us/GUID-53E09BB6-C925-424D-BDDE-F001D4E074B8.html):
  gang-up repeat, gang-up unique, and unique-collate cut are standard modes.
- [Fiery VDP gang-up methods](https://help.fiery.com/jobmaster/4.8/en-us/GUID-3390F348-B04B-493F-BA02-658E55BE8CE8.html):
  cut-and-stack keeps records sequential after stacking and cutting.
- [Imposition Wizard cut-stack](https://pressnostress.com/impositionwizard/tutorials/imposition/cut-stack/):
  cut-stack uses flow dimensions such as Deep, Down, and Right and includes
  grid, gap, duplex, bleed, and marks concepts.
- [University of Cincinnati printing glossary](https://www.uc.edu/about/printing-services/resources/glossary.html):
  imposition is the positioning of pages so they appear in sequence after
  printing, folding, and cutting.
- [Fiery cut-and-stack imposition](https://help.fiery.com/jobmaster/4.8/en-us/GUID-3390F348-B04B-493F-BA02-658E55BE8CE8.html):
  cut-and-stack keeps records sequential after stacking, cutting, and restacking.
- [Fiery imposition templates](https://help.fiery.com/jobmaster/4.7/en-us/GUID-4EA54B5C-3E7F-4139-A267-71B4E52F99D4.html):
  saddle-stitch layouts use duplex, bleeds, printer's marks, and blank-page
  padding when needed.
- [Prepressure imposition overview](https://www.prepressure.com/prepress/imposition):
  imposition planning covers press-sheet layout, folding/binding order, and
  creep/shingling compensation.
- [SAIC Saddle Stitch Books](https://sites.saic.edu/servicebureau/home/services/saddle-stitch-books/):
  saddle-stitch page counts must be multiples of four; full-bleed booklets need
  bleed, crop marks, and imposition.
- [Adobe InDesign printer marks, bleeds, and slug](https://helpx.adobe.com/indesign/desktop/print/page-set-up-and-printer-marks/set-printer-marks.html):
  printer marks, bleed, and slug are separate print setup concepts.
- [Disc Makers bleed and safety margins](https://support.discmakers.com/hc/en-us/articles/360033809554-What-Are-Bleed-And-Safety-Margins):
  safety margin is the inner area where important content stays away from crop
  marks and trim variance.
- [Adobe booklet imposition](https://helpx.adobe.com/indesign/desktop/print/print-booklets/impose-documents-for-booklet-printing.html):
  normal reader-order documents are imposed into printer spreads at output time.
- [Sheetwise-relevant Typst package markly](https://typst.app/universe/package/markly/):
  existing package for cut, bleed, and registration marks.
- [Sheetwise-relevant Typst package bookletic](https://typst.app/universe/package/bookletic/):
  existing package proving a pure-Typst booklet approach, but limited to a
  hardcoded two-page single-fold signature.
