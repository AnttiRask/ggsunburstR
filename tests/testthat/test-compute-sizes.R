# tests/testthat/test-compute-sizes.R

# Helper: build tree root → (A → (a1, a2), B)
build_size_tree <- function() {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A")
  tree <- attr(id_a, "tree")
  id_b <- add_child(tree, 1L, "B")
  tree <- attr(id_b, "tree")
  id_a1 <- add_child(tree, 2L, "a1")
  tree <- attr(id_a1, "tree")
  id_a2 <- add_child(tree, 2L, "a2")
  tree <- attr(id_a2, "tree")
  tree
}

# --- Default equal weight ---

test_that("assign_sizes() defaults all leaves to size = 1.0", {
  tree <- build_size_tree()
  result <- assign_sizes(tree)
  # Leaves: a1(4), a2(5), B(3) — all size 1.0

  expect_equal(result$nodes[[4]]$size, 1.0)
  expect_equal(result$nodes[[5]]$size, 1.0)
  expect_equal(result$nodes[[3]]$size, 1.0)
})

test_that("assign_sizes() default propagates sizes to internal nodes", {
  tree <- build_size_tree()
  result <- assign_sizes(tree)
  # A(2) has children a1 + a2 = 2.0
  expect_equal(result$nodes[[2]]$size, 2.0)
  # Root has children A(2) + B(1) = 3.0
  expect_equal(result$nodes[[1]]$size, 3.0)
})

# --- Explicit values ---

test_that("assign_sizes() uses named values for leaves", {
  tree <- build_size_tree()
  result <- assign_sizes(tree, values = c(a1 = 3, a2 = 1, B = 2))
  expect_equal(result$nodes[[4]]$size, 3.0)  # a1
  expect_equal(result$nodes[[5]]$size, 1.0)  # a2
  expect_equal(result$nodes[[3]]$size, 2.0)  # B
  # A = 3 + 1 = 4
  expect_equal(result$nodes[[2]]$size, 4.0)
})

# --- Partial values ---

test_that("assign_sizes() defaults unmatched leaves to 1.0", {
  tree <- build_size_tree()
  result <- assign_sizes(tree, values = c(a1 = 5))
  expect_equal(result$nodes[[4]]$size, 5.0)  # a1 (matched)
  expect_equal(result$nodes[[5]]$size, 1.0)  # a2 (default)
  expect_equal(result$nodes[[3]]$size, 1.0)  # B (default)
})

# --- Remainder mode ---

test_that("assign_sizes() remainder mode adds own_value to children sum", {
  tree <- build_size_tree()
  # Give A an own value of 5 in addition to children
  result <- assign_sizes(tree, values = c(a1 = 3, a2 = 1, A = 5),
                         branchvalues = "remainder")
  # A = own(5) + children(3 + 1) = 9
  expect_equal(result$nodes[[2]]$size, 9.0)
})

test_that("assign_sizes() remainder mode with no parent value is sum only", {
  tree <- build_size_tree()
  result <- assign_sizes(tree, values = c(a1 = 3, a2 = 1),
                         branchvalues = "remainder")
  # A = own(0) + children(3 + 1) = 4
  expect_equal(result$nodes[[2]]$size, 4.0)
})

# --- Total mode ---

test_that("assign_sizes() total mode consistent does not warn", {
  tree <- build_size_tree()
  # Parent value matches children sum exactly
  expect_no_warning(
    assign_sizes(tree, values = c(a1 = 3, a2 = 1, A = 4),
                 branchvalues = "total")
  )
})

test_that("assign_sizes() total mode inconsistent warns", {
  tree <- build_size_tree()
  expect_warning(
    assign_sizes(tree, values = c(a1 = 3, a2 = 1, A = 10),
                 branchvalues = "total"),
    "does not match"
  )
})

test_that("assign_sizes() total mode uses children sum regardless", {
  tree <- build_size_tree()
  result <- suppressWarnings(
    assign_sizes(tree, values = c(a1 = 3, a2 = 1, A = 10),
                 branchvalues = "total")
  )
  # A = sum(children) = 4, not the supplied 10
  expect_equal(result$nodes[[2]]$size, 4.0)
})

# --- All-zero values error ---

test_that("all-zero values cause error in compute_coordinates", {
  tree <- parse_newick("(a, b, c);")
  tree <- assign_sizes(tree, values = c(a = 0, b = 0, c = 0))
  expect_error(compute_coordinates(tree), "zero")
})
