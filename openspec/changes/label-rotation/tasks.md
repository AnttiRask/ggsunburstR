## 1. Data layer — enrich leaf_labels

- [x] 1.1 Write test: leaf_labels includes ymin, ymax, delta_angle columns
- [x] 1.2 Add delta_angle computation for leaf nodes in compute_label_positions()
- [x] 1.3 Add ymin, ymax, delta_angle to leaf_labels output in .build_output()

## 2. Perpendicular labels in sunburst()

- [x] 2.1 Write test: label_type = "perpendicular" uses pangle/pvjust in geom_text
- [x] 2.2 Write test: perpendicular labels positioned at radial midpoint (ymin+ymax)/2
- [x] 2.3 Implement label_type = "perpendicular" rendering in sunburst()

## 3. Internal node labels

- [x] 3.1 Write test: show_node_labels = TRUE adds a second geom_text layer (sunburst)
- [x] 3.2 Write test: show_node_labels = TRUE adds a second geom_text layer (icicle)
- [x] 3.3 Implement show_node_labels in sunburst()
- [x] 3.4 Implement show_node_labels in icicle()

## 4. Label size parameter

- [x] 4.1 Write test: label_size controls geom_text size (sunburst)
- [x] 4.2 Write test: label_size applies to both leaf and node labels
- [x] 4.3 Implement label_size parameter in sunburst() and icicle()

## 5. Minimum label angle filtering

- [x] 5.1 Write test: min_label_angle = 0 shows all labels (default)
- [x] 5.2 Write test: min_label_angle filters narrow sectors
- [x] 5.3 Write test: min_label_angle filters node labels too
- [x] 5.4 Implement min_label_angle filtering in sunburst()
- [x] 5.5 Mirror min_label_angle to icicle()

## 6. Input validation

- [x] 6.1 Write test: negative min_label_angle errors
- [x] 6.2 Implement min_label_angle validation in sunburst() and icicle()

## 7. Documentation and checks

- [x] 7.1 Update roxygen2 docs for sunburst() and icicle()
- [x] 7.2 Run devtools::document()
- [x] 7.3 Run devtools::test() — all pass
- [x] 7.4 Run devtools::check() — 0 errors, 0 warnings
