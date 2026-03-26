# tests/testthat/test-tree-traversal.R

# Helper: build tree root → (A → (a1, a2), B)
build_test_tree <- function() {
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

# --- get_descendants() postorder ---

test_that("postorder visits children before parents", {
  tree <- build_test_tree()
  # Tree: root(1) → A(2) → (a1(4), a2(5)), B(3)
  desc <- get_descendants(tree, 1L, "postorder")
  # a1, a2 before A; B and A before root
  expect_true(which(desc == 4L) < which(desc == 2L))
  expect_true(which(desc == 5L) < which(desc == 2L))
  expect_true(which(desc == 2L) < which(desc == 1L))
  expect_true(which(desc == 3L) < which(desc == 1L))
  expect_equal(length(desc), 5)
})

# --- get_descendants() levelorder ---

test_that("levelorder visits level by level (excluding start node)", {
  tree <- build_test_tree()
  desc <- get_descendants(tree, 1L, "levelorder")
  # Level 1: A(2), B(3) — level 2: a1(4), a2(5)
  # Root itself is excluded from levelorder
  expect_equal(desc[1:2], c(2L, 3L))
  expect_true(all(c(4L, 5L) %in% desc[3:4]))
  expect_equal(length(desc), 4)
})

# --- get_leaves() ---

test_that("get_leaves() returns only leaf node IDs", {
  tree <- build_test_tree()
  leaves <- get_leaves(tree, 1L)
  expect_equal(sort(leaves), c(3L, 4L, 5L))  # B, a1, a2
})

test_that("get_leaves() on a leaf returns that leaf", {
  tree <- build_test_tree()
  expect_equal(get_leaves(tree, 3L), 3L)
})

test_that("get_leaves() on a subtree returns only subtree leaves", {
  tree <- build_test_tree()
  leaves <- get_leaves(tree, 2L)
  expect_equal(sort(leaves), c(4L, 5L))  # a1, a2 only
})

# --- get_distance_to_root() ---

test_that("get_distance_to_root() sums branch lengths correctly", {
  tree <- new_tree()
  id <- add_child(tree, 1L, "internal", dist = 1.5)
  tree <- attr(id, "tree")
  id2 <- add_child(tree, 2L, "leaf", dist = 2.5)
  tree <- attr(id2, "tree")

  expect_equal(get_distance_to_root(tree, 3L), 4.0)  # 1.5 + 2.5
  expect_equal(get_distance_to_root(tree, 2L), 1.5)
  expect_equal(get_distance_to_root(tree, 1L), 0.0)   # root
})

# --- get_farthest_node() ---

test_that("get_farthest_node() finds the leaf with max distance", {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A", dist = 1.0)
  tree <- attr(id_a, "tree")
  id_b <- add_child(tree, 1L, "B", dist = 3.0)
  tree <- attr(id_b, "tree")

  farthest <- get_farthest_node(tree)
  expect_equal(farthest$node, 3L)  # B
  expect_equal(farthest$dist, 3.0)
})

test_that("get_farthest_node() handles deep tree", {
  tree <- new_tree()
  id <- add_child(tree, 1L, "mid", dist = 2.0)
  tree <- attr(id, "tree")
  id2 <- add_child(tree, 2L, "deep", dist = 3.0)
  tree <- attr(id2, "tree")
  id3 <- add_child(tree, 1L, "shallow", dist = 1.0)
  tree <- attr(id3, "tree")

  farthest <- get_farthest_node(tree)
  expect_equal(farthest$node, 3L)  # deep
  expect_equal(farthest$dist, 5.0)  # 2.0 + 3.0
})
