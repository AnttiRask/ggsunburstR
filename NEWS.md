# ggsunburstR 0.2.0

## New input formats

* Accept `ape::phylo` objects directly — no Newick conversion needed
  (`sunburst_data(phylo_obj)`).
* Path-delimited strings — `sunburst_data(c("A/B/C", "A/B/D"))` with
  configurable separator via `sep`.
* Path-column data.frames — `sunburst_data(data.frame(path = ...))` with
  extra columns carried as node attributes.
* `data.tree::Node` objects — R6-based trees with custom scalar fields
  preserved as attributes.

## New functions

* `highlight_nodes()` adds a highlight layer to sunburst/icicle plots for
  specific nodes by name or ID.
* `nw_print()` prints tree structure from Newick input for inspection.

## Bug fixes

* Fixed `rbind` column mismatch when nodes have varying extra columns
  from different input sources.

## Testing

* Added 81 new tests (423 total), including comprehensive ragged tree
  edge-case coverage.

# ggsunburstR 0.1.0

Initial release.

## Features

* `sunburst_data()` parses hierarchical data from 4 input formats: Newick
  strings/files, data.frames with parent-child columns, lineage files,
  and node-parent CSV/TSV files.
* `sunburst()` creates polar sunburst plots with `coord_polar()`.
* `icicle()` creates rectangular icicle plots with `scale_y_reverse()`.
* Value-weighted sectors via the `values` parameter.
* Label support with pre-computed positions and flip logic for readability.
* Tree transforms: `ladderize` and `ultrametric` options.
* S3 class `sunburst_data` with `print()`, `plot()`, `as.data.frame()`,
  and `$data` alias.
* Standard ggplot2 objects — customise with `+`.
* 342 tests, R CMD check clean.
