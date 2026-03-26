# tests/testthat/test-tree-transform.R

# --- ladderize_tree() ---

test_that("ladderize_tree() sorts children ascending by leaf count", {
  # root → A (2 leaves: a1, a2), B (1 leaf)
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A")
  tree <- attr(id_a, "tree")
  id_b <- add_child(tree, 1L, "B")
  tree <- attr(id_b, "tree")
  id_a1 <- add_child(tree, 2L, "a1")
  tree <- attr(id_a1, "tree")
  id_a2 <- add_child(tree, 2L, "a2")
  tree <- attr(id_a2, "tree")

  # Before ladderize: root children = [A(2), B(3)]
  expect_equal(tree$children[[1]], c(2L, 3L))

  result <- ladderize_tree(tree)
  # After: B (1 leaf) before A (2 leaves)
  expect_equal(result$children[[1]], c(3L, 2L))
})

test_that("ladderize_tree(reverse = TRUE) sorts descending", {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A")
  tree <- attr(id_a, "tree")
  id_b <- add_child(tree, 1L, "B")
  tree <- attr(id_b, "tree")
  id_a1 <- add_child(tree, 2L, "a1")
  tree <- attr(id_a1, "tree")
  id_a2 <- add_child(tree, 2L, "a2")
  tree <- attr(id_a2, "tree")

  result <- ladderize_tree(tree, reverse = TRUE)
  # A (2 leaves) before B (1 leaf) — descending
  expect_equal(result$children[[1]], c(2L, 3L))
})

test_that("ladderize_tree() handles single-child nodes gracefully", {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A")
  tree <- attr(id_a, "tree")

  result <- ladderize_tree(tree)
  expect_equal(result$children[[1]], 2L)
})

# --- convert_to_ultrametric() ---

test_that("convert_to_ultrametric() makes all leaves equidistant", {
  # root → A(dist=1) → leaf1(dist=1), root → B(dist=3)
  # Before: leaf1 at dist 2, B at dist 3
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A", dist = 1.0)
  tree <- attr(id_a, "tree")
  id_leaf <- add_child(tree, 2L, "leaf1", dist = 1.0)
  tree <- attr(id_leaf, "tree")
  id_b <- add_child(tree, 1L, "B", dist = 3.0)
  tree <- attr(id_b, "tree")

  result <- convert_to_ultrametric(tree)

  # All leaves should be equidistant from root
  dist_leaf1 <- get_distance_to_root(result, 3L)
  dist_b <- get_distance_to_root(result, 4L)
  expect_equal(dist_leaf1, dist_b, tolerance = 1e-10)
})

test_that("convert_to_ultrametric() preserves tree length (max distance)", {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A", dist = 1.0)
  tree <- attr(id_a, "tree")
  id_leaf <- add_child(tree, 2L, "leaf1", dist = 1.0)
  tree <- attr(id_leaf, "tree")
  id_b <- add_child(tree, 1L, "B", dist = 3.0)
  tree <- attr(id_b, "tree")

  original_max <- get_farthest_node(tree)$dist
  result <- convert_to_ultrametric(tree)
  new_max <- get_farthest_node(result)$dist

  expect_equal(new_max, original_max, tolerance = 1e-10)
})

test_that("convert_to_ultrametric() on already-ultrametric tree is a no-op", {
  # Both leaves at distance 2.0 from root
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A", dist = 2.0)
  tree <- attr(id_a, "tree")
  id_b <- add_child(tree, 1L, "B", dist = 2.0)
  tree <- attr(id_b, "tree")

  result <- convert_to_ultrametric(tree)
  dist_a <- get_distance_to_root(result, 2L)
  dist_b <- get_distance_to_root(result, 3L)
  expect_equal(dist_a, dist_b, tolerance = 1e-10)
  expect_equal(dist_a, 2.0, tolerance = 1e-10)
})

test_that("convert_to_ultrametric() preserves tree structure", {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A", dist = 2.0)
  tree <- attr(id_a, "tree")
  id_b <- add_child(tree, 1L, "B", dist = 5.0)
  tree <- attr(id_b, "tree")

  result <- convert_to_ultrametric(tree)
  # Structure unchanged: root still has 2 children
  expect_equal(length(result$children[[1]]), 2)
  expect_equal(result$nodes[[2]]$name, "A")
  expect_equal(result$nodes[[3]]$name, "B")
})
