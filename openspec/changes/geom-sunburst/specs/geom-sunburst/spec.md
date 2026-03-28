## ADDED Requirements

### Requirement: geom_sunburst creates valid ggplot layer
`geom_sunburst()` SHALL return a ggplot2 layer using `StatSunburst` and `GeomRect`.

#### Scenario: Basic plot builds
- **WHEN** `ggplot(df) + geom_sunburst(aes(id = child, parent = parent))` is called
- **THEN** the plot SHALL build without error and contain rectangles for all non-root nodes

#### Scenario: Correct number of rectangles
- **WHEN** a data.frame with 5 children and 1 root is plotted
- **THEN** the output SHALL have 5 rectangles (root excluded)

### Requirement: Fill aesthetic mapping
`geom_sunburst()` SHALL support `aes(fill = column)` for colour mapping.

#### Scenario: Fill mapping works
- **WHEN** `ggplot(df) + geom_sunburst(aes(id = child, parent = parent, fill = group))` is called
- **THEN** the built plot SHALL have varying fill values

### Requirement: Stat parameters
`geom_sunburst()` SHALL accept `values`, `branchvalues`, and `leaf_mode` parameters passed through to the stat.

#### Scenario: Value-weighted sizing
- **WHEN** `geom_sunburst(aes(id = child, parent = parent), values = "value")` is called on data with a `value` column
- **THEN** rectangle widths SHALL be proportional to values

#### Scenario: branchvalues parameter
- **WHEN** `geom_sunburst(..., branchvalues = "total")` is called
- **THEN** the stat SHALL use total branch value computation

### Requirement: coord_polar composability
The user SHALL add `coord_polar()` themselves for sunburst layout. Without it, the output SHALL be an icicle layout.

#### Scenario: Sunburst with coord_polar
- **WHEN** `ggplot(df) + geom_sunburst(...) + coord_polar()` is called
- **THEN** the result SHALL have CoordPolar

#### Scenario: Icicle without coord_polar
- **WHEN** `ggplot(df) + geom_sunburst(...)` is called without coord_polar
- **THEN** the result SHALL use default Cartesian coordinates

### Requirement: Required aesthetics
`StatSunburst` SHALL require `id` and `parent` aesthetics.

#### Scenario: Missing id errors
- **WHEN** `geom_sunburst(aes(parent = parent))` is used (missing id)
- **THEN** an error SHALL be raised
