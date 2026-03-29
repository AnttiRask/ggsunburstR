# Changelog

## ggsunburstR 0.5.1

### Error messages

- All error messages with variable interpolation now use
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
  for proper rendering. Affected functions:
  [`drilldown()`](https://anttirask.github.io/ggsunburstR/reference/drilldown.md),
  [`bars()`](https://anttirask.github.io/ggsunburstR/reference/bars.md),
  [`tile()`](https://anttirask.github.io/ggsunburstR/reference/tile.md),
  [`sunburst_multifill()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_multifill.md),
  [`icicle_multifill()`](https://anttirask.github.io/ggsunburstR/reference/icicle_multifill.md),
  and internal validators.

### Code quality

- Extracted shared `.read_newick_safe()` helper – eliminates duplicated
  Newick parsing logic between `parse_newick()` and
  [`nw_print()`](https://anttirask.github.io/ggsunburstR/reference/nw_print.md).
- `compute_coordinates()` now guards against all-zero leaf sizes with an
  informative error instead of silent division by zero.
- [`drilldown()`](https://anttirask.github.io/ggsunburstR/reference/drilldown.md)
  `params$drilldown_from` now always stores the node name (previously
  stored mixed types depending on how node was specified).
- Fixed 1-space indent in `drilldown.R`.
- Pinned `rangle(270)` test to exact expected value.

### Documentation

- Added `@seealso` cross-references to
  [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md),
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md).
- Added `@details` to
  [`ggtree()`](https://anttirask.github.io/ggsunburstR/reference/ggtree.md)
  documenting three layout modes.
- Added bare name fill example to
  [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  roxygen2 examples.
- Added `label_repel` example to
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  roxygen2 examples.
- Added deprecation plan note for `fill = NULL` in
  [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  and
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  docs.

### Testing

- Added 21 edge-case tests: single-leaf bars/tile, empty/malformed
  paths, duplicate paths, non-scalar data.tree fields, deep tree (20
  levels), xlim \< 360 labels, tibble input, duplicate tip labels,
  all-zero values, print output content, fill=“auto” equivalence,
  invalid fill expression.
- 625 tests total, R CMD check 0/0/0.

## ggsunburstR 0.5.0

### ggplot2 geom

- [`geom_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/geom_sunburst.md)
  provides idiomatic ggplot2 syntax:
  `ggplot(df) + geom_sunburst(aes(id = child, parent = parent))`. Uses a
  custom `StatSunburst` ggproto to convert parent-child data.frames into
  sunburst coordinates. Add `coord_polar()` for sunburst layout or leave
  Cartesian for icicle. Supports `values`, `branchvalues`, and
  `leaf_mode` parameters.

### New theme

- [`theme_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/theme_sunburst.md)
  provides a tailored theme for sunburst and donut charts: centred bold
  title, bottom legend, tidy margins. Based on `theme_void()`.

### Fill improvements

- `fill = "auto"` maps fill to the `depth` column in
  [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md),
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md),
  and
  [`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md).
- `fill = "none"` explicitly produces static grey (escape hatch for when
  the default eventually changes to `"auto"` in a future version).
- Bare name support: `sunburst(sb, fill = depth)` now works alongside
  the existing `fill = "depth"` string syntax.

### Testing

- Added 36 new tests (605 total).
- R CMD check: 0 errors, 0 warnings, 0 notes.

## ggsunburstR 0.4.0

### Label enhancements

- [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  gains `label_type = "perpendicular"` for arc-following labels that use
  pre-computed `pangle`/`pvjust` values and position text at the radial
  midpoint.
- [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  and
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  gain `show_node_labels` for internal node labels, `label_size` for
  controlling text size, and `min_label_angle` for filtering labels on
  narrow sectors.
- [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  gains `label_repel = TRUE` for `ggrepel`-based collision avoidance.
  Requires the `ggrepel` package (Suggests). Polar repulsion for
  sunbursts is deferred – use `min_label_angle` instead.

### New functions

- [`sunburst_multifill()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_multifill.md)
  and
  [`icicle_multifill()`](https://anttirask.github.io/ggsunburstR/reference/icicle_multifill.md)
  create plots with per-depth fill colour scales using
  [`ggnewscale::new_scale_fill()`](https://eliocamp.github.io/ggnewscale/reference/new_scale.html).
  Depths not listed in `fills` are rendered with static grey.

### Data improvements

- [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md)
  now includes `ymin`, `ymax`, and `delta_angle` columns in the
  `$leaf_labels` data.frame, enabling perpendicular label positioning
  and angular filtering.

### Dependencies

- Added `ggrepel` and `ggnewscale` to Suggests.

### Testing

- Added 69 new tests (569 total).
- R CMD check: 0 errors, 0 warnings, 0 notes.

## ggsunburstR 0.3.0

### New plot types

- [`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md)
  creates ring charts – sunbursts restricted to the outermost 1–N depth
  levels with configurable centre hole size.
- [`ggtree()`](https://anttirask.github.io/ggsunburstR/reference/ggtree.md)
  creates classical dendrograms using `geom_segment()`. Supports
  horizontal layout (`rotate = TRUE`), circular layout (`polar = TRUE`),
  leaf labels, and scale bars.

### New functions

- [`drilldown()`](https://anttirask.github.io/ggsunburstR/reference/drilldown.md)
  extracts a subtree and recomputes coordinates so the selected node
  fills the full angular space. Returns a new `sunburst_data` object
  compatible with all plot functions. Supports chaining.
- [`bars()`](https://anttirask.github.io/ggsunburstR/reference/bars.md)
  adds bar chart annotations adjacent to leaf nodes. Values are
  max-normalised per variable. Supports multiple variables, labels, and
  value display.
- [`tile()`](https://anttirask.github.io/ggsunburstR/reference/tile.md)
  adds heatmap-style tile annotations adjacent to leaf nodes. Works with
  both numeric and categorical variables.

### Testing

- Added 76 new tests (499 total).
- R CMD check: 0 errors, 0 warnings, 0 notes.

## ggsunburstR 0.2.0

### New input formats

- Accept [`ape::phylo`](https://rdrr.io/pkg/ape/man/read.tree.html)
  objects directly – no Newick conversion needed
  (`sunburst_data(phylo_obj)`).
- Path-delimited strings – `sunburst_data(c("A/B/C", "A/B/D"))` with
  configurable separator via `sep`.
- Path-column data.frames – `sunburst_data(data.frame(path = ...))` with
  extra columns carried as node attributes.
- [`data.tree::Node`](https://rdrr.io/pkg/data.tree/man/Node.html)
  objects – R6-based trees with custom scalar fields preserved as
  attributes.

### New functions

- [`highlight_nodes()`](https://anttirask.github.io/ggsunburstR/reference/highlight_nodes.md)
  adds a highlight layer to sunburst/icicle plots for specific nodes by
  name or ID.
- [`nw_print()`](https://anttirask.github.io/ggsunburstR/reference/nw_print.md)
  prints tree structure from Newick input for inspection.

### Bug fixes

- Fixed `rbind` column mismatch when nodes have varying extra columns
  from different input sources.

### Testing

- Added 81 new tests (423 total), including comprehensive ragged tree
  edge-case coverage.

## ggsunburstR 0.1.0

Initial release.

### Features

- [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md)
  parses hierarchical data from 4 input formats: Newick strings/files,
  data.frames with parent-child columns, lineage files, and node-parent
  CSV/TSV files.
- [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  creates polar sunburst plots with `coord_polar()`.
- [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  creates rectangular icicle plots with `scale_y_reverse()`.
- Value-weighted sectors via the `values` parameter.
- Label support with pre-computed positions and flip logic for
  readability.
- Tree transforms: `ladderize` and `ultrametric` options.
- S3 class `sunburst_data` with
  [`print()`](https://rdrr.io/r/base/print.html),
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html), and
  `$data` alias.
- Standard ggplot2 objects – customise with `+`.
- 342 tests, R CMD check clean.
