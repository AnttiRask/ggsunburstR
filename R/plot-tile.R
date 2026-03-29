#' Add tile (heatmap) annotations to a sunburst or icicle plot
#'
#' Overlays coloured tiles adjacent to leaf nodes, where each tile
#' represents a categorical or continuous variable from node attributes.
#' The fill aesthetic is mapped to the value, allowing users to add
#' `+ scale_fill_*()` after the call.
#'
#' @param p A ggplot object from `sunburst()`, `icicle()`, or `ggtree()`.
#' @param sb The `sunburst_data` object used to create `p`.
#' @param variables Character vector of column names in `sb$rects` to
#'   display as tiles.
#' @param y_offset Vertical offset from the outermost ring. Default `0`.
#' @param tile_height Height of each tile band. Default `1`.
#' @param tile_width Width of each tile. Default `1`.
#' @param colour Border colour for tiles. Default `"white"`.
#' @param linewidth Border line width. Default `0`.
#' @param show_labels Whether to display variable names. Default `FALSE`.
#' @param label_angle Rotation angle for variable labels. Default `90`.
#' @param label_size Text size for variable labels. Default `3`.
#' @param ... Passed to `geom_tile()`.
#'
#' @return The input ggplot with an additional `geom_tile()` layer.
#'
#' @note Since `tile()` maps fill to values, it will conflict with the
#'   fill aesthetic of the base plot. Use a base plot without fill mapping
#'   (e.g., `icicle(sb)`) or `ggnewscale::new_scale_fill()` before calling.
#'
#' @seealso [bars()] for bar chart annotations,
#'   [highlight_nodes()] for node emphasis.
#'
#' @examples
#' df <- data.frame(
#'   parent = c(NA, "root", "root"),
#'   child  = c("root", "A", "B"),
#'   score  = c(NA, 0.5, 0.9)
#' )
#' sb <- sunburst_data(df)
#' p <- icicle(sb)
#' tile(p, sb, variables = "score")
#'
#' @export
tile <- function(p, sb, variables, y_offset = 0, tile_height = 1,
                 tile_width = 1, colour = "white", linewidth = 0,
                 show_labels = FALSE, label_angle = 90,
                 label_size = 3, ...) {
  if (!inherits(p, "ggplot")) {
    abort("'p' must be a ggplot object from sunburst(), icicle(), or ggtree().")
  }
  if (!inherits(sb, "sunburst_data")) {
    abort("'sb' must be a sunburst_data object.")
  }

  # Validate variables exist
  for (var in variables) {
    if (!var %in% names(sb$rects)) {
      cli::cli_abort("Column {.val {var}} not found in sunburst data.")
    }
  }

  # Compute tile data
  tile_data <- .compute_tile_data(sb, variables, y_offset, tile_height)

  # Add geom_tile layer
  p <- p +
    ggplot2::geom_tile(
      data = tile_data,
      ggplot2::aes(
        x = .data[["x"]], y = .data[["tile_y"]],
        fill = .data[["value"]]
      ),
      height = tile_height, width = tile_width,
      colour = colour, linewidth = linewidth,
      inherit.aes = FALSE, ...
    )

  # Optional variable labels
  if (show_labels) {
    label_data <- tile_data[!duplicated(tile_data$variable), , drop = FALSE]
    label_data$label_x <- max(tile_data$x, na.rm = TRUE) + 1
    p <- p +
      ggplot2::geom_text(
        data = label_data,
        ggplot2::aes(
          x = .data[["label_x"]], y = .data[["tile_y"]],
          label = .data[["variable"]]
        ),
        angle = label_angle, hjust = 0, size = label_size,
        inherit.aes = FALSE
      )
  }

  p
}

# Compute tile position data for leaf nodes.
# Returns a data.frame with one row per (leaf x variable).
.compute_tile_data <- function(sb, variables, y_offset, tile_height) {
  leaf_data <- sb$rects[sb$rects$is_leaf, , drop = FALSE]

  # Check if mixing types across variables
  types <- vapply(variables, function(v) {
    if (is.numeric(leaf_data[[v]])) "numeric" else "other"
  }, character(1))

  coerce_to_char <- length(unique(types)) > 1
  if (coerce_to_char) {
    warn("Mixing numeric and non-numeric variables -- coercing all to character.")
  }

  # Reshape to long format
  rows <- lapply(variables, function(var) {
    val <- leaf_data[[var]]
    if (coerce_to_char) val <- as.character(val)
    data.frame(
      node_id  = leaf_data$node_id,
      x        = leaf_data$x,
      variable = var,
      value    = val,
      stringsAsFactors = FALSE
    )
  })
  long <- do.call(rbind, rows)

  # Compute tile Y positions
  long$var_index <- match(long$variable, variables) - 1L
  long$tile_y <- y_offset + long$var_index * tile_height

  long
}
