# tests/testthat/test-geom-sunburst.R

# Standard test data: 7 nodes (1 root + 2 internal + 4 leaves)
make_df <- function() {
  data.frame(
    parent = c(NA, "root", "root", "A", "A", "B", "B"),
    child  = c("root", "A", "B", "a1", "a2", "b1", "b2"),
    group  = c("r", "g1", "g2", "g1", "g1", "g2", "g2"),
    value  = c(NA, NA, NA, 10, 5, 8, 2),
    stringsAsFactors = FALSE
  )
}

# --- Basic plot builds ---

test_that("geom_sunburst() builds a valid ggplot", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent))
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- Correct number of rectangles ---

test_that("geom_sunburst() outputs one rect per non-root node", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent))
  built <- ggplot2::ggplot_build(p)
  # parse_dataframe creates an implicit root above the user's "root" row,
  # so 7 user nodes are all rendered (implicit root excluded)
  expect_equal(nrow(built$data[[1]]), 7)
})

# --- Fill mapping ---

test_that("geom_sunburst() supports fill aesthetic", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent, fill = group))
  built <- ggplot2::ggplot_build(p)
  expect_true(length(unique(built$data[[1]]$fill)) > 1)
})

# --- Value-weighted sizing ---

test_that("geom_sunburst() supports values parameter for weighted sizing", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent),
                  values = "value")
  built <- ggplot2::ggplot_build(p)
  rects <- built$data[[1]]
  # Leaves should have different widths (xmax - xmin) proportional to values
  leaf_widths <- rects$xmax - rects$xmin
  expect_true(length(unique(round(leaf_widths, 6))) > 1)
})

# --- coord_polar composability ---

test_that("geom_sunburst() + coord_polar() produces sunburst", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent)) +
    ggplot2::coord_polar()
  expect_true(inherits(p$coordinates, "CoordPolar"))
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("geom_sunburst() without coord_polar is Cartesian", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent))
  expect_true(inherits(p$coordinates, "CoordCartesian"))
})

# --- Missing aesthetics ---

test_that("geom_sunburst() errors on missing required aesthetics", {
  df <- make_df()
  # Missing id
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(parent = parent))
  expect_error(ggplot2::ggplot_build(p))
})

# --- Extra columns usable for fill ---

test_that("geom_sunburst() can map any extra column to fill", {
  df <- make_df()
  # Map 'value' (a numeric extra column) to fill — proves extra columns
  # are preserved through the stat for aesthetic mapping
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent, fill = value))
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- branchvalues parameter ---

test_that("geom_sunburst() supports branchvalues parameter", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent),
                  branchvalues = "total")
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- leaf_mode parameter ---

test_that("geom_sunburst() supports leaf_mode = 'extended'", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent),
                  leaf_mode = "extended")
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- Invalid values column warns ---

test_that(".resolve_stat_values() warns on nonexistent column", {
  # Test the internal helper directly — warnings inside ggproto compute_panel
  # are suppressed by ggplot2's tryCatch
  tree_df <- data.frame(parent = c(NA, "root"), child = c("root", "A"))
  tree <- parse_dataframe(tree_df)
  expect_warning(
    ggsunburstR:::.resolve_stat_values("nonexistent", tree_df, tree),
    "not found"
  )
})

# --- Full idiomatic composition ---

test_that("geom_sunburst() composes with coord_polar + theme_void", {
  df <- make_df()
  p <- ggplot2::ggplot(df) +
    geom_sunburst(ggplot2::aes(id = child, parent = parent, fill = group)) +
    ggplot2::coord_polar() +
    ggplot2::theme_void()
  expect_no_error(ggplot2::ggplot_build(p))
})
