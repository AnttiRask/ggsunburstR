## ADDED Requirements

### Requirement: Icicle label repulsion
`icicle()` SHALL support `label_repel = FALSE` (default) parameter. When `TRUE` and `show_labels = TRUE`, leaf labels SHALL use `ggrepel::geom_text_repel()` instead of `ggplot2::geom_text()`.

#### Scenario: Repel off by default
- **WHEN** `icicle(sb, show_labels = TRUE)` is called
- **THEN** leaf labels SHALL use `ggplot2::geom_text()`

#### Scenario: Repel enabled
- **WHEN** `icicle(sb, show_labels = TRUE, label_repel = TRUE)` is called
- **THEN** leaf labels SHALL use `ggrepel::geom_text_repel()`

#### Scenario: Repel with node labels
- **WHEN** `icicle(sb, show_labels = TRUE, show_node_labels = TRUE, label_repel = TRUE)` is called
- **THEN** both leaf and node label layers SHALL use `ggrepel::geom_text_repel()`

#### Scenario: Repel with min_label_angle
- **WHEN** `icicle(sb, show_labels = TRUE, label_repel = TRUE, min_label_angle = 50)` is called
- **THEN** labels SHALL be filtered first, then repulsion applied to remaining labels

### Requirement: ggrepel runtime check
When `label_repel = TRUE`, `icicle()` SHALL check that `ggrepel` is installed using `rlang::check_installed("ggrepel")`.

#### Scenario: ggrepel not installed
- **WHEN** `icicle(sb, show_labels = TRUE, label_repel = TRUE)` is called and `ggrepel` is not installed
- **THEN** an error SHALL be raised prompting the user to install `ggrepel`

### Requirement: Sunburst repel limitation
`sunburst()` SHALL accept `label_repel = FALSE` (default) parameter. When `TRUE`, it SHALL raise an informative error explaining that repulsion is not supported for polar plots in this version.

#### Scenario: Sunburst repel errors
- **WHEN** `sunburst(sb, show_labels = TRUE, label_repel = TRUE)` is called
- **THEN** an error SHALL be raised mentioning polar coordinate limitation and suggesting `min_label_angle`
