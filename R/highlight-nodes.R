#' Highlight specific nodes in a sunburst or icicle plot
#'
#' Adds a `geom_rect()` layer on top of an existing plot to visually
#' emphasise specific nodes. Works with both `sunburst()` and `icicle()`
#' plots.
#'
#' @param p A ggplot object produced by `sunburst()` or `icicle()`.
#' @param nodes Character vector of node names or integer vector of
#'   node IDs to highlight.
#' @param fill Fill colour for highlighted nodes. Default `"gold"`.
#' @param colour Border colour for highlighted nodes. Default `"black"`.
#' @param linewidth Border line width for highlighted nodes. Default `0.5`.
#'
#' @return The input ggplot object with an additional highlight layer.
#'
#' @examples
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' p <- sunburst(sb, fill = "depth")
#' highlight_nodes(p, nodes = c("a", "c"), fill = "red")
#'
#' @export
highlight_nodes <- function(p, nodes, fill = "gold", colour = "black",
                            linewidth = 0.5) {
  rects <- p$data

  # Filter to matching nodes — by name or node_id

  if (is.character(nodes)) {
    highlight_data <- rects[!is.na(rects$name) & rects$name %in% nodes, ,
                            drop = FALSE]
  } else if (is.integer(nodes) || is.numeric(nodes)) {
    highlight_data <- rects[rects$node_id %in% as.integer(nodes), ,
                            drop = FALSE]
  } else {
    abort("'nodes' must be a character vector of names or an integer vector of node IDs.")
  }

  if (nrow(highlight_data) == 0) {
    warn("No matching nodes found for highlighting.")
    return(p)
  }

  p +
    ggplot2::geom_rect(
      data = highlight_data,
      ggplot2::aes(
        xmin = .data[["xmin"]], xmax = .data[["xmax"]],
        ymin = .data[["ymin"]], ymax = .data[["ymax"]]
      ),
      fill = fill, colour = colour, linewidth = linewidth,
      inherit.aes = FALSE
    )
}
