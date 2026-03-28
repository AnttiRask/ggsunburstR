## Context

All three plot functions (`sunburst()`, `icicle()`, `donut()`) share the same fill dispatch: `NULL` → grey, string → mapped. We add two new special values.

## Goals / Non-Goals

**Goals:**
- `fill = "auto"` maps to `depth` column
- `fill = "none"` explicitly produces static grey
- `fill = NULL` stays static grey (non-breaking)
- All three plot functions support both new values
- Extract shared fill dispatch to avoid repetition

**Non-Goals:**
- Changing the default from `NULL` to `"auto"` (deferred to v0.6+)
- Custom auto-mapping to columns other than depth

## Decisions

### D1: Extract .build_rect_layer() helper
The fill dispatch logic (`NULL` → grey, `"auto"` → depth, `"none"` → grey, string → mapped) is identical across three functions. Extract into a shared internal helper returning a geom_rect layer.

### D2: "none" as explicit grey
Users who want static grey after a future default change to "auto" need an explicit opt-out. `"none"` is intuitive and matches ggplot2 conventions.

### D3: Validate fill against "auto"/"none" before column check
The `"auto"` and `"none"` strings are reserved — they must not be checked against `names(sb$rects)`.
