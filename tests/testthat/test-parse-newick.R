# tests/testthat/test-parse-newick.R

# --- Simple tree ---

test_that("parse_newick() parses simple tree with 3 leaves", {
  tree <- parse_newick("(A, B, C);")
  expect_type(tree, "list")
  expect_equal(tree$n_tips, 3L)
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("A", "B", "C"))
})

test_that("parse_newick() sets root parent to NA and root dist to 0", {
  tree <- parse_newick("(A, B, C);")
  expect_true(is.na(tree$parent[tree$root]))
  expect_equal(tree$nodes[[tree$root]]$dist, 0.0)
})

# --- Nested tree ---

test_that("parse_newick() parses nested tree correctly", {
  tree <- parse_newick("((A, B), (C, D));")
  expect_equal(tree$n_tips, 4L)
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("A", "B", "C", "D"))
  # Root should have 2 children (both internal)
  root_kids <- tree$children[[tree$root]]
  expect_equal(length(root_kids), 2)
})

# --- Branch lengths ---

test_that("parse_newick() preserves branch lengths", {
  tree <- parse_newick("((A:0.1, B:0.2):0.3, C:0.5);")
  # Find nodes by name
  a_id <- find_node_by_name(tree, "A")
  b_id <- find_node_by_name(tree, "B")
  c_id <- find_node_by_name(tree, "C")

  expect_equal(tree$nodes[[a_id]]$dist, 0.1)
  expect_equal(tree$nodes[[b_id]]$dist, 0.2)
  expect_equal(tree$nodes[[c_id]]$dist, 0.5)

  # Internal node (parent of A and B)
  internal_id <- tree$parent[a_id]
  expect_equal(tree$nodes[[internal_id]]$dist, 0.3)
})

test_that("parse_newick() defaults dist to 1.0 when no branch lengths", {
  tree <- parse_newick("(A, B, C);")
  a_id <- find_node_by_name(tree, "A")
  expect_equal(tree$nodes[[a_id]]$dist, 1.0)
})

# --- Internal node labels ---

test_that("parse_newick() preserves internal node labels", {
  tree <- parse_newick("((A, B)X, (C, D)Y)root;")
  x_id <- find_node_by_name(tree, "X")
  y_id <- find_node_by_name(tree, "Y")
  root_id <- find_node_by_name(tree, "root")

  expect_false(is.null(x_id))
  expect_false(is.null(y_id))
  expect_false(is.null(root_id))
  expect_equal(root_id, tree$root)
})

test_that("parse_newick() auto-names unnamed internal nodes", {
  tree <- parse_newick("((A, B), C);")
  # The internal node parent of A,B should be "NoName{id}"
  a_id <- find_node_by_name(tree, "A")
  internal_id <- tree$parent[a_id]
  expect_true(grepl("^NoName", tree$nodes[[internal_id]]$name))
})

# --- File input ---

test_that("parse_newick() reads from file", {
  tmp <- tempfile(fileext = ".nw")
  writeLines("(A, B, C);", tmp)
  on.exit(unlink(tmp))

  tree <- parse_newick(tmp)
  expect_equal(tree$n_tips, 3L)
})

test_that("parse_newick() reads inst/extdata/example.nw", {
  nw_path <- system.file("extdata", "example.nw", package = "ggsunburstR")
  skip_if(nw_path == "", message = "example.nw not installed")
  tree <- parse_newick(nw_path)
  expect_equal(tree$n_tips, 10L)
})

# --- Error handling ---

test_that("parse_newick() errors on invalid Newick string", {
  expect_error(parse_newick("not a newick string"), class = "rlang_error")
})

test_that("parse_newick() errors on empty string", {
  expect_error(parse_newick(""), class = "rlang_error")
})

# --- Single-leaf tree ---

test_that("parse_newick() handles single-leaf tree", {
  # "(A);" is a cleaner single-leaf Newick than "A;" (which ape
  # interprets as a root label, not a tip label).
  tree <- parse_newick("(A);")
  expect_equal(tree$n_tips, 1L)
  leaves <- get_leaves(tree, tree$root)
  expect_equal(length(leaves), 1)
  expect_equal(tree$nodes[[leaves[1]]]$name, "A")
})

# --- Multifurcating tree ---

test_that("parse_newick() handles multifurcating tree", {
  tree <- parse_newick("(A, B, C, D);")
  expect_equal(tree$n_tips, 4L)
  root_kids <- tree$children[[tree$root]]
  expect_equal(length(root_kids), 4)
})

# --- 10-leaf example tree ---

test_that("parse_newick() parses the 10-leaf example tree", {
  tree <- parse_newick("(((a, b, c), (d, e, f, g)), (f, i, h));")
  expect_equal(tree$n_tips, 10L)
})
