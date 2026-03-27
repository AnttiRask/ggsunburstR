# tests/testthat/test-parse-phylo.R

# --- detect_input_type ---

test_that("detect_input_type() returns 'phylo' for phylo objects", {
  phylo <- ape::read.tree(text = "(A, B, C);")
  expect_equal(detect_input_type(phylo), "phylo")
})

# --- End-to-end ---

test_that("sunburst_data() works end-to-end with phylo input", {
  phylo <- ape::read.tree(text = "(A, B, C);")
  sb <- sunburst_data(phylo)
  expect_s3_class(sb, "sunburst_data")
  expect_equal(nrow(sb$rects), 3)
  expect_true(all(sb$rects$is_leaf))
})

test_that("sunburst_data() with phylo and explicit type = 'phylo'", {
  phylo <- ape::read.tree(text = "((A, B), C);")
  sb <- sunburst_data(phylo, type = "phylo")
  expect_s3_class(sb, "sunburst_data")
  expect_equal(sum(sb$rects$is_leaf), 3)
})

# --- Branch lengths preserved ---

test_that("phylo input preserves branch lengths", {
  phylo <- ape::read.tree(text = "((A:0.1, B:0.2):0.3, C:0.5);")
  sb <- sunburst_data(phylo)
  rects <- sb$rects
  # C has dist=0.5, so its band should be taller than A's (dist=0.1)
  c_row <- rects[!is.na(rects$name) & rects$name == "C", ]
  a_row <- rects[!is.na(rects$name) & rects$name == "A", ]
  c_height <- abs(c_row$ymax[1] - c_row$ymin[1])
  a_height <- abs(a_row$ymax[1] - a_row$ymin[1])
  expect_equal(c_height / a_height, 5.0)  # 0.5 / 0.1
})

# --- Node labels preserved ---

test_that("phylo input preserves internal node labels", {
  phylo <- ape::read.tree(text = "((A, B)X, C)root;")
  sb <- sunburst_data(phylo)
  # X should appear as a named internal node (root is excluded from output)
  expect_true("X" %in% sb$rects$name)
  expect_true("X" %in% sb$node_labels$label)
})

# --- Values work with phylo ---

test_that("sunburst_data() with phylo and values parameter", {
  phylo <- ape::read.tree(text = "(a, b, c);")
  sb <- sunburst_data(phylo, values = c(a = 3, b = 1, c = 2))
  rects <- sb$rects
  a_width <- rects[rects$name == "a", "xmax"] - rects[rects$name == "a", "xmin"]
  b_width <- rects[rects$name == "b", "xmax"] - rects[rects$name == "b", "xmin"]
  expect_equal(a_width / b_width, 3.0)
})

# --- Params stored correctly ---

test_that("sunburst_data() with phylo stores type = 'phylo' in params", {
  phylo <- ape::read.tree(text = "(A, B);")
  sb <- sunburst_data(phylo)
  expect_equal(attr(sb, "params")$type, "phylo")
})
