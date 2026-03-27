# tests/testthat/test-plot-ggtree.R

make_sb <- function() {
  sunburst_data("((a, b, c), (d, e));")
}

# --- Returns ggplot ---

test_that("ggtree() returns a ggplot object", {
  sb <- make_sb()
  p <- ggtree(sb)
  expect_s3_class(p, "ggplot")
})

# --- Has segment layers ---

test_that("ggtree() has geom_segment layers", {
  sb <- make_sb()
  p <- ggtree(sb, show_labels = FALSE)
  # Should have at least 2 layers (horizontal + vertical segments)
  expect_true(length(p$layers) >= 2)
})

# --- rotate = TRUE uses coord_flip ---

test_that("ggtree() with rotate = TRUE uses coord_flip", {
  sb <- make_sb()
  p <- ggtree(sb, rotate = TRUE, polar = FALSE)
  expect_s3_class(p$coordinates, "CoordFlip")
})

# --- rotate = FALSE no coord_flip ---

test_that("ggtree() with rotate = FALSE has Cartesian coords", {
  sb <- make_sb()
  p <- ggtree(sb, rotate = FALSE, polar = FALSE)
  expect_s3_class(p$coordinates, "CoordCartesian")
})

# --- polar = TRUE uses coord_polar ---

test_that("ggtree() with polar = TRUE uses coord_polar", {
  sb <- make_sb()
  p <- ggtree(sb, polar = TRUE)
  expect_s3_class(p$coordinates, "CoordPolar")
})

# --- show_labels = TRUE adds text layer ---

test_that("ggtree() with show_labels adds text layer", {
  sb <- make_sb()
  p_no <- ggtree(sb, show_labels = FALSE)
  p_yes <- ggtree(sb, show_labels = TRUE)
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- show_labels = TRUE default ---

test_that("ggtree() shows labels by default", {
  sb <- make_sb()
  p <- ggtree(sb)
  # Default show_labels = TRUE, so more layers than without
  p_no <- ggtree(sb, show_labels = FALSE)
  expect_true(length(p$layers) > length(p_no$layers))
})

# --- blank = TRUE uses theme_void ---

test_that("ggtree() with blank = TRUE applies theme_void", {
  sb <- make_sb()
  p <- ggtree(sb, blank = TRUE)
  # theme_void sets various elements to element_blank
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- polar with labels renders ---

test_that("ggtree() polar with labels renders without error", {
  sb <- make_sb()
  p <- ggtree(sb, polar = TRUE, show_labels = TRUE)
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- Composable ---

test_that("ggtree() is composable with +", {
  sb <- make_sb()
  p <- ggtree(sb) +
    ggplot2::labs(title = "Tree")
  expect_equal(p$labels$title, "Tree")
})

# --- Input validation ---

test_that("ggtree() errors on non-sunburst_data input", {
  expect_error(ggtree(data.frame(x = 1)), class = "rlang_error")
})

# --- Branch lengths reflected ---

test_that("ggtree() with branch lengths produces different segment lengths", {
  sb <- sunburst_data("((a:1, b:3):1, c:2);")
  p <- ggtree(sb, show_labels = FALSE, rotate = FALSE)
  built <- ggplot2::ggplot_build(p)
  # Vertical segments should have different lengths
  seg_data <- built$data[[2]]  # vertical segments layer
  lengths <- abs(seg_data$yend - seg_data$y)
  expect_true(length(unique(round(lengths, 2))) > 1)
})
