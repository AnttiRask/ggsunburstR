# Changelog

## ggsunburstR 0.2.0

### New input formats

- Accept [`ape::phylo`](https://rdrr.io/pkg/ape/man/read.tree.html)
  objects directly — no Newick conversion needed
  (`sunburst_data(phylo_obj)`).
- Path-delimited strings — `sunburst_data(c("A/B/C", "A/B/D"))` with
  configurable separator via `sep`.
- Path-column data.frames — `sunburst_data(data.frame(path = ...))` with
  extra columns carried as node attributes.
- [`data.tree::Node`](https://rdrr.io/pkg/data.tree/man/Node.html)
  objects — R6-based trees with custom scalar fields preserved as
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
- Standard ggplot2 objects — customise with `+`.
- 342 tests, R CMD check clean.
