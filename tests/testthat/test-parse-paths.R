# tests/testthat/test-parse-paths.R

# --- parse_paths() basic ---

test_that("parse_paths() parses basic paths", {
  tree <- parse_paths(c("A/B/C", "A/B/D", "A/E"))
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("C", "D", "E"))
  expect_equal(tree$n_tips, 3L)
})

# --- Shared prefixes ---

test_that("parse_paths() reuses shared prefix nodes", {
  tree <- parse_paths(c("A/B/C", "A/B/D"))
  a_id <- find_node_by_name(tree, "A")
  b_id <- find_node_by_name(tree, "B")
  expect_false(is.null(a_id))
  expect_false(is.null(b_id))
  # B should have 2 children: C and D
  expect_equal(length(tree$children[[b_id]]), 2)
})

# --- Custom separator ---

test_that("parse_paths() supports custom separator", {
  tree <- parse_paths(c("A.B.C", "A.B.D"), sep = ".")
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("C", "D"))
})

# --- Single path ---

test_that("parse_paths() handles single path", {
  tree <- parse_paths("A/B/C")
  expect_equal(tree$n_tips, 1L)
  leaves <- get_leaves(tree, tree$root)
  expect_equal(tree$nodes[[leaves[1]]]$name, "C")
})

# --- detect_input_type: character vector ---

test_that("detect_input_type() returns 'paths' for character vector", {
  expect_equal(detect_input_type(c("A/B/C", "A/B/D")), "paths")
})

test_that("detect_input_type() still returns 'newick' for Newick string", {
  # Single string with parens and semicolon should still be newick
 expect_equal(detect_input_type("(A, B);"), "newick")
})

# --- detect_input_type: data.frame with path column ---

test_that("detect_input_type() returns 'paths' for data.frame with path column", {
  df <- data.frame(path = c("A/B/C", "A/B/D"))
  expect_equal(detect_input_type(df), "paths")
})

test_that("detect_input_type() still returns 'dataframe' for parent/child df", {
  df <- data.frame(parent = c(NA, "root"), child = c("root", "A"))
  expect_equal(detect_input_type(df), "dataframe")
})

# --- sunburst_data() end-to-end: vector ---

test_that("sunburst_data() works with character vector of paths", {
  sb <- sunburst_data(c("A/B/C", "A/B/D", "A/E"))
  expect_s3_class(sb, "sunburst_data")
  expect_equal(sum(sb$rects$is_leaf), 3)
})

# --- sunburst_data() end-to-end: data.frame with path ---

test_that("sunburst_data() works with data.frame path column", {
  df <- data.frame(path = c("A/B/C", "A/B/D"), stringsAsFactors = FALSE)
  sb <- sunburst_data(df)
  expect_s3_class(sb, "sunburst_data")
  expect_equal(sum(sb$rects$is_leaf), 2)
})

# --- Extra columns from path data.frame ---

test_that("sunburst_data() path data.frame carries extra columns to leaves", {
  df <- data.frame(
    path   = c("A/B/C", "A/B/D"),
    colour = c("red", "blue"),
    stringsAsFactors = FALSE
  )
  sb <- sunburst_data(df)
  leaf_rects <- sb$rects[sb$rects$is_leaf, ]
  expect_true("colour" %in% names(leaf_rects))
  expect_equal(sort(leaf_rects$colour), c("blue", "red"))
})

# --- Custom separator via sunburst_data ---

test_that("sunburst_data() with paths and custom sep", {
  sb <- sunburst_data(c("A.B.C", "A.B.D"), type = "paths", sep = ".")
  expect_equal(sum(sb$rects$is_leaf), 2)
})

# --- Params stored ---

test_that("sunburst_data() with paths stores type in params", {
  sb <- sunburst_data(c("A/B", "A/C"))
  expect_equal(attr(sb, "params")$type, "paths")
})
