# ggsunburstR

## Project Overview

`ggsunburstR` is an R package for creating sunburst and icicle adjacency
diagrams using ggplot2. It accepts hierarchical data in multiple formats
(Newick strings/files, data frames, lineage files, node-parent files),
computes rectangle coordinates for each node, and produces standard
ggplot2 objects.

A pure-R reimplementation of `ggsunburst` that eliminates the
Python/reticulate dependency.

- **Status**: MVP complete (v0.1.0). Post-MVP roadmap in SPEC.md §9.
- **License**: MIT
- **R version**: \>= 4.1.0 (for base pipe `|>`)

## Architecture

    User API:     sunburst_data() → sunburst() / icicle()
    S3 class:     sunburst_data (print, plot, as.data.frame, $data alias)
    Computation:  assign_sizes → compute_coordinates → compute_label_positions
    Parsing:      detect_input_type → parse_newick / parse_dataframe / parse_lineage / parse_node_parent
    Tree:         new_tree, add_child, get_descendants, get_leaves, ladderize_tree, convert_to_ultrametric

All internal functions (not exported) live in `R/tree-*.R`,
`R/compute-*.R`, `R/parse-*.R`, `R/detect-input.R`, `R/utils.R`.
Exported functions:
[`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md),
[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md),
[`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md),
plus S3 methods in `R/sunburst-class.R`.

## Development Setup

- Use `devtools` for all development workflows.
- Dependencies: `ape`, `cli`, `ggplot2`, `rlang` (Imports); `testthat`,
  `vdiffr`, `knitr`, `rmarkdown` (Suggests).

## Common Commands

``` r
devtools::load_all()      # Load package for interactive use
devtools::test()          # Run all 342 tests
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
- Use [`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) /
  `warn()` / `inform()` for user-facing messages, never
  [`stop()`](https://rdrr.io/r/base/stop.html) /
  [`warning()`](https://rdrr.io/r/base/warning.html) /
  [`message()`](https://rdrr.io/r/base/message.html).
- Use `::` for one-off calls to dependencies. `@importFrom` only in
  `ggsunburstR-package.R` for `rlang` and `stats`.
- Internal functions: prefixed with `.` for truly private helpers (e.g.,
  `.resolve_values()`), unprefixed for internal-but-testable functions
  (e.g., `parse_newick()`).

## Key Design Decisions

- **Internal tree as list** (`nodes`, `children`, `parent`, `root`,
  `n_tips`) — not exported, integer-indexed node IDs. See SPEC.md §2.1.
- **`add_child()` copy semantics** — returns modified tree via
  `attr(, "tree")` workaround for R’s copy-on-modify.
- **Pre-computed coordinates + `geom_rect()`** — no custom geom/stat
  ggproto (deferred to post-MVP).
- **`fill` as string column name** — not tidy eval, for simplicity in
  MVP.

## Git Conventions

- Branch from `main` for each change: `change/<slug>`
- Commit messages: conventional commits (`feat:`, `fix:`, `test:`,
  `docs:`, `chore:`, `refactor:`)
- Never commit directly to `main` — merge from change branches after
  review.
- OpenSpec manages change lifecycle in `openspec/` directory.

## CI/CD

- **R CMD check**: `.github/workflows/R-CMD-check.yaml` — runs on macOS,
  Windows, Ubuntu (R devel/release/oldrel)
- **pkgdown**: `.github/workflows/pkgdown.yaml` — builds and deploys to
  gh-pages on push to main
- **Site**: <https://anttirask.github.io/ggsunburstR/>

## Reference Documents

- `SPEC.md` — Full architecture spec (source of truth for design
  decisions)
- `REQUIREMENTS.md` — Original requirements
- `openspec/` — Change management (archived changes in
  `openspec/changes/archive/`)
- `sunburst_data.R` — Legacy reference code (not part of the package,
  excluded via .Rbuildignore)
