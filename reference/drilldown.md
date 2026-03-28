# Drill down into a subtree

Extracts a subtree rooted at the specified node and recomputes
coordinates so the subtree fills the full angular space. The result is a
new `sunburst_data` object compatible with all plot functions.

## Usage

``` r
drilldown(sb, node, ...)
```

## Arguments

- sb:

  A `sunburst_data` object.

- node:

  Node to use as the new root. Character string (node name) or integer
  (node ID).

- ...:

  Override parameters for the recomputation (e.g., `xlim`, `rot`).

## Value

A new `sunburst_data` object rooted at the selected node.

## See also

[`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md)
for creating the initial data,
[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md),
[`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md),
[`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md)
for plotting.

## Examples

``` r
sb <- sunburst_data("((a, b)X, (c, d)Y)root;")
# Drill into the X subtree (containing a, b)
sub <- drilldown(sb, node = "X")
sunburst(sub, fill = "name")

```
