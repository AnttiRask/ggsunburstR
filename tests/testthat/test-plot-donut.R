# tests/testthat/test-plot-donut.R

# Tree with 3 depth levels: root → (internal1 → (a,b,c), internal2 → (d,e))
make_sb <- function() {
  sunburst_data("((a, b, c), (d, e));")
}

# --- Returns ggplot ---

test_that("donut() returns a ggplot object", {
  sb <- make_sb()
  p <- donut(sb)
  expect_s3_class(p, "ggplot")
})

# --- Has coord_polar ---

test_that("donut() uses coord_polar", {
  sb <- make_sb()
  p <- donut(sb)
  expect_s3_class(p$coordinates, "CoordPolar")
})

# --- levels = 1 shows only deepest ring ---

test_that("donut() levels=1 shows only the deepest depth level", {
  sb <- make_sb()
  p <- donut(sb, levels = 1)
  plot_data <- p$data
  # Only leaves (depth 2) should be present — the deepest level
  max_depth <- max(sb$rects$depth)
  expect_true(all(plot_data$depth == max_depth))
})

# --- levels = 2 shows two outermost rings ---

test_that("donut() levels=2 shows two outermost depth levels", {
  sb <- make_sb()
  p <- donut(sb, levels = 2)
  plot_data <- p$data
  max_depth <- max(sb$rects$depth)
  expect_equal(sort(unique(plot_data$depth)), c(max_depth - 1, max_depth))
})

# --- Y adjustment creates hole ---

test_that("donut() creates a centre hole (all ymin > 0)", {
  sb <- make_sb()
  p <- donut(sb, levels = 1)
  plot_data <- p$data
  expect_true(all(plot_data$ymin > 0))
})

# --- hole_size controls hole ---

test_that("donut() hole_size increases the hole", {
  sb <- make_sb()
  p_small <- donut(sb, levels = 1, hole_size = 1)
  p_large <- donut(sb, levels = 1, hole_size = 5)
  min_y_small <- min(p_small$data$ymin)
  min_y_large <- min(p_large$data$ymin)
  expect_true(min_y_large > min_y_small)
})

# --- Fill mapping ---

test_that("donut() with fill maps fill aesthetic", {
  sb <- make_sb()
  p <- donut(sb, fill = "name")
  expect_no_error(ggplot2::ggplot_build(p))
})

test_that("donut() errors on non-existent fill column", {
  sb <- make_sb()
  expect_error(donut(sb, fill = "nonexistent"), class = "rlang_error")
})

# --- levels clamp ---

test_that("donut() clamps levels to tree depth", {
  sb <- make_sb()
  p <- donut(sb, levels = 100)
  plot_data <- p$data
  # Should have all nodes (same as sunburst)
  expect_equal(nrow(plot_data), nrow(sb$rects))
})

# --- show_labels ---

test_that("donut() with show_labels adds text layer", {
  sb <- make_sb()
  p_no <- donut(sb)
  p_yes <- donut(sb, show_labels = TRUE)
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- Composable ---

test_that("donut() is composable with +", {
  sb <- make_sb()
  p <- donut(sb, fill = "name") +
    ggplot2::labs(title = "Donut")
  expect_equal(p$labels$title, "Donut")
})

# --- Input validation ---

test_that("donut() errors on non-sunburst_data input", {
  expect_error(donut(data.frame(x = 1)), class = "rlang_error")
})
