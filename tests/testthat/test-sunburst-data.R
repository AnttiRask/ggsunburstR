# tests/testthat/test-sunburst-data.R

# --- End-to-end Newick ---

test_that("sunburst_data() works end-to-end with Newick string", {
  sb <- sunburst_data("(A, B, C);")
  expect_s3_class(sb, "sunburst_data")
  expect_equal(nrow(sb$rects), 3)  # 3 leaves, no internal (root excluded)
  expect_true(all(sb$rects$is_leaf))
  expect_true("xmin" %in% names(sb$rects))
  expect_true("ymin" %in% names(sb$rects))
})

test_that("sunburst_data() Newick with internals includes non-root internal nodes", {
  sb <- sunburst_data("((a, b), c);")
  # 3 leaves + 1 internal (parent of a,b) = 4 rows (root excluded)
  expect_equal(nrow(sb$rects), 4)
  expect_equal(sum(sb$rects$is_leaf), 3)
  expect_equal(sum(!sb$rects$is_leaf), 1)
})

# --- End-to-end data.frame ---

test_that("sunburst_data() works end-to-end with data.frame", {
  df <- data.frame(
    parent = c(NA, "root", "root", "A", "A"),
    child  = c("root", "A", "B", "a1", "a2"),
    stringsAsFactors = FALSE
  )
  sb <- sunburst_data(df)
  expect_s3_class(sb, "sunburst_data")
  expect_true(nrow(sb$rects) > 0)
})

# --- Auto-detection ---

test_that("sunburst_data() auto-detects Newick string", {
  sb <- sunburst_data("(A, B);")
  expect_s3_class(sb, "sunburst_data")
})

test_that("sunburst_data() auto-detects data.frame", {
  df <- data.frame(parent = c(NA, "root"), child = c("root", "A"))
  sb <- sunburst_data(df)
  expect_s3_class(sb, "sunburst_data")
})

# --- Values parameter ---

test_that("sunburst_data() with named values vector sizes sectors", {
  sb <- sunburst_data("(a, b, c);", values = c(a = 3, b = 1, c = 2))
  rects <- sb$rects
  a_row <- rects[rects$name == "a", ]
  b_row <- rects[rects$name == "b", ]
  a_width <- a_row$xmax - a_row$xmin
  b_width <- b_row$xmax - b_row$xmin
  expect_equal(a_width / b_width, 3.0)
})

test_that("sunburst_data() with string values column extracts from data.frame", {
  df <- data.frame(
    parent = c(NA, "root", "root"),
    child  = c("root", "A", "B"),
    size   = c(NA, 10, 20),
    stringsAsFactors = FALSE
  )
  sb <- sunburst_data(df, values = "size")
  rects <- sb$rects
  a_row <- rects[rects$name == "A", ]
  b_row <- rects[rects$name == "B", ]
  b_width <- b_row$xmax - b_row$xmin
  a_width <- a_row$xmax - a_row$xmin
  expect_equal(b_width / a_width, 2.0)
})

# --- Ladderize ---

test_that("sunburst_data() ladderize reorders leaves", {
  # Without ladderize: A (2 leaves) before B (1 leaf)
  sb_no <- sunburst_data("((a, b), c);", ladderize = FALSE)
  sb_yes <- sunburst_data("((a, b), c);", ladderize = TRUE)
  # With ladderize: c (1 leaf) should come before a,b (2 leaves)
  # Check xmin order: first leaf in ladderized should be c
  first_leaf_no <- sb_no$rects[which.min(sb_no$rects$xmin), "name"]
  first_leaf_yes <- sb_yes$rects[which.min(sb_yes$rects$xmin), "name"]
  expect_equal(first_leaf_yes, "c")
})

# --- Ultrametric ---

test_that("sunburst_data() ultrametric equalises leaf depths", {
  sb <- sunburst_data("((a:1, b:1):1, c:3);", ultrametric = TRUE)
  leaf_rects <- sb$rects[sb$rects$is_leaf, ]
  # All leaves should have the same ymax
  expect_equal(length(unique(leaf_rects$ymax)), 1)
})

# --- leaf_mode ---

test_that("sunburst_data() leaf_mode extended equalises leaf ymax", {
  sb <- sunburst_data("((a, b), c);", leaf_mode = "extended")
  leaf_rects <- sb$rects[sb$rects$is_leaf, ]
  expect_equal(length(unique(leaf_rects$ymax)), 1)
})

# --- xlim and rot ---

test_that("sunburst_data() stores xlim and rot in params", {
  sb <- sunburst_data("(A, B);", xlim = 270, rot = 45)
  params <- attr(sb, "params")
  expect_equal(params$xlim, 270)
  expect_equal(params$rot, 45)
})

# --- Error handling ---

test_that("sunburst_data() errors on invalid input", {
  expect_error(sunburst_data(42), class = "rlang_error")
})

# --- Output structure ---

test_that("sunburst_data() output has all expected components", {
  sb <- sunburst_data("((a, b), c);")
  expect_true(!is.null(sb$rects))
  expect_true(!is.null(sb$leaf_labels))
  expect_true(!is.null(sb$node_labels))
  expect_true(!is.null(sb$segments))
  expect_true(!is.null(sb$tree))
})

test_that("sunburst_data() $rects has required columns", {
  sb <- sunburst_data("((a, b), c);")
  expected_cols <- c("node_id", "name", "parent_name", "depth", "is_leaf",
                     "xmin", "xmax", "ymin", "ymax", "x")
  for (col in expected_cols) {
    expect_true(col %in% names(sb$rects), info = paste("Missing:", col))
  }
})

test_that("sunburst_data() $leaf_labels has label data", {
  sb <- sunburst_data("(a, b, c);")
  expect_true(nrow(sb$leaf_labels) == 3)
  expect_true("label" %in% names(sb$leaf_labels))
  expect_true("angle" %in% names(sb$leaf_labels))
  expect_true("hjust" %in% names(sb$leaf_labels))
})
