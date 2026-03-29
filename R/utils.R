# R/utils.R
# Trigonometric helpers for polar label positioning.
# Not exported. Used by compute_label_positions().
# See SPEC.md §2.4.3 for formulas.

# Radial text angle: flip by 180° on the left side so text is never
# upside-down. "Left side" = where cos(angle) < 0.
rangle <- function(angle) {
  ifelse(cos(angle * pi / 180) < 0, angle + 180, angle)
}

# Perpendicular text angle: rotate to follow the arc.
pangle <- function(angle) {
  ifelse(sin(angle * pi / 180) < 0, angle + 90, angle - 90)
}

# Horizontal justification for radial text.
# Right side (cos >= 0): left-aligned (0). Left side: right-aligned (1).
hjust_rtext <- function(angle) {
  ifelse(cos(angle * pi / 180) < 0, 1, 0)
}

# Vertical justification for perpendicular text.
# Upper half (sin >= 0): top-aligned (1). Lower half: bottom-aligned (0).
vjust_ptext <- function(angle) {
  ifelse(sin(angle * pi / 180) < 0, 0, 1)
}

# Horizontal justification for perpendicular text — always centred.
hjust_ptext <- function(angle) {
  0.5
}

# Vertical justification for radial text — always centred.
vjust_rtext <- function(angle) {
  0.5
}

# Resolve the fill quosure to a string or NULL.
# Handles: NULL, bare names (symbols), and string literals.
# Must be called with a quosure captured by rlang::enquo() in the
# calling function — enquo() cannot be deferred to this helper.
.resolve_fill <- function(fill_quo) {
  if (rlang::quo_is_null(fill_quo)) {
    return(NULL)
  }
  if (rlang::quo_is_symbol(fill_quo)) {
    return(rlang::as_name(fill_quo))
  }
  expr <- rlang::quo_get_expr(fill_quo)
  if (rlang::is_string(expr)) {
    return(expr)
  }
  rlang::abort("'fill' must be NULL, a column name, or a string.")
}

# Build a geom_rect layer with fill dispatch.
# fill = NULL or "none" → static grey, "auto" → depth, string → mapped.
.build_rect_layer <- function(data, fill, colour, linewidth, ...) {
  if (is.null(fill) || identical(fill, "none")) {
    ggplot2::geom_rect(
      data = data,
      ggplot2::aes(
        xmin = .data[["xmin"]], xmax = .data[["xmax"]],
        ymin = .data[["ymin"]], ymax = .data[["ymax"]]
      ),
      fill = "grey80", colour = colour, linewidth = linewidth, ...
    )
  } else {
    fill_col <- if (identical(fill, "auto")) "depth" else fill
    ggplot2::geom_rect(
      data = data,
      ggplot2::aes(
        xmin = .data[["xmin"]], xmax = .data[["xmax"]],
        ymin = .data[["ymin"]], ymax = .data[["ymax"]],
        fill = .data[[fill_col]]
      ),
      colour = colour, linewidth = linewidth, ...
    )
  }
}

# Validate fill parameter — skip "auto" and "none" as reserved values.
.validate_fill <- function(fill, rects) {
  if (is.null(fill) || fill %in% c("auto", "none")) return(invisible())
  if (!fill %in% names(rects)) {
    cli::cli_abort("Column {.val {fill}} not found in sunburst data.")
  }
}

# Add a text label layer — plain geom_text or ggrepel::geom_text_repel.
# Used by icicle() to avoid duplicating geom-selection logic.
.add_text_layer <- function(data, label_size, label_repel = FALSE) {
  aes_mapping <- ggplot2::aes(
    x = .data[["x"]], y = .data[["y"]],
    label = .data[["label"]]
  )
  if (isTRUE(label_repel)) {
    ggrepel::geom_text_repel(
      data = data, mapping = aes_mapping,
      size = label_size, max.overlaps = Inf, seed = 42
    )
  } else {
    ggplot2::geom_text(
      data = data, mapping = aes_mapping,
      size = label_size
    )
  }
}

# Filter label data by minimum angular extent.
# Removes rows where delta_angle < min_angle. Returns filtered data.frame.
.filter_by_angle <- function(data, min_angle) {
  if (min_angle > 0 && "delta_angle" %in% names(data)) {
    data[data$delta_angle >= min_angle, ]
  } else {
    data
  }
}
