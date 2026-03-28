## 1. Package dependency

- [x] 1.1 Add `ggrepel` to Suggests in DESCRIPTION

## 2. Icicle label_repel

- [x] 2.1 Write test: icicle label_repel = TRUE uses GeomTextRepel layer class
- [x] 2.2 Write test: icicle label_repel with show_node_labels uses repel for both layers
- [x] 2.3 Write test: icicle label_repel combined with min_label_angle filtering
- [x] 2.4 Write test: icicle label_repel = FALSE (default) still uses geom_text
- [x] 2.5 Implement label_repel parameter in icicle()

## 3. Sunburst label_repel limitation

- [x] 3.1 Write test: sunburst label_repel = TRUE errors with informative message
- [x] 3.2 Write test: sunburst label_repel = FALSE (default) works normally
- [x] 3.3 Implement label_repel parameter in sunburst() with error

## 4. Documentation and checks

- [x] 4.1 Update roxygen2 docs for icicle() and sunburst()
- [x] 4.2 Run devtools::document()
- [x] 4.3 Run devtools::test() — all pass
- [x] 4.4 Run devtools::check() — 0 errors, 0 warnings
