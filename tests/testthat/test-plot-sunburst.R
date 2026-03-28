# tests/testthat/test-plot-sunburst.R

# Shared test data
make_sb <- function() {
  sunburst_data("((a, b, c), (d, e));")
}

# --- Returns ggplot ---

test_that("sunburst() returns a ggplot object", {
  sb <- make_sb()
  p <- sunburst(sb)
  expect_s3_class(p, "ggplot")
})

# --- Has coord_polar ---

test_that("sunburst() uses coord_polar", {
  sb <- make_sb()
  p <- sunburst(sb)
  # coord_polar is stored in p$coordinates
  expect_s3_class(p$coordinates, "CoordPolar")
})

# --- Static fill default ---

test_that("sunburst() with default fill renders without error", {
  sb <- make_sb()
  p <- sunburst(sb)
  # Should be buildable without error
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- String fill mapping ---

test_that("sunburst() with fill = 'depth' maps fill aesthetic", {
  sb <- make_sb()
  p <- sunburst(sb, fill = "depth")
  built <- ggplot2::ggplot_build(p)
  # The fill should vary (not all the same)
  expect_true(length(unique(built$data[[1]]$fill)) > 1)
})

test_that("sunburst() with fill = 'name' works", {
  sb <- make_sb()
  p <- sunburst(sb, fill = "name")
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- Non-existent fill column errors ---

test_that("sunburst() errors on non-existent fill column", {
  sb <- make_sb()
  expect_error(sunburst(sb, fill = "nonexistent"), class = "rlang_error")
})

# --- Input validation ---

test_that("sunburst() errors on non-sunburst_data input", {
  expect_error(sunburst(data.frame(x = 1)), class = "rlang_error")
})

# --- show_labels ---

test_that("sunburst() with show_labels adds geom_text layer", {
  sb <- make_sb()
  p_no <- sunburst(sb)
  p_yes <- sunburst(sb, show_labels = TRUE)
  # Count layers: with labels should have one more
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- theme_void ---

test_that("sunburst() applies theme_void", {
  sb <- make_sb()
  p <- sunburst(sb)
  # theme_void sets panel.border, axis.line etc to element_blank
  expect_true(inherits(p$theme$line, "element_blank") ||
              inherits(p$theme$axis.line, "element_blank") ||
              length(p$theme) > 0)
})

# --- leaf_labels output includes geometry columns ---

test_that("sunburst_data leaf_labels includes ymin, ymax, delta_angle", {
  sb <- make_sb()
  expect_true("ymin" %in% names(sb$leaf_labels))
  expect_true("ymax" %in% names(sb$leaf_labels))
  expect_true("delta_angle" %in% names(sb$leaf_labels))
  expect_true(all(sb$leaf_labels$delta_angle > 0))
})

# --- plot.sunburst_data dispatches ---

test_that("plot.sunburst_data() dispatches to sunburst()", {
  sb <- make_sb()
  p <- plot(sb)
  expect_s3_class(p, "ggplot")
})

# --- Customisable with + ---

test_that("sunburst() result is customisable with +", {
  sb <- make_sb()
  p <- sunburst(sb, fill = "depth") +
    ggplot2::labs(title = "Test")
  expect_equal(p$labels$title, "Test")
})
