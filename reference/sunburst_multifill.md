# Create a sunburst plot with per-depth fill scales

Creates a sunburst plot where different depth levels can use different
fill colour mappings. Uses
[`ggnewscale::new_scale_fill()`](https://eliocamp.github.io/ggnewscale/reference/new_scale.html)
to enable multiple fill scales in a single plot.

## Usage

``` r
sunburst_multifill(sb, fills, colour = "white", linewidth = 0.2, ...)
```

## Arguments

- sb:

  A `sunburst_data` object from
  [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md).

- fills:

  A named list mapping depth levels (as character strings) to column
  names in `sb$rects` for fill mapping. E.g.,
  `list("1" = "name", "2" = "value")`.

- colour:

  Border colour for rectangles. Default `"white"`.

- linewidth:

  Border line width. Default `0.2`.

- ...:

  Passed to
  [`ggplot2::geom_rect()`](https://ggplot2.tidyverse.org/reference/geom_tile.html).

## Value

A `ggplot` object with `coord_polar()` and `theme_void()`. Users can add
`scale_fill_*()` calls after the plot to control each depth's colour
palette.

## See also

[`icicle_multifill()`](https://anttirask.github.io/ggsunburstR/reference/icicle_multifill.md)
for the rectangular variant,
[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
for single-scale fill.

## Examples

``` r
sb <- sunburst_data("((a, b, c), (d, e));")
if (requireNamespace("ggnewscale", quietly = TRUE)) {
  sunburst_multifill(sb, fills = list("1" = "name", "2" = "name"))
}

```
