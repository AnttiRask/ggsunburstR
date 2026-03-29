#' Drill down into a subtree
#'
#' Extracts a subtree rooted at the specified node and recomputes
#' coordinates so the subtree fills the full angular space. The result
#' is a new `sunburst_data` object compatible with all plot functions.
#'
#' @param sb A `sunburst_data` object.
#' @param node Node to use as the new root. Character string (node name)
#'   or integer (node ID).
#' @param ... Override parameters for the recomputation (e.g., `xlim`,
#'   `rot`).
#'
#' @return A new `sunburst_data` object rooted at the selected node.
#'
#' @seealso [sunburst_data()] for creating the initial data,
#'   [sunburst()], [icicle()], [donut()] for plotting.
#'
#' @examples
#' sb <- sunburst_data("((a, b)X, (c, d)Y)root;")
#' # Drill into the X subtree (containing a, b)
#' sub <- drilldown(sb, node = "X")
#' sunburst(sub, fill = "name")
#'
#' @export
drilldown <- function(sb, node, ...) {
  if (!inherits(sb, "sunburst_data")) {
    abort("'sb' must be a sunburst_data object.")
  }

  tree <- sb$tree
  overrides <- list(...)
  params <- attr(sb, "params")

  # Resolve node to node_id
 if (is.character(node) && length(node) == 1) {
    node_id <- find_node_by_name(tree, node)
    if (is.null(node_id)) {
      cli::cli_abort("Node {.val {node}} not found in tree.")
    }
  } else if (is.numeric(node) && length(node) == 1) {
    node_id <- as.integer(node)
    if (node_id < 1 || node_id > length(tree$nodes)) {
      cli::cli_abort("Node ID {node_id} out of range.")
    }
  } else {
    abort("'node' must be a single character name or integer ID.")
  }

  # Root check
  if (node_id == tree$root) {
    warn("Node is already the root. Returning unchanged data.")
    return(sb)
  }

  # Leaf check
  if (length(tree$children[[node_id]]) == 0) {
    node_name <- tree$nodes[[node_id]]$name
    cli::cli_abort("Cannot drill down into a leaf node ({.val {node_name}} has no children).")
  }

  # Extract subtree
  subtree <- extract_subtree(tree, node_id)

  # Merge params with overrides
  merged <- params
  for (nm in names(overrides)) {
    merged[[nm]] <- overrides[[nm]]
  }
  merged$drilldown_from <- node

  # Recompute: sizes
  subtree <- assign_sizes(subtree, values = merged$values,
                          branchvalues = merged$branchvalues %||% "remainder")

  # Optional transforms
  if (!identical(merged$ladderize, FALSE) && !is.null(merged$ladderize)) {
    reverse <- merged$ladderize %in% c("L", "LEFT", "left", "Left")
    subtree <- ladderize_tree(subtree, reverse = reverse)
  }

  if (isTRUE(merged$ultrametric)) {
    subtree <- convert_to_ultrametric(subtree)
  }

  # Recompute: coordinates
  leaf_mode <- merged$leaf_mode %||% "actual"
  coords <- compute_coordinates(subtree, leaf_mode = leaf_mode)

  # Recompute: labels
  xlim <- merged$xlim %||% 360
  rot <- merged$rot %||% 0
  labels <- compute_label_positions(
    coords$rects, subtree,
    xlim = xlim, total_size = coords$total_size, rot = rot
  )

  # Build output
  output <- .build_output(subtree, coords, labels)

  new_sunburst_data(
    rects       = output$rects,
    leaf_labels = output$leaf_labels,
    node_labels = output$node_labels,
    segments    = output$segments,
    tree        = subtree,
    params      = merged
  )
}

# Extract a subtree rooted at node_id into a new internal tree.
# Recursively copies all descendants, preserving names, dist, and extras.
extract_subtree <- function(tree, node_id) {
  new <- new_tree()
  # Set root from the source node
  src <- tree$nodes[[node_id]]
  new$nodes[[1]]$name <- src$name
  new$nodes[[1]]$dist <- 0.0  # root always has dist=0
  new$nodes[[1]]$extra <- src$extra

  # Recursively copy children
  new <- .copy_children(tree, node_id, new, parent_new_id = 1L)
  new
}

# Recursively copy children from src tree under src_parent_id
# into dst tree under parent_new_id.
.copy_children <- function(src, src_parent_id, dst, parent_new_id) {
  for (child_id in src$children[[src_parent_id]]) {
    child <- src$nodes[[child_id]]
    new_id <- add_child(dst, parent_new_id, child$name,
                        dist = child$dist, extra = child$extra)
    dst <- attr(new_id, "tree")

    # Recurse if the source child has children
    if (length(src$children[[child_id]]) > 0) {
      dst <- .copy_children(src, child_id, dst, as.integer(new_id))
    }
  }
  dst
}
