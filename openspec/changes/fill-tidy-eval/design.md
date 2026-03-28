## Context

The `fill` parameter currently accepts `NULL`, `"auto"`, `"none"`, or a string column name. Adding bare name support means `fill = depth` (unquoted) must also work.

## Goals / Non-Goals

**Goals:**
- `fill = depth` (bare name) resolves to `"depth"` string
- `fill = "depth"` (string) continues to work
- `fill = NULL`, `"auto"`, `"none"` continue to work
- All three plot functions + donut support tidy eval

**Non-Goals:**
- Full tidy eval expressions (`fill = paste0("d", "epth")`)
- Tidy eval for other parameters

## Decisions

### D1: .resolve_fill() returns a string or NULL
The helper uses `rlang::enquo()` to capture the fill argument, then dispatches:
- `quo_is_null()` → `NULL`
- `quo_is_symbol()` → `as_name()` (bare name to string)
- String literal → extract string
This keeps downstream code unchanged — `.validate_fill()` and `.build_rect_layer()` still receive strings.

### D2: enquo() in each plot function, not in the helper
`rlang::enquo()` must be called in the function that received the user's argument — it can't be deferred to a helper. Each plot function calls `enquo(fill)` then passes the quosure to `.resolve_fill()`.
