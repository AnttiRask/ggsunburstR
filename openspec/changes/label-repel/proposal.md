## Why

Dense icicle plots produce overlapping labels. `ggrepel::geom_text_repel()` provides collision avoidance in Cartesian space — perfect for icicle plots. Sunburst plots use polar coordinates where `ggrepel` produces poor results, so repulsion is icicle-only for v0.4; sunbursts rely on `min_label_angle` filtering from Change 20.

## What Changes

- Add `ggrepel` to Suggests in DESCRIPTION
- Add `label_repel = FALSE` parameter to `icicle()`
- When `label_repel = TRUE`, use `ggrepel::geom_text_repel()` instead of `ggplot2::geom_text()`
- Check `ggrepel` availability at runtime with `rlang::check_installed()`
- Add `label_repel` parameter to `sunburst()` that produces an informative error explaining icicle-only support in v0.4

## Capabilities

### New Capabilities
- `label-repel`: ggrepel-based collision avoidance for icicle label layers

### Modified Capabilities

## Impact

- `DESCRIPTION`: Add `ggrepel` to Suggests
- `R/plot-icicle.R`: New `label_repel` parameter, conditional `geom_text_repel()` use
- `R/plot-sunburst.R`: New `label_repel` parameter with informative error
- `tests/testthat/test-plot-icicle.R`: Tests for repel behaviour
- `tests/testthat/test-plot-sunburst.R`: Test for sunburst repel error
