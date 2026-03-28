## ADDED Requirements

### Requirement: theme_sunburst returns a ggplot2 theme
`theme_sunburst()` SHALL return a complete ggplot2 theme object based on `theme_void()`.

#### Scenario: Returns theme object
- **WHEN** `theme_sunburst()` is called
- **THEN** the result SHALL inherit from `gg` theme class

#### Scenario: Composable with ggplot
- **WHEN** `sunburst(sb) + theme_sunburst()` is called
- **THEN** the result SHALL be a valid ggplot object

### Requirement: Theme elements
`theme_sunburst()` SHALL set: plot title centred and bold, legend at bottom, plot margins of 5px.

#### Scenario: Title centred and bold
- **WHEN** `theme_sunburst()` is called
- **THEN** `plot.title` SHALL have `hjust = 0.5` and `face = "bold"`

#### Scenario: Legend at bottom
- **WHEN** `theme_sunburst()` is called
- **THEN** `legend.position` SHALL be `"bottom"`

#### Scenario: Plot margins
- **WHEN** `theme_sunburst()` is called
- **THEN** `plot.margin` SHALL be `margin(5, 5, 5, 5)`

### Requirement: base_size and base_family parameters
`theme_sunburst()` SHALL accept `base_size` (default 11) and `base_family` (default "") parameters passed to `theme_void()`.

#### Scenario: Custom base_size
- **WHEN** `theme_sunburst(base_size = 14)` is called
- **THEN** the base text size SHALL be 14
