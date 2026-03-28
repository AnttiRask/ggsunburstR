## Context

`sunburst()` and `icicle()` support a single `fill` column mapping. For multi-level colour encoding, users need `ggnewscale::new_scale_fill()` between depth layers. This is awkward to do manually — we provide helper functions.

## Goals / Non-Goals

**Goals:**
- `sunburst_multifill(sb, fills)` and `icicle_multifill(sb, fills)` exported functions
- `fills` is a named list mapping depth (as character) to fill column name
- Depths not in `fills` rendered with static grey
- Runtime check for `ggnewscale`
- User can add their own `scale_fill_*()` after each depth layer

**Non-Goals:**
- Per-depth scale specification (users add scales themselves)
- Label integration (compose with `sunburst()` labels separately)
- Automatic colour scale selection

## Decisions

### D1: Separate functions, not parameters on sunburst()/icicle()
Multi-fill fundamentally changes the plot construction (multiple geom_rect layers instead of one). A separate function is cleaner than adding complexity to the existing plot functions.

### D2: Static grey for unspecified depths
Depths not listed in `fills` should still be visible. A grey `geom_rect` layer (no fill mapping) is added for these depths, matching the default `sunburst()` appearance.

### D3: First depth layer does not use new_scale_fill()
`new_scale_fill()` is only needed before the 2nd and subsequent fill-mapped layers. The first fill-mapped depth uses ggplot2's default fill scale slot.

## Risks / Trade-offs

- [User must add scale_fill_* themselves for each depth] → Documented in examples; keeps the function composable
- [ggnewscale is a niche package] → Suggests-only dependency with runtime check
