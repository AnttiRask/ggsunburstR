# R/tree-traversal.R
# Tree traversal and distance utilities.
# Not exported. Used by coordinate computation and parsers.

# Get all descendant IDs of a node in the specified traversal order.
# Always includes the start node itself.
get_descendants <- function(tree, node_id, order = "postorder") {
  order <- rlang::arg_match(order, c("postorder", "levelorder"))
  if (order == "postorder") {
    descendants_postorder(tree, node_id)
  } else {
    descendants_levelorder(tree, node_id)
  }
}

# Postorder: children before parent (recursive).
descendants_postorder <- function(tree, node_id) {
  result <- integer(0)
  for (child_id in tree$children[[node_id]]) {
    result <- c(result, descendants_postorder(tree, child_id))
  }
  c(result, node_id)
}

# Levelorder: breadth-first, starting with node_id itself.
# Includes the start node as the first element.
descendants_levelorder <- function(tree, node_id) {
  result <- integer(0)
  queue <- node_id
  while (length(queue) > 0) {
    current <- queue[1]
    queue <- queue[-1]
    result <- c(result, current)
    queue <- c(queue, tree$children[[current]])
  }
  result
}

# Get leaf node IDs under a given node.
get_leaves <- function(tree, node_id) {
  if (length(tree$children[[node_id]]) == 0) return(node_id)
  desc <- get_descendants(tree, node_id, "postorder")
  desc[vapply(desc, function(d) length(tree$children[[d]]) == 0, logical(1))]
}

# Compute cumulative branch-length distance from a node to the root.
get_distance_to_root <- function(tree, node_id) {
  dist <- 0
  current <- node_id
  while (!is.na(tree$parent[current])) {
    dist <- dist + tree$nodes[[current]]$dist
    current <- tree$parent[current]
  }
  dist
}

# Find the leaf with maximum distance to root.
# Returns list(node = <id>, dist = <distance>).
get_farthest_node <- function(tree) {
  leaves <- get_leaves(tree, tree$root)
  dists <- vapply(leaves, function(l) get_distance_to_root(tree, l), numeric(1))
  max_idx <- which.max(dists)
  list(node = leaves[max_idx], dist = dists[max_idx])
}
