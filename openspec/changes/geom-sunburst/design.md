## Context

ggplot2 stats receive a data.frame and return a transformed data.frame. `StatSunburst` must reconstruct the tree hierarchy from parent-child columns, compute coordinates, and return a data.frame with `xmin`, `xmax`, `ymin`, `ymax` that `GeomRect` can render.

## Goals / Non-Goals

**Goals:**
- `StatSunburst` ggproto with `compute_panel()` (not `compute_group()` — tree needs all rows)
- `geom_sunburst()` convenience wrapper
- `required_aes = c("id", "parent")` for the parent-child relationship
- `values`, `branchvalues`, `leaf_mode` as stat params
- Extra columns from input data.frame preserved (for fill mapping etc.)

**Non-Goals:**
- Labels inside the geom (users compose with `geom_text()`)
- Automatic `coord_polar()` (users add it explicitly)
- Newick input (data.frame only for ggplot2 API)

## Decisions

### D1: compute_panel not compute_group
The tree must be built from all rows in the data. `compute_group()` receives subset data, which would break the hierarchy. `compute_panel()` gets the full panel data.

### D2: Reuse existing internal functions
`parse_dataframe()`, `assign_sizes()`, `compute_coordinates()` already work correctly. `StatSunburst` calls them in sequence and converts the output to a flat data.frame for `GeomRect`.

### D3: Preserve extra columns
Extra columns (beyond `id` and `parent`) are joined back to the output rects data.frame, enabling `aes(fill = some_column)`.

### D4: Root excluded from output
Consistent with `sunburst_data()` — the root node is not rendered.

### D5: Use GeomRect, not a custom Geom
`GeomRect` handles `xmin/xmax/ymin/ymax` perfectly. No need for a custom Geom class — a Stat is sufficient.
