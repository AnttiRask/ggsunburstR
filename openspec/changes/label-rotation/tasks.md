## 1. Data layer — enrich leaf_labels

- [ ] 1.1 Write test: leaf_labels includes ymin, ymax, delta_angle columns
- [ ] 1.2 Add delta_angle computation for leaf nodes in compute_label_positions()
- [ ] 1.3 Add ymin, ymax, delta_angle to leaf_labels output in .build_output()

## 2. Perpendicular labels in sunburst()

- [ ] 2.1 Write test: label_type = "perpendicular" uses pangle/pvjust in geom_text
- [ ] 2.2 Write test: perpendicular labels positioned at radial midpoint (ymin+ymax)/2
- [ ] 2.3 Implement label_type = "perpendicular" rendering in sunburst()

## 3. Internal node labels

- [ ] 3.1 Write test: show_node_labels = TRUE adds a second geom_text layer (sunburst)
- [ ] 3.2 Write test: show_node_labels = TRUE adds a second geom_text layer (icicle)
- [ ] 3.3 Implement show_node_labels in sunburst()
- [ ] 3.4 Implement show_node_labels in icicle()

## 4. Label size parameter

- [ ] 4.1 Write test: label_size controls geom_text size (sunburst)
- [ ] 4.2 Write test: label_size applies to both leaf and node labels
- [ ] 4.3 Implement label_size parameter in sunburst() and icicle()

## 5. Minimum label angle filtering

- [ ] 5.1 Write test: min_label_angle = 0 shows all labels (default)
- [ ] 5.2 Write test: min_label_angle filters narrow sectors
- [ ] 5.3 Write test: min_label_angle filters node labels too
- [ ] 5.4 Implement min_label_angle filtering in sunburst()
- [ ] 5.5 Mirror min_label_angle to icicle()

## 6. Input validation

- [ ] 6.1 Write test: negative min_label_angle errors
- [ ] 6.2 Implement min_label_angle validation in sunburst() and icicle()

## 7. Documentation and checks

- [ ] 7.1 Update roxygen2 docs for sunburst() and icicle()
- [ ] 7.2 Run devtools::document()
- [ ] 7.3 Run devtools::test() — all pass
- [ ] 7.4 Run devtools::check() — 0 errors, 0 warnings
