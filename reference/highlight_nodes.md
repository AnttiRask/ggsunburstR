# Highlight specific nodes in a sunburst or icicle plot

Adds a `geom_rect()` layer on top of an existing plot to visually
emphasise specific nodes. Works with both
[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
and
[`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md)
plots.

## Usage

``` r
highlight_nodes(p, nodes, fill = "gold", colour = "black", linewidth = 0.5)
```

## Arguments

- p:

  A ggplot object produced by
  [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
  or
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md).

- nodes:

  Character vector of node names or integer vector of node IDs to
  highlight.

- fill:

  Fill colour for highlighted nodes. Default `"gold"`.

- colour:

  Border colour for highlighted nodes. Default `"black"`.

- linewidth:

  Border line width for highlighted nodes. Default `0.5`.

## Value

The input ggplot object with an additional highlight layer.

## Examples

``` r
sb <- sunburst_data("((a, b, c), (d, e));")
p <- sunburst(sb, fill = "depth")
highlight_nodes(p, nodes = c("a", "c"), fill = "red")

```
