# tests/testthat/test-tree-internal.R

# --- new_tree() ---

test_that("new_tree() returns a list with required elements", {
  tree <- new_tree()
  expect_type(tree, "list")
  expect_named(tree, c("nodes", "children", "parent", "root", "n_tips"),
               ignore.order = TRUE)
})

test_that("new_tree() root node has correct defaults", {
  tree <- new_tree()
  root <- tree$nodes[[1]]
  expect_equal(root$name, "")
  expect_equal(root$dist, 0.0)
  expect_false(root$is_leaf)
  expect_equal(root$extra, list())
  expect_equal(tree$root, 1L)
  expect_equal(tree$n_tips, 0L)
})

test_that("new_tree() root has no children and NA parent", {
  tree <- new_tree()
  expect_equal(tree$children[[1]], integer(0))
  expect_true(is.na(tree$parent[1]))
})

# --- add_child() ---

test_that("add_child() adds a leaf to root", {
  tree <- new_tree()
  new_id <- add_child(tree, parent_id = 1L, name = "A", dist = 1.0)
  tree <- attr(new_id, "tree")

  expect_equal(as.integer(new_id), 2L)
  expect_equal(length(tree$nodes), 2)
  expect_equal(tree$children[[1]], 2L)
  expect_equal(tree$parent[2], 1L)
  expect_equal(tree$nodes[[2]]$name, "A")
  expect_equal(tree$nodes[[2]]$dist, 1.0)
  expect_true(tree$nodes[[2]]$is_leaf)
  expect_false(tree$nodes[[1]]$is_leaf)
  expect_equal(tree$n_tips, 1L)
})

test_that("add_child() adds multiple children correctly", {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A")
  tree <- attr(id_a, "tree")
  id_b <- add_child(tree, 1L, "B")
  tree <- attr(id_b, "tree")

  expect_equal(tree$children[[1]], c(2L, 3L))
  expect_equal(tree$n_tips, 2L)
  expect_true(tree$nodes[[2]]$is_leaf)
  expect_true(tree$nodes[[3]]$is_leaf)
})

test_that("add_child() n_tips is accurate for multi-level tree", {
  # root → A → (a1, a2) — only a1 and a2 are leaves, not A
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A")
  tree <- attr(id_a, "tree")
  expect_equal(tree$n_tips, 1L)  # A is a leaf at this point

  id_a1 <- add_child(tree, 2L, "a1")
  tree <- attr(id_a1, "tree")
  expect_equal(tree$n_tips, 1L)  # A became internal, a1 is leaf

  id_a2 <- add_child(tree, 2L, "a2")
  tree <- attr(id_a2, "tree")
  expect_equal(tree$n_tips, 2L)  # a1 and a2 are leaves
})

test_that("add_child() carries extra attributes", {
  tree <- new_tree()
  id <- add_child(tree, 1L, "A", extra = list(colour = "red", size = "10"))
  tree <- attr(id, "tree")

  expect_equal(tree$nodes[[2]]$extra$colour, "red")
  expect_equal(tree$nodes[[2]]$extra$size, "10")
})

test_that("add_child() default dist is 1.0", {
  tree <- new_tree()
  id <- add_child(tree, 1L, "A")
  tree <- attr(id, "tree")
  expect_equal(tree$nodes[[2]]$dist, 1.0)
})

# --- find_node_by_name() ---

test_that("find_node_by_name() returns correct ID for existing node", {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A")
  tree <- attr(id_a, "tree")
  id_b <- add_child(tree, 1L, "B")
  tree <- attr(id_b, "tree")

  expect_equal(find_node_by_name(tree, "A"), 2L)
  expect_equal(find_node_by_name(tree, "B"), 3L)
})

test_that("find_node_by_name() returns NULL for non-existent node", {
  tree <- new_tree()
  expect_null(find_node_by_name(tree, "Z"))
})
