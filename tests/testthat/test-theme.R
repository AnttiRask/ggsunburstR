# tests/testthat/test-theme.R

# --- Returns theme ---

test_that("theme_sunburst() returns a ggplot2 theme", {
  th <- theme_sunburst()
  expect_s3_class(th, "theme")
  expect_s3_class(th, "gg")
})

# --- Title centred and bold ---

test_that("theme_sunburst() centres title and makes it bold", {
  th <- theme_sunburst()
  expect_equal(th$plot.title$hjust, 0.5)
  expect_equal(th$plot.title$face, "bold")
})

# --- Legend at bottom ---

test_that("theme_sunburst() places legend at bottom", {
  th <- theme_sunburst()
  expect_equal(th$legend.position, "bottom")
})

# --- Plot margins ---

test_that("theme_sunburst() sets 5px plot margins", {
  th <- theme_sunburst()
  expected <- ggplot2::margin(5, 5, 5, 5)
  expect_equal(th$plot.margin, expected)
})

# --- Composable with sunburst ---

test_that("theme_sunburst() composes with sunburst()", {
  sb <- sunburst_data("((a, b, c), (d, e));")
  p <- sunburst(sb, fill = "depth") + theme_sunburst()
  expect_s3_class(p, "ggplot")
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- base_size passes through ---

test_that("theme_sunburst() passes base_size to theme_void", {
  th <- theme_sunburst(base_size = 14)
  # The 'text' element inherits base_size from theme_void()
  expect_equal(th$text$size, 14)
})

# --- base_family passes through ---

test_that("theme_sunburst() passes base_family to theme_void", {
  th <- theme_sunburst(base_family = "serif")
  expect_equal(th$text$family, "serif")
})

# --- Title bottom margin ---

test_that("theme_sunburst() sets title bottom margin", {
  th <- theme_sunburst()
  expect_equal(as.numeric(th$plot.title$margin[3]), 10)
})
