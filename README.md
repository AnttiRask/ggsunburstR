# ggsunburstR

<!-- badges: start -->
[![R-CMD-check](https://github.com/AnttiRask/ggsunburstR/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/AnttiRask/ggsunburstR/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Create sunburst and icicle adjacency diagrams using ggplot2. Accepts
hierarchical data in multiple formats (Newick strings/files, data frames,
lineage files, node-parent files), computes rectangle coordinates for each
node, and produces standard ggplot2 objects that you can customise with the
familiar `+` syntax.

A pure-R reimplementation of
[ggsunburst](https://github.com/didacs/ggsunburst) that eliminates the
Python/reticulate dependency.

## Installation

Install the development version from GitHub:

```r
# install.packages("pak")
pak::pak("AnttiRask/ggsunburstR")
```

## Quick start

```r
library(ggsunburstR)

# From a Newick string
sb <- sunburst_data("((a, b, c), (d, e, f));")

# Sunburst (polar) plot
sunburst(sb, fill = "depth")

# Icicle (rectangular) plot
icicle(sb, fill = "depth")
```

## Input formats

ggsunburstR accepts four input formats:

```r
# 1. Newick string
sb <- sunburst_data("((a, b, c), (d, e, f));")

# 2. Newick file
sb <- sunburst_data("path/to/tree.nw")

# 3. Data frame with parent-child columns
df <- data.frame(
  parent = c(NA, "root", "root", "A", "A"),
  child  = c("root", "A", "B", "a1", "a2")
)
sb <- sunburst_data(df)

# 4. Node-parent CSV file
sb <- sunburst_data("path/to/data.csv", type = "node_parent")
```

## Customisation

The output is a standard ggplot2 object, so you can add layers, scales,
themes, and labels:

```r
sb <- sunburst_data("((a, b, c), (d, e, f));")

sunburst(sb, fill = "name") +
  ggplot2::scale_fill_brewer(palette = "Set3") +
  ggplot2::labs(title = "My Sunburst")
```

## Value-weighted sectors

Use the `values` parameter to size sectors by data:

```r
sb <- sunburst_data(
  "((a, b, c), (d, e, f));",
  values = c(a = 10, b = 5, c = 3, d = 8, e = 2, f = 1)
)
sunburst(sb, fill = "name")
```

## License

MIT
