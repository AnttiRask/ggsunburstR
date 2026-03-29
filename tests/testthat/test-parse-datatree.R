# tests/testthat/test-parse-datatree.R

skip_if_not_installed("data.tree")

# Helper: build a simple data.tree
make_dt <- function() {
  root <- data.tree::Node$new("root_node")
  a <- root$AddChild("A")
  a$AddChild("a1")
  a$AddChild("a2")
  root$AddChild("B")
  root
}

# --- Detection ---

test_that("detect_input_type() returns 'datatree' for Node objects", {
  dt <- make_dt()
  expect_equal(detect_input_type(dt), "datatree")
})

# --- End-to-end ---

test_that("sunburst_data() works with data.tree Node", {
  dt <- make_dt()
  sb <- sunburst_data(dt)
  expect_s3_class(sb, "sunburst_data")
  leaf_rects <- sb$rects[sb$rects$is_leaf, ]
  expect_equal(nrow(leaf_rects), 3)  # a1, a2, B
  leaf_names <- sort(leaf_rects$name)
  expect_equal(leaf_names, c("B", "a1", "a2"))
})

test_that("sunburst_data() with data.tree and explicit type", {
  dt <- make_dt()
  sb <- sunburst_data(dt, type = "datatree")
  expect_s3_class(sb, "sunburst_data")
})

# --- Custom fields as attributes ---

test_that("data.tree custom fields become node attributes", {
  root <- data.tree::Node$new("root_node")
  a <- root$AddChild("A")
  a$colour <- "red"
  b <- root$AddChild("B")
  b$colour <- "blue"

  sb <- sunburst_data(root)
  rects <- sb$rects
  a_row <- rects[!is.na(rects$name) & rects$name == "A", ]
  b_row <- rects[!is.na(rects$name) & rects$name == "B", ]
  expect_equal(a_row$colour, "red")
  expect_equal(b_row$colour, "blue")
})

# --- Nested tree ---

test_that("data.tree deeply nested tree converts correctly", {
  root <- data.tree::Node$new("root_node")
  a <- root$AddChild("A")
  b <- a$AddChild("B")
  c <- b$AddChild("C")
  d <- c$AddChild("D")
  root$AddChild("E")

  sb <- sunburst_data(root)
  expect_equal(sum(sb$rects$is_leaf), 2)  # D and E
})

# --- Params stored ---

test_that("sunburst_data() with data.tree stores type in params", {
  dt <- make_dt()
  sb <- sunburst_data(dt)
  expect_equal(attr(sb, "params")$type, "datatree")
})

# --- Non-scalar custom fields ---

test_that("data.tree non-scalar fields are silently excluded", {
  skip_if_not_installed("data.tree")
  root <- data.tree::Node$new("root_node")
  a <- root$AddChild("A")
  a$tags <- c("x", "y", "z")  # vector, not scalar
  a$colour <- "red"  # scalar, should be kept

  sb <- sunburst_data(root)
  a_row <- sb$rects[!is.na(sb$rects$name) & sb$rects$name == "A", ]
  expect_true("colour" %in% names(a_row))
  # tags should NOT be in the output (non-scalar)
  expect_false("tags" %in% names(a_row))
})
