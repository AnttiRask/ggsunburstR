#' Create a tree-style dendrogram plot
#'
#' Creates a classical node-link tree diagram (dendrogram) using
#' `geom_segment()` from the segment data in a `sunburst_data` object.
#'
#' @note The Bioconductor package `ggtree` also exports a `ggtree()`
#'   function. If both packages are loaded, use `ggsunburstR::ggtree()`
#'   to disambiguate.
#'
#' @param sb A `sunburst_data` object from `sunburst_data()`.
#' @param colour Line colour for tree segments. Default `"black"`.
#' @param linewidth Line width for tree segments. Default `0.5`.
#' @param show_labels Whether to display leaf labels. Default `TRUE`.
#' @param label_size Text size for leaf labels. Default `3`.
#' @param label_colour Text colour for leaf labels. Default `"black"`.
#' @param rotate If `TRUE` (default), apply `coord_flip()` for horizontal
#'   layout (root left, leaves right).
#' @param polar If `TRUE`, apply `coord_polar()` for circular layout.
#'   Overrides `rotate`.
#' @param blank If `TRUE` (default), apply `theme_void()`.
#' @param ... Passed to `geom_segment()`.
#'
#' @return A `ggplot` object.
#'
#' @seealso [sunburst()] for polar sunburst plots, [icicle()] for
#'   rectangular layouts.
#'
#' @examples
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' ggtree(sb)
#' ggtree(sb, polar = TRUE)
#'
#' @export
ggtree <- function(sb, colour = "black", linewidth = 0.5,
                   show_labels = TRUE, label_size = 3,
                   label_colour = "black",
                   rotate = TRUE, polar = FALSE, blank = TRUE,
                   ...) {
  if (!inherits(sb, "sunburst_data")) {
    abort("'sb' must be a sunburst_data object. Use sunburst_data() to create one.")
  }

  seg <- sb$segments

  # Base plot
  p <- ggplot2::ggplot(data = seg)

  # 1. Horizontal branches (connecting children at parent level)
  p <- p +
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data[["px"]], xend = .data[["pxend"]],
        y = .data[["ryend"]], yend = .data[["ryend"]]
      ),
      na.rm = TRUE, linewidth = linewidth, colour = colour,
      lineend = "square", ...
    )

  # 2. Vertical branches (parent to child level)
  p <- p +
    ggplot2::geom_segment(
      ggplot2::aes(
        x = .data[["rx"]], xend = .data[["rx"]],
        y = .data[["ry"]], yend = .data[["ryend"]]
      ),
      na.rm = TRUE, linewidth = linewidth, colour = colour,
      lineend = "square", ...
    )

  # 3. Labels
  if (polar && show_labels) {
    # Polar mode: leader lines + rotated labels
    y_max <- max(seg$ryend, na.rm = TRUE)
    p <- p +
      ggplot2::geom_segment(
        data = sb$leaf_labels,
        ggplot2::aes(
          x = .data[["x"]], xend = .data[["x"]],
          y = .data[["y"]], yend = y_max
        ),
        linewidth = linewidth / 2, colour = "grey40",
        linetype = "dotted",
        inherit.aes = FALSE
      ) +
      ggplot2::geom_text(
        data = sb$leaf_labels,
        ggplot2::aes(
          x = .data[["x"]], y = y_max + 0.1,
          label = .data[["label"]],
          angle = .data[["angle"]], hjust = .data[["hjust"]]
        ),
        size = label_size, colour = label_colour,
        inherit.aes = FALSE
      ) +
      ggplot2::xlim(0.5, nrow(sb$leaf_labels) + 0.5)
  } else if (!polar && show_labels) {
    # Non-polar: horizontal labels beyond leaf endpoints
    y_out <- max(seg$ryend, na.rm = TRUE) + 0.1
    p <- p +
      ggplot2::geom_text(
        data = sb$leaf_labels,
        ggplot2::aes(
          x = .data[["x"]], y = y_out,
          label = .data[["label"]]
        ),
        size = label_size, colour = label_colour, hjust = 0,
        inherit.aes = FALSE
      )
  }

  # 4. Coordinate transform
  if (polar) {
    p <- p + ggplot2::coord_polar()
  } else if (rotate) {
    p <- p + ggplot2::coord_flip()
  }

  # 5. Theme
  if (blank) {
    p <- p + ggplot2::theme_void()
  }

  p + ggplot2::xlab("") + ggplot2::ylab("")
}
