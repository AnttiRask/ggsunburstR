# Package index

## Data preparation

Parse hierarchical data and compute coordinates

- [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md)
  : Parse hierarchical input into sunburst/icicle data
- [`drilldown()`](https://anttirask.github.io/ggsunburstR/reference/drilldown.md)
  : Drill down into a subtree

## Plot functions

Create sunburst, icicle, donut, and tree plots

- [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  : Create a polar sunburst plot
- [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  : Create a rectangular icicle plot
- [`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md)
  : Create a donut (ring) chart
- [`ggtree()`](https://anttirask.github.io/ggsunburstR/reference/ggtree.md)
  : Create a tree-style dendrogram plot

## Multi-scale fill

Per-depth fill colour scales

- [`sunburst_multifill()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_multifill.md)
  : Create a sunburst plot with per-depth fill scales
- [`icicle_multifill()`](https://anttirask.github.io/ggsunburstR/reference/icicle_multifill.md)
  : Create an icicle plot with per-depth fill scales

## Annotation layers

Add annotations to existing plots

- [`highlight_nodes()`](https://anttirask.github.io/ggsunburstR/reference/highlight_nodes.md)
  : Highlight specific nodes in a sunburst or icicle plot
- [`bars()`](https://anttirask.github.io/ggsunburstR/reference/bars.md)
  : Add bar chart annotations to a sunburst or icicle plot
- [`tile()`](https://anttirask.github.io/ggsunburstR/reference/tile.md)
  : Add tile (heatmap) annotations to a sunburst or icicle plot

## Utilities

Tree inspection

- [`nw_print()`](https://anttirask.github.io/ggsunburstR/reference/nw_print.md)
  : Print tree structure from Newick input

## S3 methods

Methods for sunburst_data objects

- [`` `$`( ``*`<sunburst_data>`*`)`](https://anttirask.github.io/ggsunburstR/reference/cash-.sunburst_data.md)
  : Access sunburst_data components
- [`print(`*`<sunburst_data>`*`)`](https://anttirask.github.io/ggsunburstR/reference/print.sunburst_data.md)
  : Print a sunburst_data object
- [`as.data.frame(`*`<sunburst_data>`*`)`](https://anttirask.github.io/ggsunburstR/reference/as.data.frame.sunburst_data.md)
  : Convert sunburst_data to data.frame
- [`plot(`*`<sunburst_data>`*`)`](https://anttirask.github.io/ggsunburstR/reference/plot.sunburst_data.md)
  : Plot a sunburst_data object
