# Create a polar sunburst plot

Creates a sunburst (radial) plot from a `sunburst_data` object using
[`ggplot2::geom_rect()`](https://ggplot2.tidyverse.org/reference/geom_tile.html)
with `coord_polar()` and `theme_void()`.

## Usage

``` r
sunburst(
  sb,
  fill = NULL,
  colour = "white",
  linewidth = 0.2,
  show_labels = FALSE,
  show_node_labels = FALSE,
  label_type = c("radial", "perpendicular"),
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

  Column name in `sb$rects` to map to fill aesthetic. When `NULL`, a
  static grey fill is used.

- colour:

  Border colour for rectangles. Default `"white"`.

- linewidth:

  Border line width. Default `0.2`.

- show_labels:

  Whether to add text labels for leaf nodes. Default `FALSE`.

- show_node_labels:

  Whether to add text labels for internal nodes. Only takes effect when
  `show_labels = TRUE`. Default `FALSE`.

- label_type:

  Label orientation. `"radial"`: text reads outward. `"perpendicular"`:
  text follows the arc.

- label_size:

  Text size for labels. Default `3`.

- min_label_angle:

  Minimum angular extent (degrees) for a node to receive a label. Nodes
  with `delta_angle < min_label_angle` are not labelled. Default `0` (no
  filtering).

- label_repel:

  Not supported for sunburst plots. Use
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
  for label repulsion, or `min_label_angle` to reduce label clutter on
  sunbursts. Default `FALSE`.

- ...:

  Passed to `geom_rect()`.

## Value

A `ggplot` object with `coord_polar()` and `theme_void()`.

## Examples

``` r
sb <- sunburst_data("((a, b, c), (d, e));")
sunburst(sb)

sunburst(sb, fill = "depth")

sunburst(sb, show_labels = TRUE, label_type = "perpendicular")

```
