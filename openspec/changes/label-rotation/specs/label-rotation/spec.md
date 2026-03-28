## ADDED Requirements

### Requirement: Perpendicular label orientation
`sunburst()` SHALL support `label_type = "perpendicular"` which renders leaf labels using `pangle` for text angle and `pvjust` for vertical justification, positioned at the radial midpoint `(ymin + ymax) / 2`.

#### Scenario: Perpendicular labels use pangle column
- **WHEN** `sunburst(sb, show_labels = TRUE, label_type = "perpendicular")` is called
- **THEN** the geom_text layer SHALL use the `pangle` column for angle and `pvjust` column for vjust

#### Scenario: Perpendicular labels positioned at radial midpoint
- **WHEN** `sunburst(sb, show_labels = TRUE, label_type = "perpendicular")` is called
- **THEN** the label y position SHALL be `(ymin + ymax) / 2` (not `ymax`)

### Requirement: Internal node labels
`sunburst()` and `icicle()` SHALL support `show_node_labels = FALSE` (default) parameter. When `TRUE`, a second geom_text layer SHALL be added using `sb$node_labels`.

#### Scenario: Node labels off by default
- **WHEN** `sunburst(sb, show_labels = TRUE)` is called without `show_node_labels`
- **THEN** only leaf labels SHALL be rendered (no internal node label layer)

#### Scenario: Node labels enabled
- **WHEN** `sunburst(sb, show_labels = TRUE, show_node_labels = TRUE)` is called
- **THEN** both leaf label and node label geom_text layers SHALL be present

#### Scenario: Node labels in icicle
- **WHEN** `icicle(sb, show_labels = TRUE, show_node_labels = TRUE)` is called
- **THEN** both leaf label and node label geom_text layers SHALL be present

### Requirement: Label size parameter
`sunburst()` and `icicle()` SHALL accept `label_size = 3` (default) parameter controlling the `size` argument of `geom_text()`.

#### Scenario: Custom label size
- **WHEN** `sunburst(sb, show_labels = TRUE, label_size = 5)` is called
- **THEN** the geom_text layer SHALL use `size = 5`

#### Scenario: Label size applies to both leaf and node labels
- **WHEN** `sunburst(sb, show_labels = TRUE, show_node_labels = TRUE, label_size = 4)` is called
- **THEN** both leaf and node label layers SHALL use `size = 4`

### Requirement: Minimum label angle filtering
`sunburst()` and `icicle()` SHALL accept `min_label_angle = 0` (default) parameter. Leaf labels with `delta_angle < min_label_angle` SHALL be excluded. Node labels with `delta_angle < min_label_angle` SHALL be excluded.

#### Scenario: No filtering by default
- **WHEN** `sunburst(sb, show_labels = TRUE)` is called (min_label_angle = 0)
- **THEN** all leaf labels SHALL be rendered

#### Scenario: Narrow sectors filtered
- **WHEN** `sunburst(sb, show_labels = TRUE, min_label_angle = 30)` is called on a tree where some leaves span less than 30°
- **THEN** only leaves with `delta_angle >= 30` SHALL receive labels

#### Scenario: Node labels also filtered
- **WHEN** `sunburst(sb, show_labels = TRUE, show_node_labels = TRUE, min_label_angle = 50)` is called
- **THEN** node labels with `delta_angle < 50` SHALL be excluded

### Requirement: Leaf labels include geometry columns
The `leaf_labels` data.frame in `sunburst_data` output SHALL include `ymin`, `ymax`, and `delta_angle` columns.

#### Scenario: Leaf labels have ymin and ymax
- **WHEN** `sb <- sunburst_data("((a, b, c), (d, e));")` is called
- **THEN** `sb$leaf_labels` SHALL contain `ymin` and `ymax` numeric columns

#### Scenario: Leaf labels have delta_angle
- **WHEN** `sb <- sunburst_data("((a, b, c), (d, e));")` is called
- **THEN** `sb$leaf_labels` SHALL contain a `delta_angle` numeric column with positive values

### Requirement: Input validation for label parameters
`sunburst()` and `icicle()` SHALL validate label parameters.

#### Scenario: Invalid label_type
- **WHEN** `sunburst(sb, label_type = "invalid")` is called
- **THEN** an error SHALL be raised by `match.arg()`

#### Scenario: Negative min_label_angle
- **WHEN** `sunburst(sb, min_label_angle = -5)` is called
- **THEN** an error SHALL be raised stating min_label_angle must be non-negative
