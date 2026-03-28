#' Create a rectangular icicle plot
#'
#' Creates an icicle (rectangular, top-down) plot from a `sunburst_data`
#' object using `ggplot2::geom_rect()` with `scale_y_reverse()` and
#' `theme_void()`.
#'
#' @param sb A `sunburst_data` object from `sunburst_data()`.
#' @param fill Column name in `sb$rects` to map to fill aesthetic. When
#'   `NULL`, a static grey fill is used.
#' @param colour Border colour for rectangles. Default `"white"`.
#' @param linewidth Border line width. Default `0.2`.
#' @param show_labels Whether to add text labels. Default `FALSE`.
#' @param show_node_labels Whether to add text labels for internal nodes.
#'   Only takes effect when `show_labels = TRUE`. Default `FALSE`.
#' @param label_size Text size for labels. Default `3`.
#' @param min_label_angle Minimum angular extent (degrees) for a node to
#'   receive a label. Uses the same `delta_angle` column as sunburst
#'   filtering. Default `0` (no filtering).
#' @param ... Passed to `geom_rect()`.
#'
#' @return A `ggplot` object with `scale_y_reverse()` and `theme_void()`.
#'
#' @examples
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' icicle(sb)
#' icicle(sb, fill = "depth")
#'
#' @export
icicle <- function(sb, fill = NULL, colour = "white", linewidth = 0.2,
                   show_labels = FALSE, show_node_labels = FALSE,
                   label_size = 3, min_label_angle = 0, ...) {
  # Input validation
  if (!inherits(sb, "sunburst_data")) {
    abort("'sb' must be a sunburst_data object. Use sunburst_data() to create one.")
  }

  if (!is.numeric(min_label_angle) || min_label_angle < 0) {
    abort("'min_label_angle' must be a non-negative number.")
  }

  # Validate fill column
  if (!is.null(fill) && !fill %in% names(sb$rects)) {
    abort("Column '{fill}' not found in sunburst data.")
  }

  # Build the base plot
  if (is.null(fill)) {
    p <- ggplot2::ggplot(sb$rects) +
      ggplot2::geom_rect(
        ggplot2::aes(
          xmin = .data[["xmin"]], xmax = .data[["xmax"]],
          ymin = .data[["ymin"]], ymax = .data[["ymax"]]
        ),
        fill = "grey80", colour = colour, linewidth = linewidth, ...
      )
  } else {
    p <- ggplot2::ggplot(sb$rects) +
      ggplot2::geom_rect(
        ggplot2::aes(
          xmin = .data[["xmin"]], xmax = .data[["xmax"]],
          ymin = .data[["ymin"]], ymax = .data[["ymax"]],
          fill = .data[[fill]]
        ),
        colour = colour, linewidth = linewidth, ...
      )
  }

  # Horizontal leaf labels (no rotation) for icicle
  if (show_labels && nrow(sb$leaf_labels) > 0) {
    leaf_data <- sb$leaf_labels
    # Filter by min_label_angle
    if (min_label_angle > 0 && "delta_angle" %in% names(leaf_data)) {
      leaf_data <- leaf_data[leaf_data$delta_angle >= min_label_angle, ]
    }

    if (nrow(leaf_data) > 0) {
      p <- p +
        ggplot2::geom_text(
          data = leaf_data,
          ggplot2::aes(
            x = .data[["x"]], y = .data[["y"]],
            label = .data[["label"]]
          ),
          size = label_size
        )
    }
  }

  # Internal node labels
  if (show_labels && show_node_labels && nrow(sb$node_labels) > 0) {
    node_data <- sb$node_labels
    # Filter by min_label_angle
    if (min_label_angle > 0 && "delta_angle" %in% names(node_data)) {
      node_data <- node_data[node_data$delta_angle >= min_label_angle, ]
    }

    if (nrow(node_data) > 0) {
      p <- p +
        ggplot2::geom_text(
          data = node_data,
          ggplot2::aes(
            x = .data[["x"]], y = .data[["y"]],
            label = .data[["label"]]
          ),
          size = label_size
        )
    }
  }

  # Root at top, leaves at bottom
  p + ggplot2::scale_y_reverse() + ggplot2::theme_void()
}
