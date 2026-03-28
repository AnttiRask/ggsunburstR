## Context

`sunburst()` and `icicle()` apply `theme_void()` internally. `theme_sunburst()` is a user-facing theme for additional customisation — users add it with `+ theme_sunburst()` to override the default.

## Goals / Non-Goals

**Goals:**
- `theme_sunburst(base_size = 11, base_family = "")` returns complete theme
- Based on `theme_void()` via `%+replace%`
- Centred bold title, bottom legend, 5px margins

**Non-Goals:**
- Applying automatically inside `sunburst()` (users opt in)
- Colour palette selection

## Decisions

### D1: Use %+replace% not +
`%+replace%` fully replaces theme elements rather than merging, ensuring predictable results when users also add their own `theme()` calls.
