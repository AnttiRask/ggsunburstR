## ADDED Requirements

### Requirement: Sunburst multi-scale fill
`sunburst_multifill()` SHALL accept a `sunburst_data` object and a named list `fills` mapping depth levels (as character strings) to fill column names. It SHALL return a `ggplot` object with `coord_polar()` and `theme_void()`.

#### Scenario: Basic multi-fill
- **WHEN** `sunburst_multifill(sb, fills = list("1" = "name"))` is called
- **THEN** the returned ggplot SHALL contain a `geom_rect` layer for depth 1 with fill mapped to "name"

#### Scenario: Multiple depths
- **WHEN** `sunburst_multifill(sb, fills = list("1" = "name", "2" = "name"))` is called
- **THEN** the returned ggplot SHALL contain separate fill-mapped `geom_rect` layers for each depth

#### Scenario: Unspecified depths rendered grey
- **WHEN** `sunburst_multifill(sb, fills = list("1" = "name"))` is called on a tree with depths 0, 1, 2
- **THEN** depths 0 and 2 SHALL be rendered with static grey fill (no fill mapping)

### Requirement: Icicle multi-scale fill
`icicle_multifill()` SHALL accept the same parameters as `sunburst_multifill()`. It SHALL return a `ggplot` object with `scale_y_reverse()` and `theme_void()` (no `coord_polar()`).

#### Scenario: Icicle multi-fill
- **WHEN** `icicle_multifill(sb, fills = list("1" = "name"))` is called
- **THEN** the returned ggplot SHALL contain fill-mapped layers and use `scale_y_reverse()`

### Requirement: ggnewscale runtime check
Both functions SHALL check that `ggnewscale` is installed using `rlang::check_installed()`.

### Requirement: Input validation
Both functions SHALL validate inputs.

#### Scenario: fills must be a named list
- **WHEN** `sunburst_multifill(sb, fills = c("name"))` is called
- **THEN** an error SHALL be raised

#### Scenario: fills names must be valid depths
- **WHEN** `sunburst_multifill(sb, fills = list("99" = "name"))` is called on a tree with max depth 2
- **THEN** an error SHALL be raised

#### Scenario: fill column must exist
- **WHEN** `sunburst_multifill(sb, fills = list("1" = "nonexistent"))` is called
- **THEN** an error SHALL be raised
