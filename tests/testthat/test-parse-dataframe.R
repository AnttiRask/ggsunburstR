# tests/testthat/test-parse-dataframe.R

# --- Basic parent-child ---

test_that("parse_dataframe() parses basic parent-child df", {
  df <- data.frame(
    parent = c(NA, "root", "root", "A", "A"),
    child  = c("root", "A", "B", "a1", "a2"),
    stringsAsFactors = FALSE
  )
  tree <- parse_dataframe(df)
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("B", "a1", "a2"))
  expect_equal(tree$n_tips, 3L)
})

# --- Column name: node instead of child ---

test_that("parse_dataframe() accepts 'node' column instead of 'child'", {
  df <- data.frame(
    parent = c(NA, "root", "root"),
    node   = c("root", "A", "B"),
    stringsAsFactors = FALSE
  )
  tree <- parse_dataframe(df)
  expect_equal(tree$n_tips, 2L)
})

# --- Case-insensitive column names ---

test_that("parse_dataframe() handles case-insensitive column names", {
  df <- data.frame(
    Parent = c(NA, "root", "root"),
    Child  = c("root", "A", "B"),
    stringsAsFactors = FALSE
  )
  tree <- parse_dataframe(df)
  expect_equal(tree$n_tips, 2L)
})

# --- Extra columns ---

test_that("parse_dataframe() carries extra columns as attributes", {
  df <- data.frame(
    parent = c(NA, "root", "root"),
    child  = c("root", "A", "B"),
    colour = c("grey", "red", "blue"),
    stringsAsFactors = FALSE
  )
  tree <- parse_dataframe(df)
  a_id <- find_node_by_name(tree, "A")
  b_id <- find_node_by_name(tree, "B")
  expect_equal(tree$nodes[[a_id]]$extra$colour, "red")
  expect_equal(tree$nodes[[b_id]]$extra$colour, "blue")
})

# --- NA parent (root) ---

test_that("parse_dataframe() detects root via NA parent", {
  df <- data.frame(
    parent = c(NA, "root", "root"),
    child  = c("root", "A", "B"),
    stringsAsFactors = FALSE
  )
  tree <- parse_dataframe(df)
  root_name_node <- find_node_by_name(tree, "root")
  expect_false(is.null(root_name_node))
})

# --- Empty string parent (root) ---

test_that("parse_dataframe() detects root via empty string parent", {
  df <- data.frame(
    parent = c("", "root", "root"),
    child  = c("root", "A", "B"),
    stringsAsFactors = FALSE
  )
  tree <- parse_dataframe(df)
  expect_equal(tree$n_tips, 2L)
})

# --- Missing columns error ---

test_that("parse_dataframe() errors on missing required columns", {
  df <- data.frame(name = c("A", "B"), group = c(1, 2))
  expect_error(parse_dataframe(df), "parent.*child")
})

# --- Single-node tree ---

test_that("parse_dataframe() handles single-node tree", {
  df <- data.frame(
    parent = NA,
    child  = "root",
    stringsAsFactors = FALSE
  )
  tree <- parse_dataframe(df)
  root_node <- find_node_by_name(tree, "root")
  expect_false(is.null(root_node))
})

# --- Duplicate names under different parents ---

test_that("parse_dataframe() handles duplicate names under different parents", {
  df <- data.frame(
    parent = c(NA, "root", "root", "A", "B"),
    child  = c("root", "A", "B", "leaf", "leaf"),
    stringsAsFactors = FALSE
  )
  tree <- parse_dataframe(df)
  # Should have 2 leaf nodes both named "leaf"
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("leaf", "leaf"))
  expect_equal(tree$n_tips, 2L)
})
