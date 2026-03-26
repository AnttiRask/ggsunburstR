# tests/testthat/test-compute-labels.R

# Helper: parse → size → coords → labels
compute_labels_test <- function(nw, values = NULL, xlim = 360, rot = 0) {
  tree <- parse_newick(nw)
  tree <- assign_sizes(tree, values = values)
  coords <- compute_coordinates(tree)
  labels <- compute_label_positions(coords$rects, tree, xlim = xlim,
                                    total_size = coords$total_size, rot = rot)
  labels
}

# --- Leaf label y at outer edge ---

test_that("leaf label y equals ymax (outer edge)", {
  labels <- compute_labels_test("(a, b, c);")
  leaf_ids <- which(vapply(labels$leaf_labels, function(l) !is.null(l),
                           logical(1)))
  for (lid in leaf_ids) {
    # y_out should equal the rect's ymax (= 0.0 for farthest leaves)
    expect_equal(labels$leaf_labels[[lid]]$y_out, 0.0)
  }
})

# --- Label positions are populated ---

test_that("leaf labels have all required fields", {
  labels <- compute_labels_test("(a, b, c);")
  leaf_ids <- which(vapply(labels$leaf_labels, function(l) !is.null(l),
                           logical(1)))
  for (lid in leaf_ids) {
    l <- labels$leaf_labels[[lid]]
    expect_true(!is.null(l$label))
    expect_true(!is.null(l$x))
    expect_true(!is.null(l$y))
    expect_true(!is.null(l$angle))
    expect_true(!is.null(l$rangle))
    expect_true(!is.null(l$rhjust))
    expect_true(!is.null(l$pangle))
    expect_true(!is.null(l$pvjust))
  }
})

test_that("node labels have all required fields", {
  labels <- compute_labels_test("((a, b), c);")
  node_ids <- which(vapply(labels$node_labels, function(l) !is.null(l),
                           logical(1)))
  expect_true(length(node_ids) >= 1)
  for (nid in node_ids) {
    l <- labels$node_labels[[nid]]
    expect_true(!is.null(l$label))
    expect_true(!is.null(l$rangle))
    expect_true(!is.null(l$rhjust))
    expect_true(!is.null(l$pangle))
    expect_true(!is.null(l$pvjust))
    expect_true(!is.null(l$delta_angle))
    expect_true(!is.null(l$xfraction))
  }
})

# --- delta_angle proportional to size ---

test_that("delta_angle is proportional to subtree leaf size", {
  labels <- compute_labels_test("((a, b), c);", values = c(a = 2, b = 1, c = 3))
  # total_size = 6, xlim = 360
  # Internal node (parent of a,b): leaf sum = 3, delta_angle = (3/6)*360 = 180
  node_ids <- which(vapply(labels$node_labels, function(l) !is.null(l),
                           logical(1)))
  internal <- labels$node_labels[[node_ids[1]]]
  expect_equal(internal$delta_angle, 180.0)
  expect_equal(internal$xfraction, 0.5)
})

# --- xfraction sums to 1 for root's children ---

test_that("xfraction sums to 1 across all nodes at depth 1", {
  labels <- compute_labels_test("((a, b), (c, d));")
  # Two internal nodes at depth 1, each with 2 leaves → each xfraction = 0.5
  node_ids <- which(vapply(labels$node_labels, function(l) !is.null(l),
                           logical(1)))
  xfractions <- vapply(node_ids, function(i) {
    labels$node_labels[[i]]$xfraction
  }, numeric(1))
  expect_equal(sum(xfractions), 1.0)
})

# --- Leaf labels: all leaves get a label ---

test_that("every leaf gets a label entry", {
  labels <- compute_labels_test("(a, b, c);")
  leaf_ids <- which(vapply(labels$leaf_labels, function(l) !is.null(l),
                           logical(1)))
  expect_equal(length(leaf_ids), 3)
})

# --- Rotation offset ---

test_that("rot parameter shifts base angles", {
  labels_no_rot <- compute_labels_test("(a, b);", rot = 0)
  labels_rot <- compute_labels_test("(a, b);", rot = 45)
  # Same leaf, different angle due to rotation
  leaf_ids <- which(vapply(labels_no_rot$leaf_labels, function(l) !is.null(l),
                           logical(1)))
  angle_no_rot <- labels_no_rot$leaf_labels[[leaf_ids[1]]]$angle
  angle_rot <- labels_rot$leaf_labels[[leaf_ids[1]]]$angle
  expect_equal(angle_no_rot - angle_rot, 45.0)
})
