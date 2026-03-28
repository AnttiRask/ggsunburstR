## 1. Tests

- [x] 1.1 Write test: basic plot builds without error
- [x] 1.2 Write test: correct number of rectangles (root excluded)
- [x] 1.3 Write test: fill mapping produces varying colours
- [x] 1.4 Write test: value-weighted sizing via values param
- [x] 1.5 Write test: coord_polar produces sunburst
- [x] 1.6 Write test: without coord_polar is icicle (Cartesian)
- [x] 1.7 Write test: missing required aesthetic errors
- [x] 1.8 Write test: extra columns preserved for fill

## 2. Implementation

- [x] 2.1 Create R/stat-sunburst.R with StatSunburst ggproto
- [x] 2.2 Implement compute_panel: parse_dataframe → assign_sizes → compute_coordinates → flatten
- [x] 2.3 Create R/geom-sunburst.R with geom_sunburst() wrapper
- [x] 2.4 Support values, branchvalues, leaf_mode as stat params

## 3. Documentation and checks

- [x] 3.1 Write roxygen2 docs for geom_sunburst() with @examples
- [x] 3.2 Update _pkgdown.yml
- [x] 3.3 Run devtools::document()
- [x] 3.4 Run devtools::test() — all pass
- [x] 3.5 Run devtools::check() — 0 errors, 0 warnings
