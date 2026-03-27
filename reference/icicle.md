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

  Whether to add text labels. Default `FALSE`.

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
