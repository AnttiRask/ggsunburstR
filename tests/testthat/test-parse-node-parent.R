# tests/testthat/test-parse-node-parent.R

# Helper: write temp CSV
write_np_csv <- function(lines, ext = ".csv") {
  tmp <- tempfile(fileext = ext)
  writeLines(lines, tmp)
  tmp
}

# --- Basic CSV ---

test_that("parse_node_parent() parses basic CSV", {
  f <- write_np_csv(c(
    "node,parent",
    "A,root",
    "B,root",
    "a1,A",
    "a2,A"
  ))
  on.exit(unlink(f))

  tree <- parse_node_parent(f)
  leaves <- get_leaves(tree, tree$root)
  leaf_names <- vapply(leaves, function(l) tree$nodes[[l]]$name, character(1))
  expect_equal(sort(leaf_names), c("B", "a1", "a2"))
  expect_equal(tree$n_tips, 3L)
})

# --- Extra columns ---

test_that("parse_node_parent() carries extra columns as node attributes", {
  f <- write_np_csv(c(
    "node,parent,colour",
    "A,root,red",
    "B,root,blue"
  ))
  on.exit(unlink(f))

  tree <- parse_node_parent(f)
  a_id <- find_node_by_name(tree, "A")
  b_id <- find_node_by_name(tree, "B")
  expect_equal(tree$nodes[[a_id]]$extra$colour, "red")
  expect_equal(tree$nodes[[b_id]]$extra$colour, "blue")
})

# --- Missing header ---

test_that("parse_node_parent() errors on missing required columns", {
  f <- write_np_csv(c(
    "name,group",
    "A,1",
    "B,2"
  ))
  on.exit(unlink(f))

  expect_error(parse_node_parent(f), class = "rlang_error")
})

# --- TSV separator ---

test_that("parse_node_parent() supports TSV separator", {
  f <- write_np_csv(c(
    "node\tparent",
    "A\troot",
    "B\tA"
  ), ext = ".tsv")
  on.exit(unlink(f))

  tree <- parse_node_parent(f, sep = "\t")
  b_id <- find_node_by_name(tree, "B")
  a_id <- find_node_by_name(tree, "A")
  expect_equal(tree$parent[b_id], a_id)
})

# --- Empty parent (root) ---

test_that("parse_node_parent() handles empty parent as root", {
  f <- write_np_csv(c(
    "node,parent",
    "root,",
    "A,root"
  ))
  on.exit(unlink(f))

  tree <- parse_node_parent(f)
  a_id <- find_node_by_name(tree, "A")
  expect_false(is.null(a_id))
})

# --- Fixture file ---

test_that("parse_node_parent() reads inst/extdata/example-node-parent.csv", {
  f <- system.file("extdata", "example-node-parent.csv",
                    package = "ggsunburstR")
  skip_if(f == "", message = "example-node-parent.csv not installed")
  tree <- parse_node_parent(f)
  expect_equal(tree$n_tips, 3L)  # a1, a2, b1
})
