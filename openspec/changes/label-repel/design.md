## Context

Change 20 added `min_label_angle` filtering as the primary anti-clutter mechanism. For icicle plots (Cartesian), `ggrepel` can provide additional collision avoidance. For sunburst plots (polar), `ggrepel` computes repulsion in Cartesian space before `coord_polar()` transforms it, producing poor results — so it's deferred.

## Goals / Non-Goals

**Goals:**
- Icicle-only `label_repel = TRUE` using `ggrepel::geom_text_repel()`
- Runtime check for `ggrepel` availability
- Informative error when used with `sunburst()`
- Works with all existing label features (show_node_labels, label_size, min_label_angle)

**Non-Goals:**
- Polar repulsion for sunburst (deferred to v0.5+)
- Leader line customisation
- Per-layer repel toggling

## Decisions

### D1: ggrepel as Suggests, not Imports
`ggrepel` is only needed when `label_repel = TRUE`. Using Suggests keeps the dependency optional. Use `rlang::check_installed("ggrepel")` for a user-friendly prompt.

### D2: Sunburst label_repel errors instead of silently ignoring
Users should know the limitation. An informative error with guidance toward `min_label_angle` is better than silent no-op.

### D3: geom_text_repel parameters
Use sensible defaults: `max.overlaps = Inf` to show all eligible labels, `size` from `label_size`, and `seed = 42` for reproducible placement.

## Risks / Trade-offs

- [ggrepel may produce suboptimal placement for very dense icicles] → Combine with `min_label_angle` pre-filtering to reduce label count before repulsion
- [Testing ggrepel visually is hard] → Use structural tests (correct layer class) + vdiffr snapshots
