# R/tree-transform.R
# Tree transformations: ladderize and ultrametric conversion.
# Not exported. Applied optionally before coordinate computation.

# Sort each node's children by ascending leaf count (ascending = fewer leaves
# first). When reverse = TRUE, sort descending (more leaves first).
ladderize_tree <- function(tree, reverse = FALSE) {
  leaf_counts <- integer(length(tree$nodes))
  for (nid in get_descendants(tree, tree$root, "postorder")) {
    if (length(tree$children[[nid]]) == 0) {
      leaf_counts[nid] <- 1L
    } else {
      leaf_counts[nid] <- sum(leaf_counts[tree$children[[nid]]])
    }
  }

  for (nid in seq_along(tree$children)) {
    kids <- tree$children[[nid]]
    if (length(kids) > 1) {
      counts <- leaf_counts[kids]
      ord <- order(counts, decreasing = reverse)
      tree$children[[nid]] <- kids[ord]
    }
  }
  tree
}

# Convert tree to ultrametric topology using a balanced strategy.
# Redistributes branch lengths so all leaves are equidistant from root.
# The total tree length is preserved (max distance from root to any leaf).
convert_to_ultrametric <- function(tree) {
  farthest <- get_farthest_node(tree)
  tree_len <- farthest$dist

  # Compute max depth (number of splits to farthest descendant leaf)
  max_depth <- integer(length(tree$nodes))
  for (nid in get_descendants(tree, tree$root, "postorder")) {
    kids <- tree$children[[nid]]
    if (length(kids) == 0) {
      max_depth[nid] <- 1L
    } else {
      max_depth[nid] <- max(max_depth[kids]) + 1L
    }
  }

  # Redistribute distances so each branch gets an equal share of remaining
  # distance from its parent to the farthest descendant leaf.
  node_dist_from_root <- numeric(length(tree$nodes))
  node_dist_from_root[tree$root] <- 0.0

  for (nid in descendants_levelorder(tree, tree$root)) {
    par <- tree$parent[nid]
    tree$nodes[[nid]]$dist <-
      (tree_len - node_dist_from_root[par]) / max_depth[nid]
    node_dist_from_root[nid] <-
      tree$nodes[[nid]]$dist + node_dist_from_root[par]
  }
  tree
}
