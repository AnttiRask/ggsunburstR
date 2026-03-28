# Helper: standard test data with 3 depths (0 = root, 1, 2)
make_sb <- function() {
  sunburst_data("((a, b, c), (d, e));")
}

# --- sunburst_multifill ---

test_that("sunburst_multifill() returns a ggplot with coord_polar", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  p <- sunburst_multifill(sb, fills = list("1" = "name"))
  expect_s3_class(p, "ggplot")
  # Check coord_polar is applied
  expect_true(inherits(p$coordinates, "CoordPolar"))
})

test_that("sunburst_multifill() creates fill-mapped layer for specified depth", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  # Depth 2 has 5 uniquely named leaves — fill mapping produces distinct colours
  p <- sunburst_multifill(sb, fills = list("2" = "name"))
  built <- ggplot2::ggplot_build(p)
  layer_fills <- lapply(built$data, function(d) unique(d$fill))
  has_mapped <- any(vapply(layer_fills, function(f) length(f) > 1, logical(1)))
  expect_true(has_mapped)
})

test_that("sunburst_multifill() renders unspecified depths with grey", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  # Only fill depth 2 — depth 1 should be grey (root depth 0 not in rects)
  p <- sunburst_multifill(sb, fills = list("2" = "name"))
  # 2 depths in rects (1 and 2) → 2 geom_rect layers (1 grey + 1 fill-mapped)
  n_rect_layers <- sum(vapply(
    p$layers, function(l) inherits(l$geom, "GeomRect"), logical(1)
  ))
  expect_equal(n_rect_layers, 2)
  # The grey layer (depth 1) should have uniform fill
  built <- ggplot2::ggplot_build(p)
  # First layer is depth 1 (grey), second is depth 2 (mapped)
  expect_equal(length(unique(built$data[[1]]$fill)), 1)
})

test_that("sunburst_multifill() handles multiple fill-mapped depths", {
  skip_if_not_installed("ggnewscale")
  # Use a tree with named internal nodes for multi-depth testing
  sb <- sunburst_data("((a, b)X, (c, d)Y);")
  p <- sunburst_multifill(sb, fills = list("1" = "name", "2" = "name"))
  built <- ggplot2::ggplot_build(p)
  # Both depth 1 (X, Y) and depth 2 (a, b, c, d) have distinct names
  layer_fills <- lapply(built$data, function(d) unique(d$fill))
  n_mapped <- sum(vapply(layer_fills, function(f) length(f) > 1, logical(1)))
  expect_gte(n_mapped, 2)
})

# --- icicle_multifill ---

test_that("icicle_multifill() returns a ggplot without coord_polar", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  p <- icicle_multifill(sb, fills = list("1" = "name"))
  expect_s3_class(p, "ggplot")
  # Should NOT have coord_polar (icicle is Cartesian)
  expect_false(inherits(p$coordinates, "CoordPolar"))
})

test_that("icicle_multifill() uses scale_y_reverse", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  p <- icicle_multifill(sb, fills = list("1" = "name"))
  built <- ggplot2::ggplot_build(p)
  expect_true(built$layout$panel_scales_y[[1]]$trans$name == "reverse")
})

test_that("icicle_multifill() renders unspecified depths with grey", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  p <- icicle_multifill(sb, fills = list("2" = "name"))
  built <- ggplot2::ggplot_build(p)
  # First layer (depth 1, grey) should have uniform fill
  expect_equal(length(unique(built$data[[1]]$fill)), 1)
})

test_that("icicle_multifill() creates fill-mapped layers", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  p <- icicle_multifill(sb, fills = list("2" = "name"))
  built <- ggplot2::ggplot_build(p)
  layer_fills <- lapply(built$data, function(d) unique(d$fill))
  has_mapped <- any(vapply(layer_fills, function(f) length(f) > 1, logical(1)))
  expect_true(has_mapped)
})

# --- Input validation ---

test_that("sunburst_multifill() errors for non-sunburst_data input", {
  skip_if_not_installed("ggnewscale")
  expect_error(sunburst_multifill(42, fills = list("1" = "name")),
               "sunburst_data")
})

test_that("sunburst_multifill() errors when fills is not a named list", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  expect_error(sunburst_multifill(sb, fills = c("name")), "named list")
  expect_error(sunburst_multifill(sb, fills = list("name")), "named list")
})

test_that("sunburst_multifill() errors for invalid depth in fills", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  expect_error(sunburst_multifill(sb, fills = list("99" = "name")),
               "depth")
})

test_that("sunburst_multifill() errors for nonexistent fill column", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  expect_error(sunburst_multifill(sb, fills = list("1" = "nonexistent")),
               "not found")
})

test_that("icicle_multifill() validates inputs", {
  skip_if_not_installed("ggnewscale")
  expect_error(icicle_multifill(42, fills = list("1" = "name")),
               "sunburst_data")
})

# --- colour and linewidth pass-through ---

test_that("sunburst_multifill() passes colour and linewidth to layers", {
  skip_if_not_installed("ggnewscale")
  sb <- make_sb()
  p <- sunburst_multifill(sb, fills = list("2" = "name"),
                          colour = "red", linewidth = 0.5)
  built <- ggplot2::ggplot_build(p)
  expect_true(all(built$data[[1]]$colour == "red"))
  expect_true(all(built$data[[1]]$linewidth == 0.5))
})
