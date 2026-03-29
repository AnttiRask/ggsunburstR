#' Create a sunburst plot with per-depth fill scales
#'
#' Creates a sunburst plot where different depth levels can use different
#' fill colour mappings. Uses `ggnewscale::new_scale_fill()` to enable
#' multiple fill scales in a single plot.
#'
#' @param sb A `sunburst_data` object from [sunburst_data()].
#' @param fills A named list mapping depth levels (as character strings)
#'   to column names in `sb$rects` for fill mapping.
#'   E.g., `list("1" = "name", "2" = "value")`.
#' @param colour Border colour for rectangles. Default `"white"`.
#' @param linewidth Border line width. Default `0.2`.
#' @param ... Passed to [ggplot2::geom_rect()].
#'
#' @return A `ggplot` object with `coord_polar()` and `theme_void()`.
#'   Users can add `scale_fill_*()` calls after the plot to control
#'   each depth's colour palette.
#'
#' @seealso [icicle_multifill()] for the rectangular variant,
#'   [sunburst()] for single-scale fill.
#'
#' @examples
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' if (requireNamespace("ggnewscale", quietly = TRUE)) {
#'   sunburst_multifill(sb, fills = list("1" = "name", "2" = "name"))
#' }
#'
#' @export
sunburst_multifill <- function(sb, fills, colour = "white",
                               linewidth = 0.2, ...) {
  .validate_multifill_inputs(sb, fills)
  rlang::check_installed("ggnewscale", reason = "for per-depth fill scales")

  p <- .build_multifill_layers(sb, fills, colour, linewidth, ...)
  p + ggplot2::coord_polar() + ggplot2::theme_void()
}

#' Create an icicle plot with per-depth fill scales
#'
#' Creates an icicle plot where different depth levels can use different
#' fill colour mappings. Uses `ggnewscale::new_scale_fill()` to enable
#' multiple fill scales in a single plot.
#'
#' @inheritParams sunburst_multifill
#'
#' @return A `ggplot` object with `scale_y_reverse()` and `theme_void()`.
#'
#' @seealso [sunburst_multifill()] for the polar variant,
#'   [icicle()] for single-scale fill.
#'
#' @examples
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' if (requireNamespace("ggnewscale", quietly = TRUE)) {
#'   icicle_multifill(sb, fills = list("1" = "name", "2" = "name"))
#' }
#'
#' @export
icicle_multifill <- function(sb, fills, colour = "white",
                             linewidth = 0.2, ...) {
  .validate_multifill_inputs(sb, fills)
  rlang::check_installed("ggnewscale", reason = "for per-depth fill scales")

  p <- .build_multifill_layers(sb, fills, colour, linewidth, ...)
  p + ggplot2::scale_y_reverse() + ggplot2::theme_void()
}

# Validate inputs shared by sunburst_multifill() and icicle_multifill().
.validate_multifill_inputs <- function(sb, fills) {
  if (!inherits(sb, "sunburst_data")) {
    rlang::abort("'sb' must be a sunburst_data object. Use sunburst_data() to create one.")
  }

  if (!is.list(fills) || is.null(names(fills)) ||
      any(names(fills) == "")) {
    rlang::abort("'fills' must be a named list mapping depth levels to column names.")
  }

  available_depths <- unique(sb$rects$depth)
  for (depth_str in names(fills)) {
    depth_val <- suppressWarnings(as.integer(depth_str))
    if (is.na(depth_val) || !depth_val %in% available_depths) {
      cli::cli_abort(c(
        "Depth {.val {depth_str}} not found in data.",
        i = "Available depths: {sort(available_depths)}."
      ))
    }
    fill_col <- fills[[depth_str]]
    if (!fill_col %in% names(sb$rects)) {
      cli::cli_abort("Column {.val {fill_col}} not found in sunburst data.")
    }
  }
}

# Build the multi-fill geom_rect layers. Shared between sunburst and icicle.
# Iterates over all depths: fill-mapped depths use aes(fill = ...) with
# new_scale_fill() between them; unspecified depths use static grey fill.
.build_multifill_layers <- function(sb, fills, colour, linewidth, ...) {
  p <- ggplot2::ggplot()
  all_depths <- sort(unique(sb$rects$depth))
  fill_depths <- as.integer(names(fills))

  is_first_fill <- TRUE
  for (d in all_depths) {
    depth_data <- sb$rects[sb$rects$depth == d, ]
    if (nrow(depth_data) == 0) next

    if (d %in% fill_depths) {
      fill_col <- fills[[as.character(d)]]

      # new_scale_fill() before 2nd and subsequent fill-mapped layers
      if (!is_first_fill) {
        p <- p + ggnewscale::new_scale_fill()
      }
      is_first_fill <- FALSE

      p <- p +
        ggplot2::geom_rect(
          data = depth_data,
          ggplot2::aes(
            xmin = .data[["xmin"]], xmax = .data[["xmax"]],
            ymin = .data[["ymin"]], ymax = .data[["ymax"]],
            fill = .data[[fill_col]]
          ),
          colour = colour, linewidth = linewidth, ...
        )
    } else {
      # Static grey for unspecified depths
      p <- p +
        ggplot2::geom_rect(
          data = depth_data,
          ggplot2::aes(
            xmin = .data[["xmin"]], xmax = .data[["xmax"]],
            ymin = .data[["ymin"]], ymax = .data[["ymax"]]
          ),
          fill = "grey80", colour = colour, linewidth = linewidth, ...
        )
    }
  }

  p
}
