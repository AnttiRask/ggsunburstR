#' Create a donut (ring) chart
#'
#' Creates a donut chart — a sunburst restricted to the outermost 1–N
#' depth levels. The centre hole is created by shifting Y coordinates
#' so the innermost displayed ring has `ymin > 0`.
#'
#' @param sb A `sunburst_data` object from `sunburst_data()`.
#' @param levels Number of depth levels to display (from the outermost
#'   inward). `1` = single ring, `2` = two concentric rings.
#' @param fill Column name to map to fill aesthetic. `NULL` for static grey.
#' @param colour Border colour for segments. Default `"white"`.
#' @param linewidth Border line width. Default `0.2`.
#' @param show_labels Whether to display labels. Default `FALSE`.
#' @param hole_size Size of the centre hole. Higher = larger hole relative
#'   to ring thickness. Default `1`.
#' @param ... Passed to `geom_rect()`.
#'
#' @return A `ggplot` object with `coord_polar()` and `theme_void()`.
#'
#' @examples
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' donut(sb, fill = "name")
#' donut(sb, levels = 2, fill = "depth")
#'
#' @export
donut <- function(sb, levels = 1, fill = NULL, colour = "white",
                  linewidth = 0.2, show_labels = FALSE,
                  hole_size = 1, ...) {
  if (!inherits(sb, "sunburst_data")) {
    abort("'sb' must be a sunburst_data object. Use sunburst_data() to create one.")
  }

  if (!is.null(fill) && !fill %in% names(sb$rects)) {
    abort("Column '{fill}' not found in sunburst data.")
  }

  # Filter to requested depth levels (outermost N levels)
  max_depth <- max(sb$rects$depth)
  min_depth <- max(1L, max_depth - as.integer(levels) + 1L)
  donut_rects <- sb$rects[sb$rects$depth >= min_depth, , drop = FALSE]

  # Adjust Y to create the donut hole
  y_shift <- -min(donut_rects$ymin) + hole_size
  donut_rects$ymin <- donut_rects$ymin + y_shift
  donut_rects$ymax <- donut_rects$ymax + y_shift

  # Build plot
  if (is.null(fill)) {
    p <- ggplot2::ggplot(donut_rects) +
      ggplot2::geom_rect(
        ggplot2::aes(
          xmin = .data[["xmin"]], xmax = .data[["xmax"]],
          ymin = .data[["ymin"]], ymax = .data[["ymax"]]
        ),
        fill = "grey80", colour = colour, linewidth = linewidth, ...
      )
  } else {
    p <- ggplot2::ggplot(donut_rects) +
      ggplot2::geom_rect(
        ggplot2::aes(
          xmin = .data[["xmin"]], xmax = .data[["xmax"]],
          ymin = .data[["ymin"]], ymax = .data[["ymax"]],
          fill = .data[[fill]]
        ),
        colour = colour, linewidth = linewidth, ...
      )
  }

  # Labels — filter to nodes in the donut, adjust y positions
  if (show_labels) {
    donut_labels <- sb$leaf_labels[
      sb$leaf_labels$node_id %in% donut_rects$node_id, , drop = FALSE
    ]
    if (nrow(donut_labels) > 0) {
      donut_labels$y <- donut_labels$y + y_shift
      p <- p +
        ggplot2::geom_text(
          data = donut_labels,
          ggplot2::aes(
            x = .data[["x"]], y = .data[["y"]],
            label = .data[["label"]],
            angle = .data[["angle"]],
            hjust = .data[["hjust"]]
          ),
          size = 3, vjust = 0.5,
          inherit.aes = FALSE
        )
    }
  }

  p + ggplot2::coord_polar() + ggplot2::theme_void()
}
