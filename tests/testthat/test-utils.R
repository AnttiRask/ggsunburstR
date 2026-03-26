# tests/testthat/test-utils.R

# --- rangle() ---

test_that("rangle() leaves right-side angles unchanged", {
  expect_equal(rangle(0), 0)
  expect_equal(rangle(45), 45)
  expect_equal(rangle(89), 89)
})

test_that("rangle() flips left-side angles by 180", {
  expect_equal(rangle(180), 360)  # cos(180°) = -1, so flip
  expect_equal(rangle(225), 405)
  # 270° is a boundary case: cos(270°) ≈ 0 (floating point may be < 0)
  expect_true(rangle(270) %in% c(270, 450))
})

# --- pangle() ---

test_that("pangle() subtracts 90 for upper half (sin >= 0)", {
  expect_equal(pangle(45), -45)
  expect_equal(pangle(90), 0)
})

test_that("pangle() adds 90 for lower half (sin < 0)", {
  expect_equal(pangle(225), 315)
  expect_equal(pangle(270), 360)  # sin(270°) = -1
})

# --- hjust_rtext() ---

test_that("hjust_rtext() returns 0 for right side", {
  expect_equal(hjust_rtext(0), 0)
  expect_equal(hjust_rtext(45), 0)
})

test_that("hjust_rtext() returns 1 for left side", {
  expect_equal(hjust_rtext(180), 1)
  expect_equal(hjust_rtext(225), 1)
})

# --- vjust_ptext() ---

test_that("vjust_ptext() returns 1 for upper half (sin >= 0)", {
  expect_equal(vjust_ptext(45), 1)
  expect_equal(vjust_ptext(90), 1)
})

test_that("vjust_ptext() returns 0 for lower half (sin < 0)", {
  expect_equal(vjust_ptext(225), 0)
  expect_equal(vjust_ptext(270), 0)
})

# --- hjust_ptext() and vjust_rtext() ---

test_that("hjust_ptext() always returns 0.5", {
  expect_equal(hjust_ptext(0), 0.5)
  expect_equal(hjust_ptext(180), 0.5)
})

test_that("vjust_rtext() always returns 0.5", {
  expect_equal(vjust_rtext(0), 0.5)
  expect_equal(vjust_rtext(180), 0.5)
})
