# R/compute-labels.R
# Compute label positions for polar text rendering.
# Not exported. Called after compute_coordinates().
# See SPEC.md §2.4 for column definitions and §2.4.3 for formulas.

# Compute label data for both leaf and internal nodes.
# Returns list(leaf_labels, node_labels) — each a list indexed by node_id.
compute_label_positions <- function(rects, tree, xlim = 360,
                                    total_size, rot = 0) {
  n <- length(tree$nodes)
  leaf_labels <- vector("list", n)
  node_labels <- vector("list", n)

  for (nid in seq_along(rects)) {
    r <- rects[[nid]]
    if (is.null(r)) next

    node <- tree$nodes[[nid]]

    # Base angle: maps x position to degrees
    # Formula from SPEC.md §2.4.3
    base_angle <- (r$x - 0.5) * (-xlim / total_size) + 90 - rot

    # Leaf size sum under this node (for delta_angle and xfraction)
    node_leaves <- get_leaves(tree, nid)
    this_size_sum <- sum(vapply(
      node_leaves, function(l) tree$nodes[[l]]$size, numeric(1)
    ))

    if (r$is_leaf) {
      leaf_labels[[nid]] <- list(
        label   = node$name,
        angle   = base_angle,
        rangle  = rangle(base_angle),
        pangle  = pangle(base_angle),
        rhjust  = hjust_rtext(base_angle),
        pvjust  = vjust_ptext(base_angle),
        x       = r$x,
        y       = r$ymax,  # outer edge per SPEC.md §2.4.1
        y_mid   = r$ymin + (r$ymax - r$ymin) / 2
      )
    } else {
      node_labels[[nid]] <- list(
        label       = node$name,
        rangle      = rangle(base_angle),
        rhjust      = hjust_rtext(base_angle),
        pangle      = pangle(base_angle),
        pvjust      = vjust_ptext(base_angle),
        x           = r$x,
        y           = r$ymin + (r$ymax - r$ymin) / 2,
        delta_angle = this_size_sum * (xlim / total_size),
        xfraction   = this_size_sum / total_size
      )
    }
  }

  list(leaf_labels = leaf_labels, node_labels = node_labels)
}
