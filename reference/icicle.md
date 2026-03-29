# Create a rectangular icicle plot

Creates an icicle (rectangular, top-down) plot from a `sunburst_data`
object using
[`ggplot2::geom_rect()`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
with `scale_y_reverse()` and `theme_void()`.

## Usage

``` r
icicle(
  sb,
  fill = NULL,
  colour = "white",
  linewidth = 0.2,
  show_labels = FALSE,
  show_node_labels = FALSE,
  label_size = 3,
  min_label_angle = 0,
  label_repel = FALSE,
  ...
)
```

## Arguments

- sb:

  A `sunburst_data` object from
  [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md).

- fill:

  Fill mapping. Accepts bare names or strings. One of:

  - `NULL` (default): static grey fill (no aesthetic mapping).

  - `"auto"`: maps fill to the `depth` column.

  - `"none"`: explicit static grey fill (same as `NULL`).

  - A column name: either bare (`fill = depth`) or quoted
    (`fill = "depth"`).

- colour:

  Border colour for rectangles. Default `"white"`.

- linewidth:

  Border line width. Default `0.2`.

- show_labels:

  Whether to add text labels. Default `FALSE`.

- show_node_labels:

  Whether to add text labels for internal nodes. Only takes effect when
  `show_labels = TRUE`. Default `FALSE`.

- label_size:

  Text size for labels. Default `3`.

- min_label_angle:

  Minimum angular extent (degrees) for a node to receive a label. Nodes
  with `delta_angle < min_label_angle` are not labelled. Default `0` (no
  filtering).

- label_repel:

  Use
  [`ggrepel::geom_text_repel()`](https://ggrepel.slowkow.com/reference/geom_text_repel.html)
  for collision avoidance. Requires the `ggrepel` package. Default
  `FALSE`.

- ...:

  Passed to `geom_rect()`.

## Value

A `ggplot` object with `scale_y_reverse()` and `theme_void()`.

## Examples

``` r
sb <- sunburst_data("((a, b, c), (d, e));")
icicle(sb)

icicle(sb, fill = "depth")

```
