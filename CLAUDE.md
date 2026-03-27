# ggsunburstR

## Project Overview

`ggsunburstR` is an R package for creating sunburst charts using
ggplot2.

This project is in early development — the package structure has not yet
been created.

## Development Setup

- This is an R package project. Use `devtools` for development
  workflows.
- Follow Tidyverse coding style and conventions.

## Common Commands

``` r
devtools::load_all()      # Load package for interactive use
devtools::test()          # Run tests
devtools::check()         # R CMD check
devtools::document()      # Generate documentation from roxygen2
pkgdown::build_site()     # Build documentation site
```

## Code Style

- Follow the [Tidyverse style guide](https://style.tidyverse.org/).
- Use roxygen2 for documentation.
- Use testthat (edition 3) for tests.
- Pipe operator: use `|>` (base R pipe).

## Git Conventions

- Branch: `main`
- Commit messages: use conventional commits (e.g., `feat:`, `fix:`,
  `docs:`, `test:`).
