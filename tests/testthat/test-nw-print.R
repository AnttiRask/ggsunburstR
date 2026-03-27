# tests/testthat/test-nw-print.R

# --- Produces output ---

test_that("nw_print() produces output for simple tree", {
  expect_output(nw_print("(A, B, C);"))
})

test_that("nw_print() output mentions tip count", {
  out <- capture.output(nw_print("(A, B, C);"))
  # ape's print.phylo includes "3 tips"
  expect_true(any(grepl("3 tip", out)))
})

# --- File input ---

test_that("nw_print() accepts file path", {
  tmp <- tempfile(fileext = ".nw")
  writeLines("(A, B, C);", tmp)
  on.exit(unlink(tmp))
  expect_output(nw_print(tmp))
})

# --- Ladderize ---

test_that("nw_print() with ladderize runs without error", {
  expect_output(nw_print("((a, b), c);", ladderize = TRUE))
})

test_that("nw_print() with ladderize = 'left' runs without error", {
  expect_output(nw_print("((a, b), c);", ladderize = "left"))
})

# --- Returns invisible NULL ---

test_that("nw_print() returns invisible NULL", {
  result <- withVisible(capture.output(res <- nw_print("(A, B);")))
  expect_null(res)
})

# --- Invalid input ---

test_that("nw_print() errors on invalid Newick", {
  expect_error(nw_print("not newick"), class = "rlang_error")
})
