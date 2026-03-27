# tests/testthat/test-highlight-nodes.R

make_plot <- function() {
  sb <- sunburst_data("((a, b, c), (d, e));")
  sunburst(sb, fill = "depth")
}

# --- Adds a layer ---

test_that("highlight_nodes() adds one layer to the plot", {
  p <- make_plot()
  n_before <- length(p$layers)
  p2 <- highlight_nodes(p, nodes = c("a", "c"))
  expect_equal(length(p2$layers), n_before + 1)
})

# --- Returns ggplot ---

test_that("highlight_nodes() returns a ggplot object", {
  p <- make_plot()
  p2 <- highlight_nodes(p, nodes = "a")
  expect_s3_class(p2, "ggplot")
})

# --- Correct filtering by name ---

test_that("highlight_nodes() filters to matching node names", {
  p <- make_plot()
  p2 <- highlight_nodes(p, nodes = "a")
  # The highlight layer's data should have 1 row
  highlight_data <- p2$layers[[length(p2$layers)]]$data
  expect_equal(nrow(highlight_data), 1)
  expect_equal(highlight_data$name, "a")
})

test_that("highlight_nodes() highlights multiple nodes", {
  p <- make_plot()
  p2 <- highlight_nodes(p, nodes = c("a", "b", "c"))
  highlight_data <- p2$layers[[length(p2$layers)]]$data
  expect_equal(nrow(highlight_data), 3)
})

# --- Highlight by node_id ---

test_that("highlight_nodes() accepts integer node_ids", {
  sb <- sunburst_data("(a, b, c);")
  p <- sunburst(sb)
  # Get the actual node_ids
  ids <- sb$rects$node_id[1:2]
  p2 <- highlight_nodes(p, nodes = ids)
  highlight_data <- p2$layers[[length(p2$layers)]]$data
  expect_equal(nrow(highlight_data), 2)
})

# --- Composable ---

test_that("highlight_nodes() result is composable with +", {
  p <- make_plot()
  p2 <- highlight_nodes(p, nodes = "a") +
    ggplot2::labs(title = "highlighted")
  expect_equal(p2$labels$title, "highlighted")
})

# --- No match warns ---

test_that("highlight_nodes() warns when no nodes match", {
  p <- make_plot()
  expect_warning(highlight_nodes(p, nodes = "nonexistent"), "No matching")
})

# --- Custom aesthetics ---

test_that("highlight_nodes() uses custom fill and colour", {
  p <- make_plot()
  p2 <- highlight_nodes(p, nodes = "a", fill = "red", colour = "blue")
  # Should build without error
  expect_no_error(ggplot2::ggplot_build(p2))
})

# --- Works with icicle ---

test_that("highlight_nodes() works with icicle plots", {
  sb <- sunburst_data("((a, b), c);")
  p <- icicle(sb)
  p2 <- highlight_nodes(p, nodes = "a")
  expect_equal(length(p2$layers), length(p$layers) + 1)
})
