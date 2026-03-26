# R/sunburst-class.R
# S3 class "sunburst_data" — constructor and methods.
# See SPEC.md §2.3 for the object structure and §4.4–4.6 for methods.

# Construct a sunburst_data S3 object.
new_sunburst_data <- function(rects, leaf_labels, node_labels, segments,
                              tree, params) {
  structure(
    list(
      rects       = rects,
      leaf_labels = leaf_labels,
      node_labels = node_labels,
      segments    = segments,
      tree        = tree
    ),
    class = "sunburst_data",
    params = params
  )
}

#' Access sunburst_data components
#'
#' The `$data` accessor is an alias for `$rects`.
#'
#' @param x A `sunburst_data` object.
#' @param name Component name.
#' @export
`$.sunburst_data` <- function(x, name) {
  if (name == "data") {
    return(.subset2(x, "rects"))
  }
  NextMethod()
}

#' Print a sunburst_data object
#'
#' Displays a concise summary using `cli` formatting.
#'
#' @param x A `sunburst_data` object.
#' @param ... Ignored.
#' @return `x`, invisibly.
#' @export
print.sunburst_data <- function(x, ...) {
  rects <- x$rects
  n_nodes <- nrow(rects)
  n_leaves <- sum(rects$is_leaf)
  n_internal <- n_nodes - n_leaves
  n_depth <- length(unique(rects$depth))
  params <- attr(x, "params")
  xlim_val <- params$xlim %||% 360
  rot_val <- params$rot %||% 0


  cli::cli_h3("Sunburst data")
  cli::cli_ul(c(
    "{n_nodes} node{?s} ({n_leaves} lea{?f/ves}, {n_internal} internal)",
    "{n_depth} depth level{?s}",
    "xlim = {xlim_val}\u00b0, rot = {rot_val}\u00b0"
  ))
  invisible(x)
}

#' Convert sunburst_data to data.frame
#'
#' Returns the rectangle data (`$rects`).
#'
#' @param x A `sunburst_data` object.
#' @param ... Ignored.
#' @return A data.frame containing rectangle coordinates.
#' @export
as.data.frame.sunburst_data <- function(x, ...) {
  x$rects
}

#' Plot a sunburst_data object
#'
#' Dispatches to `sunburst()`. Until `sunburst()` is implemented,
#' this prints an informational message.
#'
#' @param x A `sunburst_data` object.
#' @param ... Passed to `sunburst()`.
#' @return A ggplot object (once `sunburst()` is available), or `x` invisibly.
#' @export
plot.sunburst_data <- function(x, ...) {
  fn <- tryCatch(
    get("sunburst", envir = asNamespace("ggsunburstR"), mode = "function"),
    error = function(e) NULL
  )
  if (!is.null(fn)) {
    fn(x, ...)
  } else {
    inform("plot() method requires sunburst(). Use sunburst(x) once available.")
    invisible(x)
  }
}
