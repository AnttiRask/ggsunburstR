# tests/testthat/test-plot-tile.R

make_sb_with_vars <- function() {
  df <- data.frame(
    parent = c(NA, "root", "root", "A", "A"),
    child  = c("root", "A", "B", "a1", "a2"),
    score  = c(NA, NA, 0.8, 0.5, 0.9),
    group  = c(NA, NA, "x", "y", "x"),
    stringsAsFactors = FALSE
  )
  sunburst_data(df)
}

# --- Adds layer ---

test_that("tile() adds a layer to existing plot", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  n_before <- length(p$layers)
  p2 <- tile(p, sb, variables = "score")
  expect_true(length(p2$layers) > n_before)
})

# --- Returns ggplot ---

test_that("tile() returns a ggplot object", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p2 <- tile(p, sb, variables = "score")
  expect_s3_class(p2, "ggplot")
})

# --- Numeric variable ---

test_that("tile() works with numeric variable", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p2 <- tile(p, sb, variables = "score")
  expect_no_error(ggplot2::ggplot_build(p2))
})

# --- Categorical variable ---

test_that("tile() works with categorical variable", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p2 <- tile(p, sb, variables = "group")
  expect_no_error(ggplot2::ggplot_build(p2))
})

# --- Multiple variables ---

test_that("tile() works with multiple variables (warns on mixed types)", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  expect_warning(
    p2 <- tile(p, sb, variables = c("score", "group")),
    "coercing"
  )
  expect_no_error(ggplot2::ggplot_build(p2))
})

# --- Non-existent variable errors ---

test_that("tile() errors on non-existent variable", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  expect_error(tile(p, sb, variables = "nonexistent"), class = "rlang_error")
})

# --- show_labels ---

test_that("tile() with show_labels adds text layer", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p_no <- tile(p, sb, variables = "score", show_labels = FALSE)
  p_yes <- tile(p, sb, variables = "score", show_labels = TRUE)
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- Composable ---

test_that("tile() is composable with +", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p2 <- tile(p, sb, variables = "score") +
    ggplot2::labs(title = "With tiles")
  expect_equal(p2$labels$title, "With tiles")
})

# --- Input validation ---

test_that("tile() validates p is ggplot", {
  sb <- make_sb_with_vars()
  expect_error(tile("not a plot", sb, "score"), class = "rlang_error")
})

test_that("tile() validates sb is sunburst_data", {
  expect_error(tile(ggplot2::ggplot(), data.frame(x = 1), "x"),
               class = "rlang_error")
})

# --- Works with sunburst ---

test_that("tile() works with sunburst plot", {
  sb <- make_sb_with_vars()
  p <- sunburst(sb)
  p2 <- tile(p, sb, variables = "score")
  expect_no_error(ggplot2::ggplot_build(p2))
})

# --- Single-leaf tree ---

test_that("tile() works with single-leaf tree", {
  df <- data.frame(parent = c(NA, "root"), child = c("root", "A"), val = c(NA, 5))
  sb <- sunburst_data(df)
  p <- icicle(sb)
  expect_no_error(tile(p, sb, variables = "val"))
})
