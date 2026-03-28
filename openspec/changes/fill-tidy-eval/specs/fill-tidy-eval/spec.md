## ADDED Requirements

### Requirement: Bare name fill support
`sunburst()`, `icicle()`, and `donut()` SHALL accept bare column names for the `fill` parameter.

#### Scenario: Bare name fill
- **WHEN** `sunburst(sb, fill = depth)` is called
- **THEN** the fill aesthetic SHALL be mapped to the `depth` column

#### Scenario: Bare name equivalence
- **WHEN** `sunburst(sb, fill = depth)` and `sunburst(sb, fill = "depth")` are called
- **THEN** both SHALL produce identical plots

#### Scenario: Bare name in icicle
- **WHEN** `icicle(sb, fill = name)` is called
- **THEN** the fill aesthetic SHALL be mapped to the `name` column

#### Scenario: Bare name in donut
- **WHEN** `donut(sb, fill = depth, levels = 2)` is called
- **THEN** the fill aesthetic SHALL be mapped to the `depth` column

### Requirement: Backward compatibility
String fill values SHALL continue to work unchanged.

#### Scenario: String fill unchanged
- **WHEN** `sunburst(sb, fill = "depth")` is called
- **THEN** the result SHALL be identical to prior versions

#### Scenario: Special strings preserved
- **WHEN** `sunburst(sb, fill = "auto")` or `sunburst(sb, fill = "none")` is called
- **THEN** the behaviour SHALL be unchanged from Change 25
