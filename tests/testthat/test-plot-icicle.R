# tests/testthat/test-plot-icicle.R

make_sb <- function() {
  sunburst_data("((a, b, c), (d, e));")
}

# --- Returns ggplot ---

test_that("icicle() returns a ggplot object", {
  sb <- make_sb()
  p <- icicle(sb)
  expect_s3_class(p, "ggplot")
})

# --- Has scale_y_reverse ---

test_that("icicle() uses scale_y_reverse", {
  sb <- make_sb()
  p <- icicle(sb)
  # scale_y_reverse appears in the y scales
  scales <- p$scales$scales
  has_y_reverse <- any(vapply(scales, function(s) {
    inherits(s, "ScaleContinuousPosition") && s$aesthetics[1] == "y"
  }, logical(1)))
  # Also check via ggplot_build — y axis should be reversed
  built <- ggplot2::ggplot_build(p)
  expect_true(built$layout$panel_scales_y[[1]]$trans$name == "reverse")
})

# --- Static fill default ---

test_that("icicle() with default fill renders without error", {
  sb <- make_sb()
  p <- icicle(sb)
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- String fill mapping ---

test_that("icicle() with fill = 'depth' maps fill aesthetic", {
  sb <- make_sb()
  p <- icicle(sb, fill = "depth")
  built <- ggplot2::ggplot_build(p)
  expect_true(length(unique(built$data[[1]]$fill)) > 1)
})

# --- Non-existent fill column errors ---

test_that("icicle() errors on non-existent fill column", {
  sb <- make_sb()
  expect_error(icicle(sb, fill = "nonexistent"), class = "rlang_error")
})

# --- Input validation ---

test_that("icicle() errors on non-sunburst_data input", {
  expect_error(icicle(data.frame(x = 1)), class = "rlang_error")
})

# --- show_labels ---

test_that("icicle() with show_labels adds geom_text layer", {
  sb <- make_sb()
  p_no <- icicle(sb)
  p_yes <- icicle(sb, show_labels = TRUE)
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- show_node_labels ---

test_that("icicle() with show_node_labels = TRUE adds node label layer", {
  sb <- make_sb()
  p_leaf <- icicle(sb, show_labels = TRUE)
  p_both <- icicle(sb, show_labels = TRUE, show_node_labels = TRUE)
  expect_equal(length(p_both$layers), length(p_leaf$layers) + 1)
})

test_that("icicle() show_node_labels without show_labels has no effect", {
  sb <- make_sb()
  p_no <- icicle(sb)
  p_nodes <- icicle(sb, show_node_labels = TRUE)
  expect_equal(length(p_nodes$layers), length(p_no$layers))
})

# --- label_size ---

test_that("icicle() label_size controls text size", {
  sb <- make_sb()
  p <- icicle(sb, show_labels = TRUE, label_size = 5)
  built <- ggplot2::ggplot_build(p)
  label_data <- built$data[[2]]
  expect_true(all(label_data$size == 5))
})

# --- min_label_angle ---

test_that("icicle() label_size applies to both leaf and node labels", {
  sb <- make_sb()
  p <- icicle(sb, show_labels = TRUE, show_node_labels = TRUE, label_size = 4)
  built <- ggplot2::ggplot_build(p)
  expect_true(all(built$data[[2]]$size == 4))
  expect_true(all(built$data[[3]]$size == 4))
})

test_that("icicle() min_label_angle filters narrow sectors", {
  sb <- make_sb()
  # 5 equal-weight leaves → 72° each. min = 100 filters all.
  p_filtered <- icicle(sb, show_labels = TRUE, min_label_angle = 100)
  built <- ggplot2::ggplot_build(p_filtered)
  # Only 1 data layer (geom_rect) — no label layer added
  expect_equal(length(built$data), 1)
})

test_that("icicle() min_label_angle filters node labels too", {
  sb <- make_sb()
  # 3-leaf node: 216°, 2-leaf node: 144°. min = 200 keeps only the 3-leaf.
  p <- icicle(sb, show_labels = TRUE, show_node_labels = TRUE,
              min_label_angle = 200)
  built <- ggplot2::ggplot_build(p)
  node_layer <- built$data[[length(built$data)]]
  expect_equal(nrow(node_layer), 1)
})

# --- Input validation ---

test_that("icicle() errors on negative min_label_angle", {
  sb <- make_sb()
  expect_error(icicle(sb, min_label_angle = -5), "non-negative")
})

# --- label_repel ---

test_that("icicle() label_repel = FALSE (default) uses geom_text", {
  sb <- make_sb()
  p <- icicle(sb, show_labels = TRUE)
  # Second layer should be GeomText, not GeomTextRepel
  expect_s3_class(p$layers[[2]]$geom, "GeomText")
})

test_that("icicle() label_repel = TRUE uses geom_text_repel", {
  skip_if_not_installed("ggrepel")
  sb <- make_sb()
  p <- icicle(sb, show_labels = TRUE, label_repel = TRUE)
  expect_true(inherits(p$layers[[2]]$geom, "GeomTextRepel"))
})

test_that("icicle() label_repel with show_node_labels uses repel for both layers", {
  skip_if_not_installed("ggrepel")
  sb <- make_sb()
  p <- icicle(sb, show_labels = TRUE, show_node_labels = TRUE,
              label_repel = TRUE)
  # Leaf layer (2nd) and node layer (3rd) both use GeomTextRepel
  expect_true(inherits(p$layers[[2]]$geom, "GeomTextRepel"))
  expect_true(inherits(p$layers[[3]]$geom, "GeomTextRepel"))
})

test_that("icicle() label_repel combined with min_label_angle", {
  skip_if_not_installed("ggrepel")
  sb <- make_sb()
  # 5 equal leaves → 72° each. min = 50 keeps all, repel applied.
  p <- icicle(sb, show_labels = TRUE, label_repel = TRUE,
              min_label_angle = 50)
  built <- ggplot2::ggplot_build(p)
  expect_equal(nrow(built$data[[2]]), 5)
  expect_true(inherits(p$layers[[2]]$geom, "GeomTextRepel"))
})

# --- Customisable with + ---

test_that("icicle() result is customisable with +", {
  sb <- make_sb()
  p <- icicle(sb, fill = "depth") +
    ggplot2::labs(title = "Test Icicle")
  expect_equal(p$labels$title, "Test Icicle")
})
