## Why

The default static grey fill (`fill = NULL`) shows structure but no information. Mapping fill to `depth` makes the default output more informative. Per SPEC.md, this is a non-breaking change for v0.5: `fill = "auto"` is a new option, `fill = NULL` continues to produce grey.

## What Changes

- Add `fill = "auto"` option to `sunburst()`, `icicle()`, and `donut()` — maps fill to the `depth` column
- Add `fill = "none"` as explicit static grey (equivalent to current `fill = NULL`)
- `fill = NULL` (default) continues to produce static grey — breaking change deferred to v0.6+
- Document the deprecation plan

## Capabilities

### New Capabilities
- `fill-auto-depth`: Auto-map fill to depth via `fill = "auto"` in all plot functions

### Modified Capabilities

## Impact

- `R/plot-sunburst.R`: Add `"auto"` and `"none"` handling to fill logic
- `R/plot-icicle.R`: Same
- `R/plot-donut.R`: Same
- `tests/testthat/test-plot-sunburst.R`: New tests
- `tests/testthat/test-plot-icicle.R`: New tests
- `tests/testthat/test-plot-donut.R`: New tests
