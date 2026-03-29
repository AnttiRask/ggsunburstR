# tests/testthat/test-sunburst-class.R

# Helper: create a minimal sunburst_data object for testing
make_test_sb <- function() {
  rects <- data.frame(
    node_id = 1:3,
    name = c("a", "b", "c"),
    depth = c(1L, 1L, 1L),
    is_leaf = c(TRUE, TRUE, TRUE),
    xmin = c(0.5, 1.5, 2.5),
    xmax = c(1.5, 2.5, 3.5),
    ymin = c(-1, -1, -1),
    ymax = c(0, 0, 0),
    x = c(1, 2, 3),
    stringsAsFactors = FALSE
  )
  leaf_labels <- data.frame(
    node_id = 1:3, label = c("a", "b", "c"),
    x = c(1, 2, 3), y = c(0, 0, 0),
    angle = c(30, -30, -90), hjust = c(0, 0, 1),
    stringsAsFactors = FALSE
  )
  node_labels <- data.frame(
    node_id = integer(0), label = character(0),
    stringsAsFactors = FALSE
  )
  segments <- data.frame(rx = numeric(0), stringsAsFactors = FALSE)
  tree <- new_tree()
  params <- list(xlim = 360, rot = 0)

  new_sunburst_data(rects, leaf_labels, node_labels, segments, tree, params)
}

# --- Constructor ---

test_that("new_sunburst_data() returns correct class", {
  sb <- make_test_sb()
  expect_s3_class(sb, "sunburst_data")
  expect_true(inherits(sb, "sunburst_data"))
})

test_that("new_sunburst_data() stores all components", {
  sb <- make_test_sb()
  expect_true(!is.null(sb$rects))
  expect_true(!is.null(sb$leaf_labels))
  expect_true(!is.null(sb$node_labels))
  expect_true(!is.null(sb$segments))
  expect_true(!is.null(sb$tree))
})

# --- $data alias ---

test_that("$data is an alias for $rects", {
  sb <- make_test_sb()
  expect_identical(sb$data, sb$rects)
})

test_that("$data and $rects return the same object", {
  sb <- make_test_sb()
  expect_equal(nrow(sb$data), 3)
  expect_equal(nrow(sb$rects), 3)
})

# --- print ---

test_that("print.sunburst_data() runs without error", {
  sb <- make_test_sb()
  # cli output may go to message stream; just ensure no error
  expect_no_error(capture.output(print(sb), type = "message"))
})

test_that("print.sunburst_data() returns invisible(x)", {
  sb <- make_test_sb()
  result <- withVisible(print(sb))
  expect_false(result$visible)
  expect_s3_class(result$value, "sunburst_data")
})

# --- as.data.frame ---

test_that("as.data.frame.sunburst_data() returns $rects", {
  sb <- make_test_sb()
  df <- as.data.frame(sb)
  expect_identical(df, sb$rects)
})

# --- plot stub ---

test_that("plot.sunburst_data() exists as a method", {
  sb <- make_test_sb()
  expect_true(is.function(getS3method("plot", "sunburst_data",
                                       optional = TRUE)))
})

# --- print output content ---

test_that("print.sunburst_data() output contains expected content", {
  sb <- make_test_sb()
  out <- capture.output(print(sb), type = "message")
  out_text <- paste(out, collapse = " ")
  expect_true(grepl("3 nodes", out_text) || grepl("3 node", out_text))
  expect_true(grepl("3 lea", out_text))
})
