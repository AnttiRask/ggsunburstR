# tests/testthat/test-detect-input.R

# --- Data.frame ---

test_that("detect_input_type() returns 'dataframe' for data.frame input", {
  df <- data.frame(parent = c(NA, "root"), child = c("root", "A"))
  expect_equal(detect_input_type(df), "dataframe")
})

test_that("detect_input_type() returns 'dataframe' for data.frame with 'node' col", {
  df <- data.frame(parent = c(NA, "root"), node = c("root", "A"))
  expect_equal(detect_input_type(df), "dataframe")
})

# --- Newick string ---

test_that("detect_input_type() returns 'newick' for Newick string", {
  expect_equal(detect_input_type("(A, B, C);"), "newick")
})

test_that("detect_input_type() returns 'newick' for nested Newick string", {
  expect_equal(detect_input_type("((A:0.1, B:0.2):0.3, C);"), "newick")
})

# --- File sniffing ---

test_that("detect_input_type() returns 'node_parent' for CSV with node/parent header", {
  tmp <- tempfile(fileext = ".csv")
  writeLines(c("node,parent", "A,root"), tmp)
  on.exit(unlink(tmp))
  expect_equal(detect_input_type(tmp), "node_parent")
})

test_that("detect_input_type() returns 'newick' for file starting with '('", {
  tmp <- tempfile(fileext = ".nw")
  writeLines("(A, B, C);", tmp)
  on.exit(unlink(tmp))
  expect_equal(detect_input_type(tmp), "newick")
})

test_that("detect_input_type() returns 'lineage' for tab-delimited file", {
  tmp <- tempfile(fileext = ".tsv")
  writeLines(c("A\tB\tC", "A\tB\tD"), tmp)
  on.exit(unlink(tmp))
  expect_equal(detect_input_type(tmp), "lineage")
})

# --- Error cases ---

test_that("detect_input_type() errors on numeric input", {
  expect_error(detect_input_type(42), class = "rlang_error")
})

test_that("detect_input_type() errors on unrecognisable string", {
  expect_error(detect_input_type("just a plain string"), class = "rlang_error")
})
