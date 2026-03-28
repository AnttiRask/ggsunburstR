## Why

Users need different colour scales for different hierarchy levels — e.g., depth 1 coloured by discrete "category" and depth 2 by continuous "value". ggplot2 only supports one fill scale per plot. `ggnewscale::new_scale_fill()` enables multiple fill scales by resetting the fill aesthetic between layers.

## What Changes

- Add `ggnewscale` to Suggests in DESCRIPTION
- Create `R/multifill.R` with `sunburst_multifill()` and `icicle_multifill()`
- Each function splits `sb$rects` by depth and adds per-depth `geom_rect()` layers with `new_scale_fill()` between them
- Depths not listed in `fills` are rendered with static grey fill
- Runtime check for `ggnewscale` availability

## Capabilities

### New Capabilities
- `multi-scale-fill`: Per-depth fill colour scales via `ggnewscale`

## Impact

- `DESCRIPTION`: Add `ggnewscale` to Suggests
- `R/multifill.R`: New file with `sunburst_multifill()` and `icicle_multifill()`
- `tests/testthat/test-multifill.R`: New test file
- `man/sunburst_multifill.Rd`, `man/icicle_multifill.Rd`: New man pages
