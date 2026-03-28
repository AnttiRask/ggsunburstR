## Context

`sunburst()` and `icicle()` currently support `show_labels = TRUE` with radial orientation only. The `sunburst_data` object already computes `pangle`/`pvjust` for perpendicular labels and `node_labels` for internal nodes — these are just not wired through the plot API. The `leaf_labels` data.frame is missing `ymin`/`ymax`/`delta_angle` columns needed for midpoint positioning and angular filtering.

## Goals / Non-Goals

**Goals:**
- Expose perpendicular (arc-following) label orientation via `label_type = "perpendicular"`
- Add internal node label rendering via `show_node_labels`
- Add `label_size` control (currently hardcoded to `3`)
- Add `min_label_angle` filtering to suppress labels on narrow sectors
- Propagate `ymin`, `ymax`, `delta_angle` into the leaf_labels data.frame

**Non-Goals:**
- `ggrepel` integration (Change 21: `label-repel`)
- Custom font or colour per label
- Label placement outside the arc (leader lines)

## Decisions

### D1: Perpendicular label Y position

For `label_type = "perpendicular"` in sunburst, labels are positioned at the radial midpoint `(ymin + ymax) / 2` instead of the outer edge `ymax`. This centres text within the arc band. Requires adding `ymin`/`ymax` to `leaf_labels` output.

**Alternative:** Keep `y = ymax` — rejected because perpendicular text centred at the outer edge looks offset.

### D2: delta_angle for leaf nodes

Currently `delta_angle` is only computed for internal nodes. For `min_label_angle` filtering to work on leaves, we need `delta_angle` for leaves too. This is `size * (xlim / total_size)` — the angular span of a single leaf.

### D3: Icicle label_type

`icicle()` does not use `coord_polar()` so `label_type` has no visible effect — labels are horizontal. Rather than adding a non-functional parameter, `icicle()` will get `show_node_labels`, `label_size`, and `min_label_angle` but not `label_type`.

### D4: Node labels share label_size

Both leaf and node labels use the same `label_size` parameter. Per-layer sizing can be done by users via the returned ggplot object.

## Risks / Trade-offs

- [Perpendicular labels can overlap on dense trees] → `min_label_angle` filtering mitigates this; full repulsion deferred to Change 21
- [Adding columns to leaf_labels is a minor breaking change for code inspecting the data.frame] → Additive only (new columns), no existing columns change, low risk
