## 1. Package dependency

- [x] 1.1 Add `ggnewscale` to Suggests in DESCRIPTION

## 2. Core implementation

- [x] 2.1 Write test: sunburst_multifill returns ggplot with coord_polar
- [x] 2.2 Write test: sunburst_multifill creates fill-mapped layer for specified depth
- [x] 2.3 Write test: unspecified depths get static grey layer
- [x] 2.4 Write test: multiple depths produce separate fill-mapped layers
- [x] 2.5 Implement sunburst_multifill()
- [x] 2.6 Write test: icicle_multifill returns ggplot with scale_y_reverse
- [x] 2.7 Implement icicle_multifill()

## 3. Input validation

- [x] 3.1 Write test: fills must be a named list
- [x] 3.2 Write test: fills depth must exist in data
- [x] 3.3 Write test: fill column must exist in rects
- [x] 3.4 Write test: sb must be sunburst_data
- [x] 3.5 Implement input validation

## 4. Documentation and checks

- [x] 4.1 Write roxygen2 docs with @examples
- [x] 4.2 Run devtools::document()
- [x] 4.3 Run devtools::test() — all pass
- [x] 4.4 Run devtools::check() — 0 errors, 0 warnings
