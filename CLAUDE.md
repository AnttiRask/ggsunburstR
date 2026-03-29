# ggsunburstR

## Project Overview

`ggsunburstR` is an R package for creating sunburst, icicle, donut, and
tree adjacency diagrams using ggplot2. It accepts hierarchical data in 9
input formats (Newick strings/files, data frames, lineage files,
node-parent files, path strings,
[`ape::phylo`](https://rdrr.io/pkg/ape/man/read.tree.html),
[`data.tree::Node`](https://rdrr.io/pkg/data.tree/man/Node.html)),
computes rectangle coordinates for each node, and produces standard
ggplot2 objects.

A pure-R reimplementation of `ggsunburst` that eliminates the
Python/reticulate dependency.

- **Status**: v0.5.1 (PoC complete). Manual testing phase before
  potential redesign.
- **License**: MIT
- **R version**: \>= 4.1.0 (for base pipe `|>`)

## Architecture

    User API:     sunburst_data() / drilldown() → sunburst() / icicle() / donut() / ggtree()
    Geom API:     ggplot(df) + geom_sunburst(aes(id, parent)) + coord_polar()
    Annotations:  highlight_nodes(), bars(), tile(), sunburst_multifill(), icicle_multifill()
    S3 class:     sunburst_data (print, plot, as.data.frame, $data alias)
    Computation:  assign_sizes → compute_coordinates → compute_label_positions
    Parsing:      detect_input_type → parse_newick / parse_dataframe / parse_lineage /
                  parse_node_parent / parse_paths / parse_datatree / phylo_to_tree
    Tree:         new_tree, add_child, get_descendants, get_leaves, ladderize_tree,
                  convert_to_ultrametric, extract_subtree
    Helpers:      .read_newick_safe, .resolve_fill, .validate_fill, .build_rect_layer,
                  .filter_by_angle, .add_text_layer, rangle, pangle, hjust_rtext, vjust_ptext

## Development Setup

- Use `devtools` for all development workflows.
- Dependencies: `ape`, `cli`, `ggplot2`, `rlang` (Imports); `testthat`,
  `vdiffr`, `knitr`, `rmarkdown`, `ggrepel`, `ggnewscale`, `data.tree`,
  `tibble`, `dplyr`, `tidyr` (Suggests).

## Common Commands

``` r
devtools::load_all()      # Load package for interactive use
devtools::test()          # Run all 625 tests
devtools::test(filter = "parse-newick")  # Run specific test file
devtools::check()         # R CMD check (target: 0/0/0)
devtools::document()      # Regenerate NAMESPACE and man/ from roxygen2
pkgdown::build_site()     # Build documentation site locally
```

## Code Style

- Follow the [Tidyverse style guide](https://style.tidyverse.org/).
- Use roxygen2 for exported function documentation. Internal functions
  get code comments (`# ...`), not roxygen2.
- Use testthat edition 3. Test files mirror source: `R/parse-newick.R` →
  `tests/testthat/test-parse-newick.R`.
- Pipe operator: use `|>` (base R pipe).
- Assignment: use `<-`, never `=`.
- Use
  [`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
  for error messages with interpolation,
  [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) for
  static strings. Never use
  [`stop()`](https://rdrr.io/r/base/stop.html).
- Use [`rlang::warn()`](https://rlang.r-lib.org/reference/abort.html) /
  `inform()` for warnings/info. Never use
  [`warning()`](https://rdrr.io/r/base/warning.html) /
  [`message()`](https://rdrr.io/r/base/message.html).
- Use `::` for one-off calls to dependencies. `@importFrom` only in
  `ggsunburstR-package.R` for `rlang` and `stats`.
- Internal functions: prefixed with `.` for truly private helpers (e.g.,
  `.resolve_fill()`), unprefixed for internal-but-testable functions
  (e.g., `parse_newick()`).

## Key Design Decisions

- **Internal tree as list** (`nodes`, `children`, `parent`, `root`,
  `n_tips`) – not exported, integer-indexed node IDs. See SPEC.md S2.1.
- **`add_child()` copy semantics** – returns modified tree via
  `attr(, "tree")` workaround for R’s copy-on-modify.
- **Pre-computed coordinates + `geom_rect()`** for convenience
  functions; custom `StatSunburst` ggproto for
  [`geom_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/geom_sunburst.md).
- **`fill` supports tidy eval** – bare names (`fill = depth`), strings
  (`fill = "depth"`), and special values (`"auto"`, `"none"`).
- **Shared helpers** in `R/utils.R` – `.resolve_fill()`,
  `.validate_fill()`, `.build_rect_layer()`, `.read_newick_safe()`,
  `.filter_by_angle()`, `.add_text_layer()`.

## Exported Functions (15)

- [`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md),
  [`drilldown()`](https://anttirask.github.io/ggsunburstR/reference/drilldown.md)
  – data preparation
- [`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md),
  [`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md),
  [`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md),
  [`ggtree()`](https://anttirask.github.io/ggsunburstR/reference/ggtree.md)
  – standalone plot constructors
- [`geom_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/geom_sunburst.md)
  – ggplot2 geom layer
- [`highlight_nodes()`](https://anttirask.github.io/ggsunburstR/reference/highlight_nodes.md),
  [`bars()`](https://anttirask.github.io/ggsunburstR/reference/bars.md),
  [`tile()`](https://anttirask.github.io/ggsunburstR/reference/tile.md)
  – annotation layers
- [`sunburst_multifill()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_multifill.md),
  [`icicle_multifill()`](https://anttirask.github.io/ggsunburstR/reference/icicle_multifill.md)
  – per-depth fill scales
- [`nw_print()`](https://anttirask.github.io/ggsunburstR/reference/nw_print.md)
  – tree inspection utility
- [`theme_sunburst()`](https://anttirask.github.io/ggsunburstR/reference/theme_sunburst.md)
  – custom theme
- S3 methods: `print`, `plot`, `as.data.frame`, `$` for `sunburst_data`

## Git Conventions

- Branch from `main` for each change: `change/<slug>`
- Commit messages: conventional commits (`feat:`, `fix:`, `test:`,
  `docs:`, `chore:`, `refactor:`)
- Never commit directly to `main` – merge from change branches after
  review.
- OpenSpec manages change lifecycle in `openspec/` directory.

## CI/CD

- **R CMD check**: `.github/workflows/R-CMD-check.yaml` – runs on macOS,
  Windows, Ubuntu (R devel/release/oldrel)
- **pkgdown**: `.github/workflows/pkgdown.yaml` – builds and deploys to
  gh-pages on push to main
- **Site**: <https://anttirask.github.io/ggsunburstR/>

## Reference Documents

- `SPEC.md` – Full architecture spec (source of truth for design
  decisions)
- `REQUIREMENTS.md` – Original requirements
- `SUMMARY.md` – Development history across v0.1-v0.5
- `SUGGESTIONS.md` – Deferred reviewer suggestions (grouped by theme)
- `openspec/` – Change management (archived changes in
  `openspec/changes/archive/`)
- `reviews/` – All reviewer COMMENTS.md files
- `sunburst_data.R` – Legacy reference code (not part of the package)
