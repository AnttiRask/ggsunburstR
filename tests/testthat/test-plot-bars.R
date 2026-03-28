# tests/testthat/test-plot-bars.R

make_sb_with_vars <- function() {
  df <- data.frame(
    parent = c(NA, "root", "root", "A", "A"),
    child  = c("root", "A", "B", "a1", "a2"),
    score  = c(NA, NA, 0.8, 0.5, 0.9),
    weight = c(NA, NA, 0.3, 0.7, 0.4),
    stringsAsFactors = FALSE
  )
  sunburst_data(df)
}

# --- Adds layers ---

test_that("bars() adds layers to existing plot", {
  sb <- make_sb_with_vars()
  p <- icicle(sb, fill = "depth")
  n_before <- length(p$layers)
  p2 <- bars(p, sb, variables = "score")
  expect_true(length(p2$layers) > n_before)
})

# --- Returns ggplot ---

test_that("bars() returns a ggplot object", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p2 <- bars(p, sb, variables = "score")
  expect_s3_class(p2, "ggplot")
})

# --- Multiple variables ---

test_that("bars() works with multiple variables", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p2 <- bars(p, sb, variables = c("score", "weight"))
  expect_no_error(ggplot2::ggplot_build(p2))
})

# --- Non-existent variable errors ---

test_that("bars() errors on non-existent variable", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  expect_error(bars(p, sb, variables = "nonexistent"), class = "rlang_error")
})

# --- Non-numeric variable errors ---

test_that("bars() errors on non-numeric variable", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  expect_error(bars(p, sb, variables = "name"), class = "rlang_error")
})

# --- NA handling ---

test_that("bars() treats NA values as zero", {
  df <- data.frame(
    parent = c(NA, "root", "root"),
    child  = c("root", "A", "B"),
    val    = c(NA, NA, 10),
    stringsAsFactors = FALSE
  )
  sb <- sunburst_data(df)
  p <- icicle(sb)
  # A has NA val -> bar should have zero height. Should not error.
  expect_no_error(bars(p, sb, variables = "val"))
})

# --- All-zero variable ---

test_that("bars() handles all-zero variable without error", {
  df <- data.frame(
    parent = c(NA, "root", "root"),
    child  = c("root", "A", "B"),
    val    = c(NA, 0, 0),
    stringsAsFactors = FALSE
  )
  sb <- sunburst_data(df)
  p <- icicle(sb)
  expect_no_error(bars(p, sb, variables = "val"))
})

# --- show_labels ---

test_that("bars() with show_labels adds text layer", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p_no <- bars(p, sb, variables = "score", show_labels = FALSE)
  p_yes <- bars(p, sb, variables = "score", show_labels = TRUE)
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- show_values ---

test_that("bars() with show_values adds text layer", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p_no <- bars(p, sb, variables = "score", show_values = FALSE)
  p_yes <- bars(p, sb, variables = "score", show_values = TRUE)
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- Works with sunburst ---

test_that("bars() works with sunburst plot", {
  sb <- make_sb_with_vars()
  p <- sunburst(sb)
  p2 <- bars(p, sb, variables = "score")
  expect_no_error(ggplot2::ggplot_build(p2))
})

# --- Composable ---

test_that("bars() result is composable with +", {
  sb <- make_sb_with_vars()
  p <- icicle(sb)
  p2 <- bars(p, sb, variables = "score") +
    ggplot2::labs(title = "With bars")
  expect_equal(p2$labels$title, "With bars")
})

# --- Input validation ---

test_that("bars() validates p is ggplot", {
  sb <- make_sb_with_vars()
  expect_error(bars("not a plot", sb, "score"), class = "rlang_error")
})

test_that("bars() validates sb is sunburst_data", {
  expect_error(bars(ggplot2::ggplot(), data.frame(x = 1), "x"),
               class = "rlang_error")
})
