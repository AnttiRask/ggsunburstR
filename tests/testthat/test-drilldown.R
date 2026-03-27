# tests/testthat/test-drilldown.R

# Tree: root → (internal1 → (a, b, c), internal2 → (d, e))
make_sb <- function() {
  sunburst_data("(((a, b, c), (d, e)), (f, g, h));")
}

# --- extract_subtree ---

test_that("extract_subtree() creates valid tree from subtree", {
  sb <- make_sb()
  tree <- sb$tree
  # Find the internal node that parents a, b, c
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  subtree <- extract_subtree(tree, parent_id)
  expect_equal(subtree$n_tips, 3L)
  leaves <- get_leaves(subtree, subtree$root)
  leaf_names <- vapply(leaves, function(l) subtree$nodes[[l]]$name,
                        character(1))
  expect_equal(sort(leaf_names), c("a", "b", "c"))
})

test_that("extract_subtree() preserves branch lengths", {
  tree <- parse_newick("((a:0.5, b:1.5):2.0, c:3.0);")
  # Subtree rooted at parent of a,b (node with dist=2.0)
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  subtree <- extract_subtree(tree, parent_id)
  a_sub <- find_node_by_name(subtree, "a")
  b_sub <- find_node_by_name(subtree, "b")
  expect_equal(subtree$nodes[[a_sub]]$dist, 0.5)
  expect_equal(subtree$nodes[[b_sub]]$dist, 1.5)
})

test_that("extract_subtree() preserves node extras", {
  tree <- new_tree()
  id_a <- add_child(tree, 1L, "A", extra = list(colour = "red"))
  tree <- attr(id_a, "tree")
  id_a1 <- add_child(tree, 2L, "a1", extra = list(colour = "blue"))
  tree <- attr(id_a1, "tree")
  id_a2 <- add_child(tree, 2L, "a2", extra = list(colour = "green"))
  tree <- attr(id_a2, "tree")

  subtree <- extract_subtree(tree, 2L)
  a1_sub <- find_node_by_name(subtree, "a1")
  expect_equal(subtree$nodes[[a1_sub]]$extra$colour, "blue")
})

# --- drilldown by name ---

test_that("drilldown() by name returns valid sunburst_data", {
  # Use a tree with named internal nodes
  sb <- sunburst_data("((a, b)X, (c, d)Y)root;")
  sb_sub <- drilldown(sb, node = "X")
  expect_s3_class(sb_sub, "sunburst_data")
  expect_true(nrow(sb_sub$rects) > 0)
  leaf_names <- sort(sb_sub$rects$name[sb_sub$rects$is_leaf])
  expect_equal(leaf_names, c("a", "b"))
})

# --- drilldown by node_id ---

test_that("drilldown() by integer node_id works", {
  sb <- make_sb()
  tree <- sb$tree
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  sb_sub <- drilldown(sb, node = parent_id)
  expect_s3_class(sb_sub, "sunburst_data")
  leaf_names <- sort(sb_sub$rects$name[sb_sub$rects$is_leaf])
  expect_equal(leaf_names, c("a", "b", "c"))
})

# --- Subtree fills full angular space ---

test_that("drilldown() subtree fills the full angular space", {
  sb <- sunburst_data("((a, b), (c, d));")
  tree <- sb$tree
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  sb_sub <- drilldown(sb, node = parent_id)
  # a and b should now fill the full width
  total_width_orig <- max(sb$rects$xmax) - min(sb$rects$xmin)
  total_width_sub <- max(sb_sub$rects$xmax) - min(sb_sub$rects$xmin)
  # Both should equal total leaf sizes (subtree has 2 leaves = width 2)
  expect_equal(total_width_sub, 2.0)
})

# --- Error: node not found ---

test_that("drilldown() errors when node name not found", {
  sb <- make_sb()
  expect_error(drilldown(sb, node = "nonexistent"),
               "not found", class = "rlang_error")
})

test_that("drilldown() errors when node_id out of range", {
  sb <- make_sb()
  expect_error(drilldown(sb, node = 9999L),
               "out of range", class = "rlang_error")
})

# --- Error: leaf node ---

test_that("drilldown() errors on leaf node", {
  sb <- make_sb()
  expect_error(drilldown(sb, node = "a"),
               "leaf", class = "rlang_error")
})

# --- Warn: root node ---

test_that("drilldown() warns on root and returns unchanged", {
  sb <- make_sb()
  expect_warning(sb_same <- drilldown(sb, node = sb$tree$root),
                 "already the root")
  expect_identical(sb_same, sb)
})

# --- Preserves values ---

test_that("drilldown() with value-weighted tree preserves proportions", {
  sb <- sunburst_data("((a, b), (c, d));",
                       values = c(a = 3, b = 1, c = 2, d = 4))
  tree <- sb$tree
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  sb_sub <- drilldown(sb, node = parent_id)
  rects <- sb_sub$rects
  a_width <- rects[rects$name == "a", "xmax"] - rects[rects$name == "a", "xmin"]
  b_width <- rects[rects$name == "b", "xmax"] - rects[rects$name == "b", "xmin"]
  expect_equal(a_width / b_width, 3.0)
})

# --- Chained drilldown ---

test_that("chained drilldown works", {
  sb <- sunburst_data("(((a, b), (c, d)), (e, f));")
  tree <- sb$tree
  a_id <- find_node_by_name(tree, "a")
  mid_id <- tree$parent[a_id]  # parent of a,b
  top_id <- tree$parent[mid_id]  # parent of (a,b),(c,d)

  sb1 <- drilldown(sb, node = top_id)
  # Now drill further into the a,b subtree
  tree1 <- sb1$tree
  a1_id <- find_node_by_name(tree1, "a")
  parent1_id <- tree1$parent[a1_id]

  sb2 <- drilldown(sb1, node = parent1_id)
  leaf_names <- sort(sb2$rects$name[sb2$rects$is_leaf])
  expect_equal(leaf_names, c("a", "b"))
})

# --- Composable with plot functions ---

test_that("drilldown() result works with sunburst()", {
  sb <- sunburst_data("((a, b), (c, d));")
  tree <- sb$tree
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  sb_sub <- drilldown(sb, node = parent_id)
  p <- sunburst(sb_sub, fill = "name")
  expect_s3_class(p, "ggplot")
})

test_that("drilldown() result works with icicle()", {
  sb <- sunburst_data("((a, b), (c, d));")
  tree <- sb$tree
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  sb_sub <- drilldown(sb, node = parent_id)
  p <- icicle(sb_sub)
  expect_s3_class(p, "ggplot")
})

# --- Stores drilldown_from ---

test_that("drilldown() stores drilldown_from in params", {
  sb <- sunburst_data("((a, b), (c, d));")
  tree <- sb$tree
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  sb_sub <- drilldown(sb, node = parent_id)
  expect_equal(attr(sb_sub, "params")$drilldown_from, parent_id)
})

# --- ... overrides ---

test_that("drilldown() with xlim override applies to result", {
  sb <- sunburst_data("((a, b), (c, d));")
  tree <- sb$tree
  a_id <- find_node_by_name(tree, "a")
  parent_id <- tree$parent[a_id]

  sb_sub <- drilldown(sb, node = parent_id, xlim = 180)
  expect_equal(attr(sb_sub, "params")$xlim, 180)
})

# --- Input validation ---

test_that("drilldown() errors on non-sunburst_data input", {
  expect_error(drilldown(data.frame(x = 1), "a"), class = "rlang_error")
})
