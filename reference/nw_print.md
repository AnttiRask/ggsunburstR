# Print tree structure from Newick input

Displays a text summary of the tree encoded in a Newick string or file.
Useful for inspecting tree topology before creating plots.

## Usage

``` r
nw_print(newick, ladderize = FALSE, ultrametric = FALSE)
```

## Arguments

- newick:

  A Newick string or file path.

- ladderize:

  If not `FALSE`, sort partitions by descendant count. `TRUE` or
  `"right"` for ascending, `"left"` for descending.

- ultrametric:

  If `TRUE`, convert to ultrametric topology before printing.

## Value

`NULL`, invisibly. Called for its side effect of printing.

## Examples

``` r
nw_print("((a, b, c), (d, e));")
#> 
#> Phylogenetic tree with 5 tips and 3 internal nodes.
#> 
#> Tip labels:
#>   a, b, c, d, e
#> 
#> Rooted; no branch length. 
```
