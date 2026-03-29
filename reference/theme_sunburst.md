# Sunburst theme

A ggplot2 theme tailored for sunburst and donut charts. Based on
[`ggplot2::theme_void()`](https://ggplot2.tidyverse.org/reference/ggtheme.html)
with centred bold title, legend at bottom, and tidy margins.

## Usage

``` r
theme_sunburst(base_size = 11, base_family = "")
```

## Arguments

- base_size:

  Base font size. Default `11`.

- base_family:

  Base font family. Default `""`.

## Value

A ggplot2
[`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
object.

## See also

[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md),
[`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md)

## Examples

``` r
sb <- sunburst_data("((a, b, c), (d, e));")
sunburst(sb, fill = "depth") + theme_sunburst()

```
