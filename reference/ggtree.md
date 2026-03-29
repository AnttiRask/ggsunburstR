# Create a tree-style dendrogram plot

Creates a classical node-link tree diagram (dendrogram) using
`geom_segment()` from the segment data in a `sunburst_data` object.

## Usage

``` r
ggtree(
  sb,
  colour = "black",
  linewidth = 0.5,
  show_labels = TRUE,
  label_size = 3,
  label_colour = "black",
  rotate = TRUE,
  polar = FALSE,
  blank = TRUE,
  show_scale = FALSE,
  scale_length = 0,
  ...
)
```

## Arguments

- sb:

  A `sunburst_data` object from
  [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md).

- colour:

  Line colour for tree segments. Default `"black"`.

- linewidth:

  Line width for tree segments. Default `0.5`.

- show_labels:

  Whether to display leaf labels. Default `TRUE`.

- label_size:

  Text size for leaf labels. Default `3`.

- label_colour:

  Text colour for leaf labels. Default `"black"`.

- rotate:

  If `TRUE` (default), apply `coord_flip()` for horizontal layout (root
  left, leaves right).

- polar:

  If `TRUE`, apply `coord_polar()` for circular layout. Overrides
  `rotate`.

- blank:

  If `TRUE` (default), apply `theme_void()`.

- show_scale:

  If `TRUE`, display a scale bar indicating branch-length units. Default
  `FALSE`.

- scale_length:

  Length of the scale bar. When `0` (default), auto-computed as one
  tenth of the total tree depth.

- ...:

  Passed to `geom_segment()`.

## Value

A `ggplot` object.

## Details

Three layout modes are available:

- Horizontal dendrogram (default): `rotate = TRUE, polar = FALSE`. Root
  at left, leaves at right.

- Vertical dendrogram: `rotate = FALSE, polar = FALSE`. Root at top,
  leaves at bottom.

- Circular (radial) tree: `polar = TRUE`. Root at centre, leaves around
  circumference with leader lines and rotated labels.

## Note

The Bioconductor package `ggtree` also exports a `ggtree()` function. If
both packages are loaded, use `ggsunburstR::ggtree()` to disambiguate.

## See also

[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
for polar sunburst plots,
[`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
for rectangular layouts.

## Examples

``` r
sb <- sunburst_data("((a, b, c), (d, e));")
ggtree(sb)

ggtree(sb, polar = TRUE)

```
