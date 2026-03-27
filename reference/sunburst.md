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
  label_type = c("radial", "perpendicular"),
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

- label_type:

  Label orientation. `"radial"`: text reads outward. `"perpendicular"`:
  text follows arc (post-MVP quality).

- ...:

  Passed to `geom_rect()`.

## Value

A `ggplot` object with `coord_polar()` and `theme_void()`.

## Examples

``` r
sb <- sunburst_data("((a, b, c), (d, e));")
sunburst(sb)

sunburst(sb, fill = "depth")

```
