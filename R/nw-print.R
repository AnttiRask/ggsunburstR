#' Print tree structure from Newick input
#'
#' Displays a text summary of the tree encoded in a Newick string or file.
#' Useful for inspecting tree topology before creating plots.
#'
#' @param newick A Newick string or file path.
#' @param ladderize If not `FALSE`, sort partitions by descendant count.
#'   `TRUE` or `"right"` for ascending, `"left"` for descending.
#' @param ultrametric If `TRUE`, convert to ultrametric topology before
#'   printing.
#'
#' @return `NULL`, invisibly. Called for its side effect of printing.
#'
#' @examples
#' nw_print("((a, b, c), (d, e));")
#'
#' @export
nw_print <- function(newick, ladderize = FALSE, ultrametric = FALSE) {
  # Parse via ape — reuse the same warning-capture pattern as parse_newick
  captured_warnings <- list()
  phylo <- tryCatch(
    withCallingHandlers(
      {
        if (file.exists(newick)) {
          ape::read.tree(file = newick)
        } else {
          ape::read.tree(text = newick)
        }
      },
      warning = function(w) {
        captured_warnings[[length(captured_warnings) + 1L]] <<- w
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      abort(
        "Failed to parse Newick input.",
        i = "Check that the input is valid Newick format.",
        parent = e
      )
    }
  )

  if (is.null(phylo)) {
    abort(
      "Failed to parse Newick input.",
      i = "Check that the input is valid Newick format."
    )
  }

  # Re-emit warnings from successful parse
  for (w in captured_warnings) {
    warn(conditionMessage(w))
  }

  # Optional transforms via ape directly

  if (!identical(ladderize, FALSE)) {
    right <- !(ladderize %in% c("L", "LEFT", "left", "Left"))
    phylo <- ape::ladderize(phylo, right = right)
  }

  if (isTRUE(ultrametric)) {
    phylo <- ape::compute.brlen(phylo)
  }

  # Print the tree summary
  cat(paste(utils::capture.output(print(phylo)), collapse = "\n"), "\n")

  invisible(NULL)
}
