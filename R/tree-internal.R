# R/tree-internal.R
# Internal tree data structure: construction and node lookup.
# Not exported. See SPEC.md §2.1 for the data model.

# Create a new empty tree with a single root node.
# The root has name = "", dist = 0.0, is_leaf = FALSE.
new_tree <- function() {
  root_node <- list(
    name    = "",
    dist    = 0.0,
    size    = 1.0,
    is_leaf = FALSE,
    extra   = list()
  )
  list(
    nodes    = list(root_node),
    children = list(integer(0)),
    parent   = NA_integer_,
    root     = 1L,
    n_tips   = 0L
  )
}

# Add a child node to a tree.
# Returns the new node's ID with the modified tree attached as attr(, "tree").
# This workaround is needed because R has copy-on-modify semantics for lists.
add_child <- function(tree, parent_id, name, dist = 1.0, extra = list()) {
  new_id <- length(tree$nodes) + 1L
  tree$nodes[[new_id]] <- list(
    name    = name,
    dist    = dist,
    size    = 1.0,
    is_leaf = TRUE,
    extra   = extra
  )
  tree$children[[new_id]] <- integer(0)
  tree$parent[new_id]     <- parent_id
  tree$children[[parent_id]] <- c(tree$children[[parent_id]], new_id)

  # Parent is no longer a leaf
  tree$nodes[[parent_id]]$is_leaf <- FALSE

  # Update tip count
  tree$n_tips <- tree$n_tips + 1L

  structure(new_id, tree = tree)
}

# Find a node by name, returning its integer ID or NULL if not found.
find_node_by_name <- function(tree, name) {
  for (i in seq_along(tree$nodes)) {
    if (tree$nodes[[i]]$name == name) return(i)
  }
  NULL
}
