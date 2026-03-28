## 1. Tests

- [x] 1.1 Write test: sunburst fill = depth (bare name) maps fill
- [x] 1.2 Write test: bare name produces identical result to string
- [x] 1.3 Write test: icicle fill = name (bare name)
- [x] 1.4 Write test: donut fill = depth (bare name)
- [x] 1.5 Write test: string fill still works (backward compat)
- [x] 1.6 Write test: "auto" and "none" still work

## 2. Implementation

- [x] 2.1 Create .resolve_fill() helper in utils.R
- [x] 2.2 Update sunburst() to use enquo + .resolve_fill()
- [x] 2.3 Update icicle() to use enquo + .resolve_fill()
- [x] 2.4 Update donut() to use enquo + .resolve_fill()

## 3. Documentation and checks

- [x] 3.1 Update roxygen2 docs for fill parameter
- [x] 3.2 Run devtools::document()
- [x] 3.3 Run devtools::test() — all pass
- [x] 3.4 Run devtools::check() — 0 errors, 0 warnings
