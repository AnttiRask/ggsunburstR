## Why

The existing `sunburst()` / `icicle()` API requires a two-step workflow: `sunburst_data()` then `sunburst()`. Power users expect idiomatic ggplot2 syntax: `ggplot(df) + geom_sunburst(aes(id = child, parent = parent))`. A custom `StatSunburst` ggproto enables this.

## What Changes

- New `StatSunburst` ggproto that converts a parent-child data.frame into rect coordinates inside `compute_panel()`
- New `geom_sunburst()` layer function wrapping `StatSunburst` + `GeomRect`
- Users add `coord_polar()` for sunburst or leave Cartesian for icicle
- `values`, `branchvalues`, `leaf_mode` available as stat parameters

## Capabilities

### New Capabilities
- `geom-sunburst`: Custom ggproto stat/geom for idiomatic ggplot2 sunburst syntax

### Modified Capabilities

## Impact

- `R/stat-sunburst.R`: New file with `StatSunburst` ggproto
- `R/geom-sunburst.R`: New file with `geom_sunburst()` wrapper
- `tests/testthat/test-geom-sunburst.R`: Comprehensive tests
- `man/geom_sunburst.Rd`: New man page
- `_pkgdown.yml`: Add to reference
