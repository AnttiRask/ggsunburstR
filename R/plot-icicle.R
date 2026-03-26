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
                   show_labels = FALSE, ...) {
  # Input validation
  if (!inherits(sb, "sunburst_data")) {
    abort("'sb' must be a sunburst_data object. Use sunburst_data() to create one.")
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

  # Horizontal labels (no rotation) for icicle
  if (show_labels && nrow(sb$leaf_labels) > 0) {
    p <- p +
      ggplot2::geom_text(
        data = sb$leaf_labels,
        ggplot2::aes(
          x = .data[["x"]], y = .data[["y"]],
          label = .data[["label"]]
        ),
        size = 3
      )
  }

  # Root at top, leaves at bottom
  p + ggplot2::scale_y_reverse() + ggplot2::theme_void()
}
