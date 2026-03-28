## Why

Users composing sunburst/donut plots typically want centred titles, legend at bottom, and no axis clutter. Currently they must manually add `theme_void() + theme(...)` each time. A purpose-built theme provides a one-liner.

## What Changes

- New exported function `theme_sunburst(base_size, base_family)` returning a ggplot2 theme
- Based on `theme_void()` with centred bold title, bottom legend, tidy margins

## Capabilities

### New Capabilities
- `theme-sunburst`: Default theme function for sunburst and donut plots

### Modified Capabilities

## Impact

- `R/theme.R`: New file
- `tests/testthat/test-theme.R`: New test file
- `man/theme_sunburst.Rd`: New man page
- `_pkgdown.yml`: Add to reference
