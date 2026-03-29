# ggsunburstR Development Summary

## What Was Built

A pure-R package for creating sunburst, icicle, donut, and tree
adjacency diagrams using ggplot2. Reimplements the Python-dependent
`ggsunburst` package entirely in R.

## Versions

### v0.1.0 — MVP (14 changes)

The core package: parse hierarchical data, compute coordinates, render
plots.

- **Package scaffold**: DESCRIPTION, testthat 3, MIT license, CI
- **Internal tree**: list-based structure with integer-indexed node IDs,
  traversal (postorder/levelorder), distance computation, ladderize,
  ultrametric conversion, trig helpers
- **Parsers**: Newick (via
  [`ape::read.tree()`](https://rdrr.io/pkg/ape/man/read.tree.html)),
  lineage files, node-parent CSV/TSV, parent-child data.frames
- **Input detection**: cascade auto-detection (`type = "auto"`)
- **Coordinate engine**: cursor-based leaf X, branch-length Y, internal
  node spanning, `leaf_mode = "extended"`, segment data for tree plots
- **Label engine**: radial angles, flip logic for readability,
  delta_angle, xfraction
- **S3 class**: `sunburst_data` with
  [`print()`](https://rdrr.io/r/base/print.html),
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html),
  [`as.data.frame()`](https://rdrr.io/r/base/as.data.frame.html),
  `$data` alias
- **Plot functions**:
  [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  (coord_polar),
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  (scale_y_reverse)
- **Documentation**: README, getting-started vignette, pkgdown, GitHub
  Actions CI

### v0.2.0 — Input Formats & Utilities (6 changes)

Expanded input support and added utility functions.

- **[`ape::phylo`](https://rdrr.io/pkg/ape/man/read.tree.html) input**:
  direct phylo objects, no Newick conversion needed
- **Path-delimited strings**: `c("A/B/C", "A/B/D")` with configurable
  separator
- **Path-column data.frames**: `data.frame(path = ...)` with extra
  columns
- **[`data.tree::Node`](https://rdrr.io/pkg/data.tree/man/Node.html)
  input**: R6-based trees with custom scalar fields
- **[`highlight_nodes()`](https://anttirask.github.io/ggsunburstR/reference/highlight_nodes.md)**:
  add a highlight layer by node name or ID
- **[`nw_print()`](https://anttirask.github.io/ggsunburstR/reference/nw_print.md)**:
  print tree structure from Newick input

### v0.3.0 — Plot Types & Data Transforms (5 changes)

New plot types and the drilldown feature.

- **[`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md)**:
  ring chart (sunburst restricted to N outermost levels)
- **[`ggtree()`](https://anttirask.github.io/ggsunburstR/reference/ggtree.md)**:
  dendrogram with horizontal, vertical, and circular layouts plus scale
  bars
- **[`drilldown()`](https://anttirask.github.io/ggsunburstR/reference/drilldown.md)**:
  extract subtree and recompute as new root
- **[`bars()`](https://anttirask.github.io/ggsunburstR/reference/bars.md)**:
  bar chart annotation layer for leaf nodes
- **[`tile()`](https://anttirask.github.io/ggsunburstR/reference/tile.md)**:
  heatmap-style tile annotation layer

### v0.4.0 — Labels & Multi-Scale Fill (4 changes)

Label enhancements and per-depth fill scales.

- **Perpendicular labels**: arc-following `label_type = "perpendicular"`
- **Node labels**: `show_node_labels = TRUE` for internal nodes
- **Label filtering**: `min_label_angle` to hide labels on narrow
  sectors
- **Label repulsion**: `label_repel = TRUE` (icicle only, via ggrepel)
- **[`sunburst_multifill()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_multifill.md)
  /
  [`icicle_multifill()`](https://anttirask.github.io/ggsunburstR/reference/icicle_multifill.md)**:
  per-depth fill scales via ggnewscale
- **Leaf label geometry**: added `ymin`, `ymax`, `delta_angle` to
  `$leaf_labels`

### v0.5.0 — ggplot2 Integration & Polish (4 changes)

Idiomatic ggplot2 syntax and fill improvements.

- **[`geom_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/geom_sunburst.md)**:
  custom StatSunburst ggproto for
  `ggplot(df) + geom_sunburst(aes(id, parent))`
- **[`theme_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/theme_sunburst.md)**:
  tailored theme with centred title, bottom legend
- **`fill = "auto"`**: maps to depth column
- **`fill = "none"`**: explicit static grey
- **Tidy eval fill**: `sunburst(sb, fill = depth)` bare names

## By the Numbers

| Metric                  | Value                               |
|-------------------------|-------------------------------------|
| Total changes           | 33                                  |
| Total tests             | 605                                 |
| Exported functions      | 15                                  |
| Internal R files        | 20                                  |
| Test files              | 22                                  |
| Input formats supported | 8                                   |
| Plot types              | 4 (sunburst, icicle, donut, ggtree) |
| Annotation layers       | 3 (highlight_nodes, bars, tile)     |
| R CMD check             | 0 errors, 0 warnings, 0 notes       |

## Exported Functions

### Data preparation

- [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md)
  — main entry point, all input types
- [`drilldown()`](https://anttirask.github.io/ggsunburstR/reference/drilldown.md)
  — subtree extraction and recomputation

### Standalone plot constructors

- [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  — polar sunburst
- [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  — rectangular icicle
- [`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md)
  — ring chart
- [`ggtree()`](https://anttirask.github.io/ggsunburstR/reference/ggtree.md)
  — dendrogram

### ggplot2 geom

- [`geom_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/geom_sunburst.md)
  — idiomatic ggplot2 layer

### Annotation layers (added to existing plots)

- [`highlight_nodes()`](https://anttirask.github.io/ggsunburstR/reference/highlight_nodes.md)
  — emphasis layer
- [`bars()`](https://anttirask.github.io/ggsunburstR/reference/bars.md)
  — bar chart annotation
- [`tile()`](https://anttirask.github.io/ggsunburstR/reference/tile.md)
  — heatmap annotation
- [`sunburst_multifill()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_multifill.md)
  — per-depth fill (sunburst)
- [`icicle_multifill()`](https://anttirask.github.io/ggsunburstR/reference/icicle_multifill.md)
  — per-depth fill (icicle)

### Utilities

- [`nw_print()`](https://anttirask.github.io/ggsunburstR/reference/nw_print.md)
  — tree inspection
- [`theme_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/theme_sunburst.md)
  — custom theme

### S3 methods

- [`print.sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/print.sunburst_data.md),
  [`plot.sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/plot.sunburst_data.md),
  [`as.data.frame.sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/as.data.frame.sunburst_data.md),
  `$.sunburst_data`

## Architecture

    User input → detect_input_type() → parser → internal tree
               → assign_sizes() → [ladderize/ultrametric]
               → compute_coordinates() → compute_label_positions()
               → .build_output() → new_sunburst_data()
               → sunburst() / icicle() / donut() / ggtree()

The internal tree is a plain list with integer-indexed node IDs
(`nodes`, `children`, `parent`, `root`, `n_tips`). It is never exposed
to users.

## Key Design Decisions

1.  **[`ape::read.tree()`](https://rdrr.io/pkg/ape/man/read.tree.html)
    for Newick** — leverages a well-tested CRAN package rather than
    writing a custom parser
2.  **List-based tree** — simple, efficient for traversal, not exported
3.  **Pre-computed coordinates + `geom_rect()`** — debuggable,
    composable with ggplot2; custom ggproto added later in v0.5
4.  **`add_child()` copy semantics** — returns modified tree via
    `attr(, "tree")` workaround for R’s copy-on-modify
5.  **S3 class** — lightweight, standard R convention
6.  **`fill` as string then tidy eval** — started simple (string column
    name), added bare name support in v0.5

## Development Process

- **TDD throughout**: every function had failing tests before
  implementation
- **OpenSpec change management**: 33 changes with proposal, design,
  specs, and tasks
- **Code review gate**: every change reviewed before merge, with BLOCK /
  REQUEST / SUGGEST severity levels
- **Atomic commits**: test commits separate from implementation commits
- **Branch-per-change**: `change/<slug>` branches, merge to main after
  review

## What’s Next

See `SUGGESTIONS.md` for all deferred reviewer suggestions. The package
is a working proof of concept. Manual testing may reveal changes needed
to the API, coordinate computation, or feature set. The SPEC.md roadmap
has one remaining item: v1.0 CRAN submission.
