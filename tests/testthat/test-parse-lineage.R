# tests/testthat/test-parse-lineage.R

# Helper: write temp lineage file
write_lineage <- function(lines) {
  tmp <- tempfile(fileext = ".tsv")
  writeLines(lines, tmp)
  tmp
}

# --- Basic parsing ---

test_that("parse_lineage() parses basic 3-line file", {
  f <- write_lineage(c("A\tB\tC", "A\tB\tD", "A\tE"))
  on.exit(unlink(f))

  tree <- parse_lineage(f)
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("C", "D", "E"))
})

# --- Shared prefixes ---

test_that("parse_lineage() reuses shared path prefixes", {
  f <- write_lineage(c("A\tB\tC", "A\tB\tD"))
  on.exit(unlink(f))

  tree <- parse_lineage(f)
  # A and B should exist only once
  a_id <- find_node_by_name(tree, "A")
  b_id <- find_node_by_name(tree, "B")
  expect_false(is.null(a_id))
  expect_false(is.null(b_id))

  # B should have 2 children: C and D
  b_kids <- tree$children[[b_id]]
  expect_equal(length(b_kids), 2)
  kid_names <- vapply(b_kids, function(k) tree$nodes[[k]]$name, character(1))
  expect_equal(sort(kid_names), c("C", "D"))
})

# --- Attribute syntax ---

test_that("parse_lineage() parses attribute syntax", {
  f <- write_lineage(c("root\tleaf->colour:red;size:10"))
  on.exit(unlink(f))

  tree <- parse_lineage(f)
  # Find the leaf node (should have attributes)
  leaf_id <- find_node_by_name(tree, "leaf")
  expect_false(is.null(leaf_id))
  expect_equal(tree$nodes[[leaf_id]]$extra$colour, "red")
  expect_equal(tree$nodes[[leaf_id]]$extra$size, "10")
})

# --- Single-line file ---

test_that("parse_lineage() handles single-line file", {
  f <- write_lineage(c("A\tB"))
  on.exit(unlink(f))

  tree <- parse_lineage(f)
  leaves <- get_leaves(tree, tree$root)
  expect_equal(length(leaves), 1)
  expect_equal(tree$nodes[[leaves[1]]]$name, "B")
})

# --- Custom separator ---

test_that("parse_lineage() supports custom separator", {
  f <- write_lineage(c("A,B,C", "A,B,D"))
  on.exit(unlink(f))

  tree <- parse_lineage(f, sep = ",")
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("C", "D"))
})
