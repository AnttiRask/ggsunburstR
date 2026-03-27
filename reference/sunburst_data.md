# Parse hierarchical input into sunburst/icicle data

Accepts hierarchical data in multiple formats (Newick strings/files,
data frames, lineage files, node-parent files), computes rectangle
coordinates for each node, and returns a `sunburst_data` S3 object
suitable for rendering with
[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md)
or
[`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md).

## Usage

``` r
sunburst_data(
  input,
  type = "auto",
  values = NULL,
  branchvalues = c("remainder", "total"),
  leaf_mode = c("actual", "extended"),
  ladderize = FALSE,
  ultrametric = FALSE,
  xlim = 360,
  rot = 0,
  node_attributes = NULL,
  sep = NULL,
  ...
)
```

## Arguments

- input:

  Hierarchical data. One of: Newick string, file path, data.frame with
  parent-child columns.

- type:

  Input type. One of `"auto"`, `"newick"`, `"lineage"`, `"node_parent"`,
  `"dataframe"`. Auto-detection is recommended.

- values:

  Column name (character, for data.frame input) or named numeric vector
  mapping node names to values for sector sizing. `NULL` for equal
  weight.

- branchvalues:

  How parent values relate to children. `"remainder"`: parent value is
  additive. `"total"`: parent value equals sum of children.

- leaf_mode:

  How short branches are handled. `"actual"`: stop at real depth.
  `"extended"`: extend to max depth.

- ladderize:

  Sort partitions by descendant count. `FALSE` for no sorting, `TRUE` or
  `"right"` for ascending, `"left"` for descending.

- ultrametric:

  If `TRUE`, convert tree to ultrametric topology.

- xlim:

  Angular span in degrees. Default `360` for full circle.

- rot:

  Rotation offset in degrees.

- node_attributes:

  Character vector of additional node attribute names to include in
  output.

- sep:

  Separator for file-based inputs.

- ...:

  Reserved for future parameters.

## Value

An S3 object of class `"sunburst_data"` containing `$rects`,
`$leaf_labels`, `$node_labels`, `$segments`, and `$tree`.

## Examples

``` r
# Newick string
sb <- sunburst_data("((a, b, c), (d, e));")
sb
#> 
#> ── Sunburst data 
#> • 7 nodes (5 leaves, 2 internal)
#> • 2 depth levels
#> • xlim = 360°, rot = 0°

# Data frame
df <- data.frame(
  parent = c(NA, "root", "root"),
  child  = c("root", "A", "B")
)
sb <- sunburst_data(df)
```
