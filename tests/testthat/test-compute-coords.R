# tests/testthat/test-compute-coords.R

# Helper: parse newick, assign sizes, compute coords
compute_test <- function(nw, values = NULL, branchvalues = "remainder",
                         leaf_mode = "actual") {
  tree <- parse_newick(nw)
  tree <- assign_sizes(tree, values = values, branchvalues = branchvalues)
  compute_coordinates(tree, leaf_mode = leaf_mode)
}

# --- Equal-width sectors ---

test_that("equal-weight leaves have equal width", {
  result <- compute_test("(a, b, c);")
  # 3 leaves, all size 1.0 → each has width 1.0
  leaf_ids <- which(vapply(result$rects, function(r) {
    !is.null(r) && r$is_leaf
  }, logical(1)))
  widths <- vapply(leaf_ids, function(i) {
    result$rects[[i]]$xmax - result$rects[[i]]$xmin
  }, numeric(1))
  expect_equal(length(unique(widths)), 1)
  expect_equal(widths[1], 1.0)
})

# --- Value-weighted widths ---

test_that("value-weighted leaves have proportional width", {
  result <- compute_test("(a, b);", values = c(a = 3, b = 1))
  a_id <- which(vapply(result$rects, function(r) {
    !is.null(r) && identical(r$name, "a")
  }, logical(1)))
  b_id <- which(vapply(result$rects, function(r) {
    !is.null(r) && identical(r$name, "b")
  }, logical(1)))
  a_width <- result$rects[[a_id]]$xmax - result$rects[[a_id]]$xmin
  b_width <- result$rects[[b_id]]$xmax - result$rects[[b_id]]$xmin
  expect_equal(a_width / b_width, 3.0)
})

# --- Sequential leaf X with no gaps ---

test_that("leaf X coordinates are sequential with no gaps", {
  result <- compute_test("(a, b, c);")
  leaf_ids <- which(vapply(result$rects, function(r) {
    !is.null(r) && r$is_leaf
  }, logical(1)))
  # Sort by xmin
  xmins <- vapply(leaf_ids, function(i) result$rects[[i]]$xmin, numeric(1))
  xmaxs <- vapply(leaf_ids, function(i) result$rects[[i]]$xmax, numeric(1))
  ord <- order(xmins)
  sorted_xmins <- xmins[ord]
  sorted_xmaxs <- xmaxs[ord]
  # Each leaf's xmin should equal previous leaf's xmax
  for (j in 2:length(sorted_xmins)) {
    expect_equal(sorted_xmins[j], sorted_xmaxs[j - 1])
  }
})

# --- Y from branch lengths ---

test_that("Y coordinates respect branch lengths", {
  result <- compute_test("((a:1, b:1):1, c:2);")
  # y_offset = max dist_to_root = 2 (for a: 1+1=2, b: 1+1=2, c: 2)
  # a: dist_to_root=2, ymax=2-2=0, ymin=0-1=-1
  a_id <- which(vapply(result$rects, function(r) {
    !is.null(r) && identical(r$name, "a")
  }, logical(1)))
  expect_equal(result$rects[[a_id]]$ymax, 0.0)
  expect_equal(result$rects[[a_id]]$ymin, -1.0)

  # c: dist_to_root=2, ymax=2-2=0, ymin=0-2=-2
  c_id <- which(vapply(result$rects, function(r) {
    !is.null(r) && identical(r$name, "c")
  }, logical(1)))
  expect_equal(result$rects[[c_id]]$ymax, 0.0)
  expect_equal(result$rects[[c_id]]$ymin, -2.0)
})

# --- Ragged tree actual mode ---

test_that("ragged tree actual mode has different leaf ymax", {
  # c is at depth 1 (dist=1), a,b at depth 2 (dist=1+1=2)
  # Without branch lengths, all dist=1.0
  result <- compute_test("((a, b), c);")
  c_id <- which(vapply(result$rects, function(r) {
    !is.null(r) && identical(r$name, "c")
  }, logical(1)))
  a_id <- which(vapply(result$rects, function(r) {
    !is.null(r) && identical(r$name, "a")
  }, logical(1)))
  # c should have ymax != a's ymax in actual mode (c is shallower)
  expect_true(result$rects[[c_id]]$ymax < result$rects[[a_id]]$ymax)
})

# --- leaf_mode = "extended" ---

test_that("extended mode equalises all leaf ymax to 0", {
  result <- compute_test("((a, b), c);", leaf_mode = "extended")
  leaf_ids <- which(vapply(result$rects, function(r) {
    !is.null(r) && r$is_leaf
  }, logical(1)))
  ymaxs <- vapply(leaf_ids, function(i) result$rects[[i]]$ymax, numeric(1))
  expect_true(all(ymaxs == 0.0))
})

# --- Single-leaf tree ---

test_that("single-leaf tree produces one rect", {
  result <- compute_test("(a);")
  non_null <- which(vapply(result$rects, function(r) !is.null(r), logical(1)))
  # Should have at least 1 rect (the leaf)
  expect_true(length(non_null) >= 1)
})

# --- SPEC.md §3.5 worked example ---

test_that("SPEC.md §3.5 worked example produces exact coordinates", {
  result <- compute_test("((a:1, b:1):1, c:2);",
                         values = c(a = 3, b = 1, c = 2))

  # a (id=1): xmin=0.5, xmax=3.5, ymin=-1, ymax=0, x=2.0
  a_rect <- result$rects[[1]]
  expect_equal(a_rect$xmin, 0.5)
  expect_equal(a_rect$xmax, 3.5)
  expect_equal(a_rect$ymin, -1.0)
  expect_equal(a_rect$ymax, 0.0)
  expect_equal(a_rect$x, 2.0)

  # b (id=2): xmin=3.5, xmax=4.5, ymin=-1, ymax=0, x=4.0
  b_rect <- result$rects[[2]]
  expect_equal(b_rect$xmin, 3.5)
  expect_equal(b_rect$xmax, 4.5)
  expect_equal(b_rect$ymin, -1.0)
  expect_equal(b_rect$ymax, 0.0)
  expect_equal(b_rect$x, 4.0)

  # node5 (id=5, internal): xmin=0.5, xmax=4.5, ymin=-2, ymax=-1, x=2.5
  n5_rect <- result$rects[[5]]
  expect_equal(n5_rect$xmin, 0.5)
  expect_equal(n5_rect$xmax, 4.5)
  expect_equal(n5_rect$ymin, -2.0)
  expect_equal(n5_rect$ymax, -1.0)
  expect_equal(n5_rect$x, 2.5)

  # c (id=3): xmin=4.5, xmax=6.5, ymin=-2, ymax=0, x=5.5
  c_rect <- result$rects[[3]]
  expect_equal(c_rect$xmin, 4.5)
  expect_equal(c_rect$xmax, 6.5)
  expect_equal(c_rect$ymin, -2.0)
  expect_equal(c_rect$ymax, 0.0)
  expect_equal(c_rect$x, 5.5)
})

# --- Internal node X spans children ---

test_that("internal node X spans from min child xmin to max child xmax", {
  result <- compute_test("((a, b), c);")
  # Find the internal node (parent of a, b)
  internal_ids <- which(vapply(result$rects, function(r) {
    !is.null(r) && !r$is_leaf
  }, logical(1)))
  expect_true(length(internal_ids) >= 1)
  internal <- result$rects[[internal_ids[1]]]
  # Its xmin should equal a's xmin, xmax should equal b's xmax
  a_id <- which(vapply(result$rects, function(r) {
    !is.null(r) && identical(r$name, "a")
  }, logical(1)))
  b_id <- which(vapply(result$rects, function(r) {
    !is.null(r) && identical(r$name, "b")
  }, logical(1)))
  expect_equal(internal$xmin, result$rects[[a_id]]$xmin)
  expect_equal(internal$xmax, result$rects[[b_id]]$xmax)
})

# --- Ragged tree edge cases ---

test_that("deeply ragged tree (5 levels) maintains xmin < xmax and ymin < ymax", {
  result <- compute_test("((((a, b), c), d), e);")
  non_null <- which(vapply(result$rects, function(r) !is.null(r), logical(1)))
  for (i in non_null) {
    r <- result$rects[[i]]
    expect_true(r$xmin < r$xmax,
                info = paste("node", i, "xmin >= xmax"))
    expect_true(r$ymin < r$ymax,
                info = paste("node", i, "ymin >= ymax"))
  }
})

test_that("ragged tree with branch lengths + extended mode equalises ymax", {
  result <- compute_test("((a:1, b:3):1, c:1);", leaf_mode = "extended")
  leaf_ids <- which(vapply(result$rects, function(r) {
    !is.null(r) && r$is_leaf
  }, logical(1)))
  ymaxs <- vapply(leaf_ids, function(i) result$rects[[i]]$ymax, numeric(1))
  expect_equal(length(unique(ymaxs)), 1)
  expect_equal(ymaxs[1], 0.0)
})

test_that("single-leaf tree extended mode is a no-op", {
  result_actual <- compute_test("(a);", leaf_mode = "actual")
  result_ext <- compute_test("(a);", leaf_mode = "extended")
  leaf_actual <- which(vapply(result_actual$rects, function(r) {
    !is.null(r) && r$is_leaf
  }, logical(1)))
  leaf_ext <- which(vapply(result_ext$rects, function(r) {
    !is.null(r) && r$is_leaf
  }, logical(1)))
  expect_equal(result_actual$rects[[leaf_actual[1]]]$ymax,
               result_ext$rects[[leaf_ext[1]]]$ymax)
})

test_that("all-same-depth tree extended mode is a no-op", {
  result_actual <- compute_test("(a, b, c);", leaf_mode = "actual")
  result_ext <- compute_test("(a, b, c);", leaf_mode = "extended")
  leaf_ids <- which(vapply(result_actual$rects, function(r) {
    !is.null(r) && r$is_leaf
  }, logical(1)))
  for (i in leaf_ids) {
    expect_equal(result_actual$rects[[i]]$ymax,
                 result_ext$rects[[i]]$ymax)
  }
})
