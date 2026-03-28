## Why

Sunburst labels currently only support radial orientation (text reads outward from centre). Users need arc-following (perpendicular) labels, internal node labels, and automatic filtering of labels on narrow sectors to produce readable plots. The pre-computed `pangle`/`pvjust` values already exist in `sunburst_data` — this change exposes them through the plot API.

## What Changes

- Add `label_type = "perpendicular"` rendering to `sunburst()` using existing `pangle`/`pvjust` columns
- Add `show_node_labels` parameter to `sunburst()` and `icicle()` for internal node labels
- Add `label_size` parameter to `sunburst()` and `icicle()` for controlling text size
- Add `min_label_angle` parameter to `sunburst()` and `icicle()` for filtering labels on narrow sectors
- Include `ymin`/`ymax` in leaf_labels output so perpendicular labels can be positioned at the radial midpoint
- Include `delta_angle` in leaf_labels for min_label_angle filtering
- Mirror all applicable label enhancements to `icicle()`

## Capabilities

### New Capabilities
- `label-rotation`: Arc-following label orientation, internal node labels, label size control, and minimum-angle label filtering for sunburst and icicle plots

### Modified Capabilities

## Impact

- `R/plot-sunburst.R`: New parameters and label rendering logic
- `R/plot-icicle.R`: New parameters and node label support
- `R/sunburst-data.R`: Add `ymin`, `ymax`, `delta_angle` columns to leaf_labels output
- `R/compute-labels.R`: Compute `delta_angle` for leaf nodes
- `tests/testthat/test-plot-sunburst.R`: New tests for all label features
- `tests/testthat/test-plot-icicle.R`: New tests for node labels, label_size, min_label_angle
- No new dependencies
