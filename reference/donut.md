# Create a donut (ring) chart

Creates a donut chart – a sunburst restricted to the outermost 1–N depth
levels. The centre hole is created by shifting Y coordinates so the
innermost displayed ring has `ymin > 0`.

## Usage

``` r
donut(
  sb,
  levels = 1,
  fill = NULL,
  colour = "white",
  linewidth = 0.2,
  show_labels = FALSE,
  hole_size = 1,
  ...
)
```

## Arguments

- sb:

  A `sunburst_data` object from
  [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md).

- levels:

  Number of depth levels to display (from the outermost inward). `1` =
  single ring, `2` = two concentric rings.

- fill:

  Column name to map to fill aesthetic. `NULL` for static grey.

- colour:

  Border colour for segments. Default `"white"`.

- linewidth:

  Border line width. Default `0.2`.

- show_labels:

  Whether to display labels. Default `FALSE`.

- hole_size:

  Size of the centre hole. Higher = larger hole relative to ring
  thickness. Default `1`.

- ...:

  Passed to `geom_rect()`.

## Value

A `ggplot` object with `coord_polar()` and `theme_void()`.

## See also

[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
for full sunburst plots,
[`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
for rectangular layouts.

## Examples

``` r
sb <- sunburst_data("((a, b, c), (d, e));")
donut(sb, fill = "name")

donut(sb, levels = 2, fill = "depth")

```
