# tests/testthat/test-plot-sunburst.R

# Shared test data
make_sb <- function() {
  sunburst_data("((a, b, c), (d, e));")
}

# --- Returns ggplot ---

test_that("sunburst() returns a ggplot object", {
  sb <- make_sb()
  p <- sunburst(sb)
  expect_s3_class(p, "ggplot")
})

# --- Has coord_polar ---

test_that("sunburst() uses coord_polar", {
  sb <- make_sb()
  p <- sunburst(sb)
  # coord_polar is stored in p$coordinates
  expect_s3_class(p$coordinates, "CoordPolar")
})

# --- Static fill default ---

test_that("sunburst() with default fill renders without error", {
  sb <- make_sb()
  p <- sunburst(sb)
  # Should be buildable without error
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- String fill mapping ---

test_that("sunburst() with fill = 'depth' maps fill aesthetic", {
  sb <- make_sb()
  p <- sunburst(sb, fill = "depth")
  built <- ggplot2::ggplot_build(p)
  # The fill should vary (not all the same)
  expect_true(length(unique(built$data[[1]]$fill)) > 1)
})

test_that("sunburst() with fill = 'name' works", {
  sb <- make_sb()
  p <- sunburst(sb, fill = "name")
  expect_no_error(ggplot2::ggplot_build(p))
})

# --- Non-existent fill column errors ---

test_that("sunburst() errors on non-existent fill column", {
  sb <- make_sb()
  expect_error(sunburst(sb, fill = "nonexistent"), class = "rlang_error")
})

# --- Input validation ---

test_that("sunburst() errors on non-sunburst_data input", {
  expect_error(sunburst(data.frame(x = 1)), class = "rlang_error")
})

# --- show_labels ---

test_that("sunburst() with show_labels adds geom_text layer", {
  sb <- make_sb()
  p_no <- sunburst(sb)
  p_yes <- sunburst(sb, show_labels = TRUE)
  # Count layers: with labels should have one more
  expect_true(length(p_yes$layers) > length(p_no$layers))
})

# --- theme_void ---

test_that("sunburst() applies theme_void", {
  sb <- make_sb()
  p <- sunburst(sb)
  # theme_void sets panel.border, axis.line etc to element_blank
  expect_true(inherits(p$theme$line, "element_blank") ||
              inherits(p$theme$axis.line, "element_blank") ||
              length(p$theme) > 0)
})

# --- label_type = "perpendicular" ---

test_that("sunburst() with label_type = 'perpendicular' adds a geom_text layer", {
  sb <- make_sb()
  p <- sunburst(sb, show_labels = TRUE, label_type = "perpendicular")
  # Should have at least one more layer than the base (geom_rect)
  built <- ggplot2::ggplot_build(p)
  expect_true(length(p$layers) >= 2)
})
test_that("sunburst() perpendicular labels use pangle for angle", {
  sb <- make_sb()
  p <- sunburst(sb, show_labels = TRUE, label_type = "perpendicular")
  built <- ggplot2::ggplot_build(p)
  # Label layer is the second layer (first = geom_rect)
  label_data <- built$data[[2]]
  # pangle values should differ from radial angle values
  p_radial <- sunburst(sb, show_labels = TRUE, label_type = "radial")
  built_r <- ggplot2::ggplot_build(p_radial)
  radial_angles <- built_r$data[[2]]$angle
  perp_angles <- label_data$angle
  # They must not all be the same

  expect_false(all(radial_angles == perp_angles))
})

test_that("sunburst() perpendicular labels positioned at radial midpoint", {
  sb <- make_sb()
  p <- sunburst(sb, show_labels = TRUE, label_type = "perpendicular")
  built <- ggplot2::ggplot_build(p)
  label_data <- built$data[[2]]
  # The y values should be midpoints (ymin + ymax) / 2, not ymax
  # Compare against radial y values which use ymax
  p_radial <- sunburst(sb, show_labels = TRUE, label_type = "radial")
  built_r <- ggplot2::ggplot_build(p_radial)
  radial_y <- built_r$data[[2]]$y
  perp_y <- label_data$y
  # Perpendicular y should be smaller (midpoint < outer edge)
  expect_true(all(perp_y < radial_y))
})

# --- show_node_labels ---

test_that("sunburst() with show_node_labels = TRUE adds node label layer", {
  sb <- make_sb()
  p_leaf <- sunburst(sb, show_labels = TRUE)
  p_both <- sunburst(sb, show_labels = TRUE, show_node_labels = TRUE)
  expect_equal(length(p_both$layers), length(p_leaf$layers) + 1)
})

test_that("sunburst() show_node_labels without show_labels has no effect", {
  sb <- make_sb()
  p_no <- sunburst(sb)
  p_nodes <- sunburst(sb, show_node_labels = TRUE)
  # show_node_labels alone should not add layers (need show_labels = TRUE)
  expect_equal(length(p_nodes$layers), length(p_no$layers))
})

# --- label_size ---

test_that("sunburst() label_size controls text size", {
  sb <- make_sb()
  p <- sunburst(sb, show_labels = TRUE, label_size = 5)
  built <- ggplot2::ggplot_build(p)
  label_data <- built$data[[2]]
  expect_true(all(label_data$size == 5))
})

test_that("sunburst() label_size applies to both leaf and node labels", {
  sb <- make_sb()
  p <- sunburst(sb, show_labels = TRUE, show_node_labels = TRUE, label_size = 4)
  built <- ggplot2::ggplot_build(p)
  # Leaf layer (2nd) and node layer (3rd) both use size = 4
  expect_true(all(built$data[[2]]$size == 4))
  expect_true(all(built$data[[3]]$size == 4))
})

# --- min_label_angle ---

test_that("sunburst() min_label_angle = 0 shows all labels", {
  sb <- make_sb()
  p <- sunburst(sb, show_labels = TRUE, min_label_angle = 0)
  built <- ggplot2::ggplot_build(p)
  # All 5 leaves should have labels
  expect_equal(nrow(built$data[[2]]), 5)
})

test_that("sunburst() min_label_angle filters narrow sectors", {
  sb <- make_sb()
  # With 5 equal-weight leaves in 360°, each has delta_angle = 72°
  # Setting min to 100 should remove all labels — no label layer added
  p_all <- sunburst(sb, show_labels = TRUE, min_label_angle = 0)
  p_filtered <- sunburst(sb, show_labels = TRUE, min_label_angle = 100)
  # Filtered plot should have fewer layers (no label layer)
  expect_true(length(p_filtered$layers) < length(p_all$layers))
})

test_that("sunburst() min_label_angle filters node labels too", {
  sb <- make_sb()
  # With tree "((a, b, c), (d, e));":
  # Internal node with 3 leaves: delta_angle = 3/5 * 360 = 216
  # Internal node with 2 leaves: delta_angle = 2/5 * 360 = 144
  # min_label_angle = 200 filters all leaf labels (72°) and keeps only
  # the 3-leaf node label (216°). Node layer is the last data layer.
  p <- sunburst(sb, show_labels = TRUE, show_node_labels = TRUE,
                min_label_angle = 200)
  built <- ggplot2::ggplot_build(p)
  # Last layer is the node labels (leaf layer was omitted due to filtering)
  node_layer <- built$data[[length(built$data)]]
  expect_equal(nrow(node_layer), 1)
})

# --- Input validation ---

test_that("sunburst() errors on negative min_label_angle", {
  sb <- make_sb()
  expect_error(
    sunburst(sb, min_label_angle = -5),
    "non-negative"
  )
})

# --- leaf_labels output includes geometry columns ---

test_that("sunburst_data leaf_labels includes ymin, ymax, delta_angle", {
  sb <- make_sb()
  expect_true("ymin" %in% names(sb$leaf_labels))
  expect_true("ymax" %in% names(sb$leaf_labels))
  expect_true("delta_angle" %in% names(sb$leaf_labels))
  expect_true(all(sb$leaf_labels$delta_angle > 0))
})

# --- plot.sunburst_data dispatches ---

test_that("plot.sunburst_data() dispatches to sunburst()", {
  sb <- make_sb()
  p <- plot(sb)
  expect_s3_class(p, "ggplot")
})

# --- Customisable with + ---

test_that("sunburst() result is customisable with +", {
  sb <- make_sb()
  p <- sunburst(sb, fill = "depth") +
    ggplot2::labs(title = "Test")
  expect_equal(p$labels$title, "Test")
})
