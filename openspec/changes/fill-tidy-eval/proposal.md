## Why

Users expect ggplot2-like syntax: `sunburst(sb, fill = depth)` with bare names, not just `fill = "depth"`. Both should work for backward compatibility.

## What Changes

- Modify `sunburst()`, `icicle()`, and `donut()` to resolve `fill` via `rlang::enquo()` — accepting bare names, strings, NULL, "auto", and "none"
- Extract a shared `.resolve_fill()` helper for consistent resolution across all plot functions
- Maintain full backward compatibility: `fill = "depth"` still works

## Capabilities

### New Capabilities
- `fill-tidy-eval`: Bare column name support for fill parameter

### Modified Capabilities

## Impact

- `R/plot-sunburst.R`, `R/plot-icicle.R`, `R/plot-donut.R`: enquo-based fill resolution
- `R/utils.R`: `.resolve_fill()` helper
- Tests: bare name tests added alongside existing string tests
