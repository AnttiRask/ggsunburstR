## ADDED Requirements

### Requirement: fill = "auto" maps to depth
`sunburst()`, `icicle()`, and `donut()` SHALL accept `fill = "auto"` which maps the fill aesthetic to the `depth` column.

#### Scenario: sunburst auto fill
- **WHEN** `sunburst(sb, fill = "auto")` is called
- **THEN** the fill aesthetic SHALL be mapped to `depth` and the built plot SHALL have varying fill values

#### Scenario: icicle auto fill
- **WHEN** `icicle(sb, fill = "auto")` is called
- **THEN** the fill aesthetic SHALL be mapped to `depth`

#### Scenario: donut auto fill
- **WHEN** `donut(sb, fill = "auto")` is called
- **THEN** the fill aesthetic SHALL be mapped to `depth`

### Requirement: fill = "none" produces static grey
`sunburst()`, `icicle()`, and `donut()` SHALL accept `fill = "none"` which produces a static grey fill with no aesthetic mapping.

#### Scenario: sunburst none fill
- **WHEN** `sunburst(sb, fill = "none")` is called
- **THEN** all rectangles SHALL have the same grey fill

#### Scenario: icicle none fill
- **WHEN** `icicle(sb, fill = "none")` is called
- **THEN** all rectangles SHALL have the same grey fill

### Requirement: fill = NULL still produces grey (non-breaking)
`fill = NULL` (the default) SHALL continue to produce static grey fill, identical to `fill = "none"`.

#### Scenario: default unchanged
- **WHEN** `sunburst(sb)` is called (fill = NULL)
- **THEN** all rectangles SHALL have the same grey fill (no change from prior behaviour)

### Requirement: "auto" and "none" are reserved
`fill = "auto"` and `fill = "none"` SHALL NOT be validated against `names(sb$rects)`.

#### Scenario: no error for "auto"
- **WHEN** `sunburst(sb, fill = "auto")` is called and there is no column named "auto" in rects
- **THEN** no error SHALL be raised
