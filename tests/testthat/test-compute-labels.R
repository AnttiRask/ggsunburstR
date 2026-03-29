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

test_that("leaf label y equals ymax (outer edge per SPEC.md §2.4.1)", {
  labels <- compute_labels_test("(a, b, c);")
  leaf_ids <- which(vapply(labels$leaf_labels, function(l) !is.null(l),
                           logical(1)))
  for (lid in leaf_ids) {
    expect_equal(labels$leaf_labels[[lid]]$y, 0.0)
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

# --- Integration: left-side labels get flipped angles and hjust = 1 ---

test_that("labels on left side (cos < 0) have rhjust = 1 and flipped rangle", {
  # With many leaves spread across 360°, some will land on the left side.
  # Use 8 leaves so we get good coverage of the angle range.
  labels <- compute_labels_test("(a, b, c, d, e, f, g, h);")
  leaf_ids <- which(vapply(labels$leaf_labels, function(l) !is.null(l),
                           logical(1)))

  found_left <- FALSE
  found_right <- FALSE
  for (lid in leaf_ids) {
    l <- labels$leaf_labels[[lid]]
    base <- l$angle
    cos_val <- cos(base * pi / 180)
    if (cos_val < 0) {
      # Left side: rhjust must be 1, rangle must be base + 180
      expect_equal(l$rhjust, 1, info = paste("leaf", lid, "base_angle", base))
      expect_equal(l$rangle, base + 180,
                   info = paste("leaf", lid, "base_angle", base))
      found_left <- TRUE
    } else {
      # Right side: rhjust must be 0, rangle must be base
      expect_equal(l$rhjust, 0, info = paste("leaf", lid, "base_angle", base))
      expect_equal(l$rangle, base,
                   info = paste("leaf", lid, "base_angle", base))
      found_right <- TRUE
    }
  }
  # Ensure we actually tested both sides

  expect_true(found_left, info = "No labels on left side — test is incomplete")
  expect_true(found_right, info = "No labels on right side — test is incomplete")
})

# --- Leaf labels include ymin, ymax, delta_angle ---

test_that("leaf labels include y_mid, ymin, ymax fields", {
  labels <- compute_labels_test("(a, b, c);")
  leaf_ids <- which(vapply(labels$leaf_labels, function(l) !is.null(l),
                           logical(1)))
  for (lid in leaf_ids) {
    l <- labels$leaf_labels[[lid]]
    expect_true(!is.null(l$ymin), info = "missing ymin")
    expect_true(!is.null(l$ymax), info = "missing ymax")
    expect_true(l$ymin < l$ymax, info = "ymin must be < ymax")
  }
})

test_that("leaf labels include delta_angle", {
  labels <- compute_labels_test("(a, b, c);")
  leaf_ids <- which(vapply(labels$leaf_labels, function(l) !is.null(l),
                           logical(1)))
  for (lid in leaf_ids) {
    l <- labels$leaf_labels[[lid]]
    expect_true(!is.null(l$delta_angle), info = "missing delta_angle")
    expect_true(l$delta_angle > 0, info = "delta_angle must be positive")
  }
})

test_that("leaf delta_angle equals size * (xlim / total_size)", {
  labels <- compute_labels_test("(a, b, c);", values = c(a = 2, b = 1, c = 3))
  leaf_ids <- which(vapply(labels$leaf_labels, function(l) !is.null(l),
                           logical(1)))
  # total_size = 6, xlim = 360
  for (lid in leaf_ids) {
    l <- labels$leaf_labels[[lid]]
    # Look up the leaf name to find its expected value
    if (l$label == "a") expect_equal(l$delta_angle, 2 / 6 * 360)
    if (l$label == "b") expect_equal(l$delta_angle, 1 / 6 * 360)
    if (l$label == "c") expect_equal(l$delta_angle, 3 / 6 * 360)
  }
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

# --- Partial sunburst (xlim < 360) ---

test_that("labels scale correctly for xlim < 360 (partial sunburst)", {
  labels_full <- compute_labels_test("(a, b);", xlim = 360)
  labels_half <- compute_labels_test("(a, b);", xlim = 180)
  # delta_angle should be halved for half-sunburst
  node_ids_full <- which(vapply(labels_full$node_labels, function(l) !is.null(l), logical(1)))
  node_ids_half <- which(vapply(labels_half$node_labels, function(l) !is.null(l), logical(1)))
  # No internal node labels for "(a, b);" — check leaf delta_angle instead
  # Actually "(a, b);" has root -> a, b. Root is excluded. So use leaf labels.
  leaf_full <- which(vapply(labels_full$leaf_labels, function(l) !is.null(l), logical(1)))
  leaf_half <- which(vapply(labels_half$leaf_labels, function(l) !is.null(l), logical(1)))
  # Use a tree with internal nodes for delta_angle
  labels_full2 <- compute_labels_test("((a, b), c);", xlim = 360)
  labels_half2 <- compute_labels_test("((a, b), c);", xlim = 180)
  nf <- which(vapply(labels_full2$node_labels, function(l) !is.null(l), logical(1)))
  nh <- which(vapply(labels_half2$node_labels, function(l) !is.null(l), logical(1)))
  expect_equal(labels_half2$node_labels[[nh[1]]]$delta_angle,
               labels_full2$node_labels[[nf[1]]]$delta_angle / 2)
})
