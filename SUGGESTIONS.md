# Reviewer Suggestions — Deferred / Not Addressed

These are all SUGGEST-level findings from code reviews during v0.1–v0.5
development that were not acted on. They are grouped by theme for easier
triage.

------------------------------------------------------------------------

## Error Messages — `abort()` doesn’t interpolate

Multiple functions use `rlang::abort("Column '{fill}' not found...")`
where the `{fill}` is a literal string, not interpolated. Switching to
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
across the package would give proper interpolation.

**Affected functions:**
[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md),
[`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md),
[`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md),
[`drilldown()`](https://anttirask.github.io/ggsunburstR/reference/drilldown.md),
[`bars()`](https://anttirask.github.io/ggsunburstR/reference/bars.md),
[`tile()`](https://anttirask.github.io/ggsunburstR/reference/tile.md),
`.validate_fill()`

**Sources:** S1 in COMMENTS-plot-donut, S2 in COMMENTS-drilldown, S1 in
COMMENTS-025-fill-auto-depth

------------------------------------------------------------------------

## Visual Regression Tests (vdiffr)

vdiffr snapshot tests were deferred throughout development. Adding them
would catch visual regressions (wrong colour, broken polar mapping,
label positioning) that structural tests miss.

**Missing snapshots:** `sunburst-default`, `sunburst-fill-depth`,
`sunburst-labels`, `icicle-default`, `icicle-fill-depth`,
`ggtree-rectangular`, `ggtree-polar`, `bars-on-icicle`, `tile-on-icicle`

**Sources:** S1 in COMMENTS-012-plot-sunburst, S1 in
COMMENTS-plot-ggtree, S2 in COMMENTS-plot-bars, S1 in COMMENTS-plot-tile

------------------------------------------------------------------------

## Code Duplication

### Newick parsing logic

`parse_newick()` and
[`nw_print()`](https://anttirask.github.io/ggsunburstR/reference/nw_print.md)
both have the same `tryCatch(withCallingHandlers(...))` pattern for
reading Newick with warning capture. A shared `.read_newick_safe()`
returning a `phylo` object would deduplicate.

**Source:** S1 in COMMENTS-nw-print

### Fill/validation logic in plot functions

[`sunburst()`](https://anttirask.github.io/ggsunburstR/reference/sunburst.md),
[`icicle()`](https://anttirask.github.io/ggsunburstR/reference/icicle.md),
and
[`donut()`](https://anttirask.github.io/ggsunburstR/reference/donut.md)
share identical input validation and fill branching. This was partially
addressed in v0.5 with shared helpers (`.resolve_fill()`,
`.validate_fill()`, `.build_rect_layer()`). Review whether further
extraction is needed.

**Source:** S1 in COMMENTS-013-plot-icicle

------------------------------------------------------------------------

## Performance

### Recursive postorder traversal

`descendants_postorder()` is recursive and could hit R’s stack limit on
trees deeper than ~2500 levels. Convert to iterative with explicit stack
if large trees are a use case.

**Source:** S1 in COMMENTS-002-tree-internals

### `get_leaves()` called per node in label computation

`compute_label_positions()` calls `get_leaves(tree, nid)` for every
node. Pre-computing a `leaf_size_sum` map in a single postorder pass
would be more efficient for large trees.

**Source:** S2 in COMMENTS-009-compute-labels

### Depth computation via while-loop

`.build_output()` computes depth per node by walking up to root (O(n \*
depth)). A single postorder pass pre-computing depth would be O(n).

**Source:** S3 in COMMENTS-011-sunburst-data

------------------------------------------------------------------------

## Missing Edge-Case Tests

### All-zero values guard

If all leaf values are 0, `compute_coordinates()` divides by zero when
computing angular fractions. Either validate in `assign_sizes()` or
handle in `compute_coordinates()`.

**Source:** S1 in COMMENTS-007-compute-sizes

### Single-leaf tree for bars/tile

No tests for
[`bars()`](https://anttirask.github.io/ggsunburstR/reference/bars.md) or
[`tile()`](https://anttirask.github.io/ggsunburstR/reference/tile.md) on
a single-leaf tree.

**Sources:** S1 in COMMENTS-plot-bars, S2 in COMMENTS-plot-tile

### Empty/malformed paths

No tests for empty strings, paths with only separators, or trailing
separators in `parse_paths()`.

**Source:** S1 in COMMENTS-parse-paths

### Duplicate full paths

If two paths are identical (`c("A/B/C", "A/B/C")`) with no extras, the
leaf is reused (count = 1). With extras, a duplicate leaf is created.
Behaviour should be documented with a test.

**Source:** S2 in COMMENTS-parse-paths

### Non-scalar data.tree fields

No test confirming that non-scalar fields (vectors, lists) on
[`data.tree::Node`](https://rdrr.io/pkg/data.tree/man/Node.html) objects
are silently excluded.

**Source:** S1 in COMMENTS-parse-datatree

### Deep tree (20 levels)

SPEC.md task calls for a deep tree test that was never added.

**Source:** S1 in COMMENTS-008-compute-coords

### `xlim < 360` (partial sunburst) for labels

No test verifies label angles scale correctly for partial sunbursts.

**Source:** S1 in COMMENTS-009-compute-labels

### Tibble input

No test confirms
[`sunburst_data()`](https://anttirask.github.io/ggsunburstR/reference/sunburst_data.md)
works with tibble input (as opposed to plain data.frame). Should work
via inheritance but worth documenting.

**Sources:** S1 in COMMENTS-005-parse-dataframe, S1 in
COMMENTS-006-detect-input

### Duplicate tip labels

The example tree has duplicate “f” labels. `find_node_by_name()` returns
the first match — this is a known limitation but no test documents it.

**Source:** S1 in COMMENTS-003-parse-newick

------------------------------------------------------------------------

## Documentation

### Lineage format missing from README

The lineage TSV format has no code example in README or vignette.

**Source:** S1 in COMMENTS-014-documentation-and-ci

### `@seealso` cross-references

Some functions lack `@seealso` links to related functions.

**Source:** S2 in COMMENTS-012-plot-sunburst

### `ggtree()` mode documentation

A `@details` section explaining the three modes (vertical, horizontal,
circular) would help users.

**Source:** S3 in COMMENTS-plot-ggtree

### Deprecation plan for `fill = NULL`

SPEC.md mentions `fill = NULL` may change to mean `"auto"` in v0.6+. The
roxygen2 docs don’t mention this. A note would help users write
forward-compatible code.

**Source:** S3 in COMMENTS-025-fill-auto-depth

### Bare name fill example in roxygen2

The examples show `fill = "depth"` but not the bare name form
`fill = depth`.

**Source:** S2 in COMMENTS-026-fill-tidy-eval

### `icicle()` example with `label_repel = TRUE`

No runnable example in roxygen2 for this feature.

**Source:** S2 in COMMENTS-021-label-repel

------------------------------------------------------------------------

## Minor Style / Design

### `hjust_ptext()` and `vjust_rtext()` always return 0.5

These exist for API consistency (all justification functions take
`angle`). Could be constants instead. Current approach is fine.

**Source:** S2 in COMMENTS-002-tree-internals

### `rangle(270)` boundary behaviour

Floating-point ambiguity at cos(270°) ≈ 0. Test uses loose assertion.
Could pin to one expected value by deciding on `< 0` vs `<= 0`.

**Source:** S3 in COMMENTS-002-tree-internals

### `drilldown_from` stores mixed types

When called by name, stores a string. When called by ID, stores an
integer. Consider normalising.

**Source:** S4 in COMMENTS-drilldown

### `drilldown.R` line 35 has 1-space indent

Should be 2-space per tidyverse style.

**Source:** S1 in COMMENTS-drilldown

### `parse_lineage()` attribute-on-shared-prefix creates duplicates

If a shared-prefix node has attributes on one line but not another, the
node is duplicated. Faithful to original behaviour but may surprise
users.

**Source:** S1 in COMMENTS-004-parse-file-inputs

### `parse_node_parent()` error uses cli glue in `abort()`

Works due to rlang-cli integration, but
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
would be clearer.

**Source:** S2 in COMMENTS-004-parse-file-inputs

### `print.sunburst_data()` output content not tested

Test verifies no error but not that output contains expected text.

**Source:** S2 in COMMENTS-010-sunburst-class

### Test helper mock rects may diverge from real pipeline

The `make_test_sb()` helper has a `depth` column that’s added during
assembly, not by `compute_coordinates()`.

**Source:** S1 in COMMENTS-010-sunburst-class

### CRAN misspelled words NOTE

“Newick”, “ggplot”, “reimplementation”, “reticulate” flagged. All
legitimate domain terms.

**Source:** S3 in COMMENTS-001-package-scaffold

### `ape` installation check is moot

Since `ape` is in Imports, R enforces its presence at package load time.
The SPEC.md requirement is self-fulfilling.

**Source:** S2 in COMMENTS-003-parse-newick

### `fill = "auto"` equivalence test

Test checks values vary but doesn’t verify exact equivalence with
`fill = "depth"`.

**Source:** S2 in COMMENTS-025-fill-auto-depth

### Invalid fill expression error path untested

`.resolve_fill()` has an error for non-NULL/non-symbol/non-string but no
test exercises it.

**Source:** S1 in COMMENTS-026-fill-tidy-eval
