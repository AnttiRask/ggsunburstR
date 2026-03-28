## 1. Tests

- [x] 1.1 Write test: sunburst fill = "auto" maps to depth (varying fill values)
- [x] 1.2 Write test: sunburst fill = "none" produces uniform grey
- [x] 1.3 Write test: sunburst fill = NULL still produces grey (non-breaking)
- [x] 1.4 Write test: icicle fill = "auto" maps to depth
- [x] 1.5 Write test: icicle fill = "none" produces uniform grey
- [x] 1.6 Write test: donut fill = "auto" maps to depth
- [x] 1.7 Write test: donut fill = "none" produces uniform grey

## 2. Implementation

- [x] 2.1 Extract .build_rect_layer() helper in utils.R
- [x] 2.2 Update sunburst() fill dispatch
- [x] 2.3 Update icicle() fill dispatch
- [x] 2.4 Update donut() fill dispatch
- [x] 2.5 Update fill validation to skip "auto"/"none"

## 3. Documentation and checks

- [x] 3.1 Update roxygen2 docs for sunburst(), icicle(), donut()
- [x] 3.2 Run devtools::document()
- [x] 3.3 Run devtools::test() — all pass
- [x] 3.4 Run devtools::check() — 0 errors, 0 warnings
