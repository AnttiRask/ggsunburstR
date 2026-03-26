# tests/testthat/test-plot-icicle.R

make_sb <- function() {
  sunburst_data("((a, b, c), (d, e));")
}

# --- Returns ggplot ---

test_that("icicle() returns a ggplot object", {
  sb <- make_sb()
  p <- icicle(sb)
  expect_s3_class(p, "ggplot")
})

# --- Has scale_y_reverse ---

test_that("icicle() uses scale_y_reverse", {
  sb <- make_sb()
  p <- icicle(sb)
  # scale_y_reverse appears in the y scales
  scales <- p$scales$scales
  has_y_reverse <- any(vapply(scales, function(s) {
    inherits(s, "ScaleContinuousPosition") && s$aesthetics[1] == "y"
  }, logical(1)))
  # Also check via ggplot_build — y axis should be reversed
  built <- ggplot2::ggplot_build(p)
  expect_true(built$layout$panel_scales_y[[1]]$trans$name == "reverse")
})

# --- Static fill default ---

test_that("icicle() with default fill renders without error", {
  sb <- make_sb()
  p <- icicle(sb)
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- String fill mapping ---

test_that("icicle() with fill = 'depth' maps fill aesthetic", {
  sb <- make_sb()
  p <- icicle(sb, fill = "depth")
  built <- ggplot2::ggplot_build(p)
  expect_true(length(unique(built$data[[1]]$fill)) > 1)
})

# --- Non-existent fill column errors ---

test_that("icicle() errors on non-existent fill column", {
  sb <- make_sb()
  expect_error(icicle(sb, fill = "nonexistent"), class = "rlang_error")
})

# --- Input validation ---

test_that("icicle() errors on non-sunburst_data input", {
  expect_error(icicle(data.frame(x = 1)), class = "rlang_error")
})

# --- show_labels ---

test_that("icicle() with show_labels adds geom_text layer", {
  sb <- make_sb()
  p_no <- icicle(sb)
  p_yes <- icicle(sb, show_labels = TRUE)
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- Customisable with + ---

test_that("icicle() result is customisable with +", {
  sb <- make_sb()
  p <- icicle(sb, fill = "depth") +
    ggplot2::labs(title = "Test Icicle")
  expect_equal(p$labels$title, "Test Icicle")
})
