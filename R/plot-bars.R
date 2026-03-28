#' Add bar chart annotations to a sunburst or icicle plot
#'
#' Overlays bar charts adjacent to leaf nodes, where each bar represents
#' a quantitative variable from node attributes. Values are max-normalised
#' per variable to the 0--1 range.
#'
#' @param p A ggplot object from `sunburst()`, `icicle()`, or `ggtree()`.
#' @param sb The `sunburst_data` object used to create `p`.
#' @param variables Character vector of numeric column names in `sb$rects`
#'   to display as bars.
#' @param y_offset Vertical offset from the outermost ring. Default `0`.
#' @param bar_height Height of each bar band. Default `1`.
#' @param box_colour Outline colour for the outer box. Default `"black"`.
#' @param bar_colour Fill colour for the inner value bar. Default `"black"`.
#' @param show_labels Whether to display variable names. Default `FALSE`.
#' @param show_values Whether to display numeric values inside bars.
#'   Default `FALSE`.
#' @param label_size Text size for variable labels. Default `3`.
#' @param value_size Text size for value labels. Default `2.5`.
#' @param ... Passed to the outer `geom_rect()`.
#'
#' @return The input ggplot with additional bar layers.
#'
#' @seealso `tile()` for heatmap-style annotations,
#'   [highlight_nodes()] for node emphasis.
#'
#' @examples
#' df <- data.frame(
#'   parent = c(NA, "root", "root"),
#'   child  = c("root", "A", "B"),
#'   score  = c(NA, 0.5, 0.9)
#' )
#' sb <- sunburst_data(df)
#' p <- icicle(sb, fill = "depth")
#' bars(p, sb, variables = "score")
#'
#' @export
bars <- function(p, sb, variables, y_offset = 0, bar_height = 1,
                 box_colour = "black", bar_colour = "black",
                 show_labels = FALSE, show_values = FALSE,
                 label_size = 3, value_size = 2.5, ...) {
  if (!inherits(p, "ggplot")) {
    abort("'p' must be a ggplot object from sunburst(), icicle(), or ggtree().")
  }
  if (!inherits(sb, "sunburst_data")) {
    abort("'sb' must be a sunburst_data object.")
  }

  # Validate variables exist and are numeric
  for (var in variables) {
    if (!var %in% names(sb$rects)) {
      abort("Column '{var}' not found in sunburst data.")
    }
    if (!is.numeric(sb$rects[[var]])) {
      abort("Column '{var}' must be numeric for bar display.")
    }
  }

  # Compute bar data
  bar_data <- .compute_bar_data(sb, variables, y_offset, bar_height)

  # 1. Outer box (white fill, coloured border)
  p <- p +
    ggplot2::geom_rect(
      data = bar_data,
      ggplot2::aes(
        xmin = .data[["bar_xmin"]], xmax = .data[["bar_xmax"]],
        ymin = .data[["bar_ymin"]], ymax = .data[["bar_ymax"]]
      ),
      fill = "white", colour = box_colour, linewidth = 0.3,
      inherit.aes = FALSE
    )

  # 2. Inner value bar (filled, no border)
  p <- p +
    ggplot2::geom_rect(
      data = bar_data,
      ggplot2::aes(
        xmin = .data[["bar_xmin"]], xmax = .data[["bar_xmax"]],
        ymin = .data[["bar_ymin"]], ymax = .data[["bar_ymax_scaled"]]
      ),
      fill = bar_colour, colour = NA,
      inherit.aes = FALSE
    )

  # 3. Variable labels
  if (show_labels) {
    label_data <- bar_data[!duplicated(bar_data$variable), ,
                            drop = FALSE]
    label_data$label_x <- max(bar_data$bar_xmax, na.rm = TRUE) + 0.5
    label_data$label_y <- (label_data$bar_ymin + label_data$bar_ymax) / 2
    p <- p +
      ggplot2::geom_text(
        data = label_data,
        ggplot2::aes(
          x = .data[["label_x"]], y = .data[["label_y"]],
          label = .data[["variable"]]
        ),
        size = label_size, hjust = 0,
        inherit.aes = FALSE
      )
  }

  # 4. Value labels
  if (show_values) {
    bar_data$val_y <- (bar_data$bar_ymin + bar_data$bar_ymax_scaled) / 2
    p <- p +
      ggplot2::geom_text(
        data = bar_data,
        ggplot2::aes(
          x = .data[["x"]], y = .data[["val_y"]],
          label = round(.data[["value"]], 2)
        ),
        size = value_size,
        inherit.aes = FALSE
      )
  }

  p
}

# Compute bar rectangle data for leaf nodes.
# Returns a data.frame with one row per (leaf x variable).
.compute_bar_data <- function(sb, variables, y_offset, bar_height) {
  leaf_data <- sb$rects[sb$rects$is_leaf, , drop = FALSE]

  # Reshape to long format using base R
  rows <- lapply(variables, function(var) {
    data.frame(
      node_id = leaf_data$node_id,
      x       = leaf_data$x,
      xmin    = leaf_data$xmin,
      xmax    = leaf_data$xmax,
      variable = var,
      value   = leaf_data[[var]],
      stringsAsFactors = FALSE
    )
  })
  long <- do.call(rbind, rows)

  # Replace NA with 0
  long$value[is.na(long$value)] <- 0

  # Normalise per variable to [0, 1]
  for (var in variables) {
    mask <- long$variable == var
    max_val <- max(long$value[mask], na.rm = TRUE)
    if (max_val > 0) {
      long$value_norm[mask] <- long$value[mask] / max_val
    } else {
      long$value_norm[mask] <- 0
    }
  }

  # Compute bar positions
  long$var_index <- match(long$variable, variables) - 1L
  long$bar_xmin <- long$x - 0.4
  long$bar_xmax <- long$x + 0.4
  long$bar_ymin <- y_offset + long$var_index * bar_height
  long$bar_ymax <- long$bar_ymin + bar_height * 0.95
  long$bar_ymax_scaled <- long$bar_ymin + bar_height * 0.95 * long$value_norm

  long
}
