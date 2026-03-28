#' Create a polar sunburst plot
#'
#' Creates a sunburst (radial) plot from a `sunburst_data` object using
#' `ggplot2::geom_rect()` with `coord_polar()` and `theme_void()`.
#'
#' @param sb A `sunburst_data` object from `sunburst_data()`.
#' @param fill Column name in `sb$rects` to map to fill aesthetic. When
#'   `NULL`, a static grey fill is used.
#' @param colour Border colour for rectangles. Default `"white"`.
#' @param linewidth Border line width. Default `0.2`.
#' @param show_labels Whether to add text labels for leaf nodes.
#'   Default `FALSE`.
#' @param show_node_labels Whether to add text labels for internal nodes.
#'   Only takes effect when `show_labels = TRUE`. Default `FALSE`.
#' @param label_type Label orientation. `"radial"`: text reads outward.
#'   `"perpendicular"`: text follows the arc.
#' @param label_size Text size for labels. Default `3`.
#' @param min_label_angle Minimum angular extent (degrees) for a node to
#'   receive a label. Nodes with `delta_angle < min_label_angle` are not
#'   labelled. Default `0` (no filtering).
#' @param ... Passed to `geom_rect()`.
#'
#' @return A `ggplot` object with `coord_polar()` and `theme_void()`.
#'
#' @examples
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' sunburst(sb)
#' sunburst(sb, fill = "depth")
#' sunburst(sb, show_labels = TRUE, label_type = "perpendicular")
#'
#' @export
sunburst <- function(sb, fill = NULL, colour = "white", linewidth = 0.2,
                     show_labels = FALSE, show_node_labels = FALSE,
                     label_type = c("radial", "perpendicular"),
                     label_size = 3, min_label_angle = 0, ...) {
  # Input validation
  if (!inherits(sb, "sunburst_data")) {
    abort("'sb' must be a sunburst_data object. Use sunburst_data() to create one.")
  }

  label_type <- match.arg(label_type)

  if (!is.numeric(min_label_angle) || min_label_angle < 0) {
    abort("'min_label_angle' must be a non-negative number.")
  }

  # Validate fill column
  if (!is.null(fill) && !fill %in% names(sb$rects)) {
    abort("Column '{fill}' not found in sunburst data.")
  }

  # Build the base plot
  if (is.null(fill)) {
    # Static fill — no aesthetic mapping
    p <- ggplot2::ggplot(sb$rects) +
      ggplot2::geom_rect(
        ggplot2::aes(
          xmin = .data[["xmin"]], xmax = .data[["xmax"]],
          ymin = .data[["ymin"]], ymax = .data[["ymax"]]
        ),
        fill = "grey80", colour = colour, linewidth = linewidth, ...
      )
  } else {
    # Mapped fill
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

  # Add leaf labels if requested
  if (show_labels && nrow(sb$leaf_labels) > 0) {
    leaf_data <- .filter_by_angle(sb$leaf_labels, min_label_angle)

    if (nrow(leaf_data) > 0) {
      if (label_type == "perpendicular") {
        # Perpendicular: arc-following labels at radial midpoint
        p <- p +
          ggplot2::geom_text(
            data = leaf_data,
            ggplot2::aes(
              x = .data[["x"]],
              y = (.data[["ymin"]] + .data[["ymax"]]) / 2,
              label = .data[["label"]],
              angle = .data[["pangle"]],
              vjust = .data[["pvjust"]]
            ),
            size = label_size, hjust = 0.5
          )
      } else {
        # Radial: text reads outward from centre
        p <- p +
          ggplot2::geom_text(
            data = leaf_data,
            ggplot2::aes(
              x = .data[["x"]], y = .data[["y"]],
              label = .data[["label"]],
              angle = .data[["angle"]],
              hjust = .data[["hjust"]]
            ),
            size = label_size, vjust = 0.5
          )
      }
    }
  }

  # Add internal node labels if requested
  if (show_labels && show_node_labels && nrow(sb$node_labels) > 0) {
    node_data <- .filter_by_angle(sb$node_labels, min_label_angle)

    if (nrow(node_data) > 0) {
      if (label_type == "perpendicular") {
        p <- p +
          ggplot2::geom_text(
            data = node_data,
            ggplot2::aes(
              x = .data[["x"]],
              y = .data[["y"]],
              label = .data[["label"]],
              angle = .data[["pangle"]],
              vjust = .data[["pvjust"]]
            ),
            size = label_size, hjust = 0.5
          )
      } else {
        p <- p +
          ggplot2::geom_text(
            data = node_data,
            ggplot2::aes(
              x = .data[["x"]],
              y = .data[["y"]],
              label = .data[["label"]],
              angle = .data[["rangle"]],
              hjust = .data[["rhjust"]]
            ),
            size = label_size, vjust = 0.5
          )
      }
    }
  }

  # Apply coord_polar and theme_void
  p + ggplot2::coord_polar() + ggplot2::theme_void()
}
