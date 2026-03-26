# R/compute-coords.R
# Compute rectangle coordinates for sunburst/icicle rendering.
# Not exported. See SPEC.md §3.1 for the algorithm.

# Compute xmin/xmax/ymin/ymax for all non-root nodes.
# Returns a list with:
#   $rects    — list indexed by node_id, each a list(xmin, xmax, ymin, ymax,
#               x, name, is_leaf)
#   $segments — list indexed by node_id, each a list(rx, ry, ryend, px, pxend)
#   $total_size — sum of leaf sizes (for label angle computation)
compute_coordinates <- function(tree, leaf_mode = "actual") {
  leaf_mode <- match.arg(leaf_mode, c("actual", "extended"))
  root <- tree$root

  # Global parameters
  leaves <- get_leaves(tree, root)
  total_size <- sum(vapply(
    leaves, function(l) tree$nodes[[l]]$size, numeric(1)
  ))
  farthest <- get_farthest_node(tree)
  y_offset <- farthest$dist

  # Storage
  n <- length(tree$nodes)
  rects <- vector("list", n)
  segs <- vector("list", n)

  # Cursor-based X assignment for leaves
  xmin_cursor <- 0.5

  for (nid in get_descendants(tree, root, "postorder")) {
    if (nid == root) next

    node <- tree$nodes[[nid]]
    dist_to_root <- get_distance_to_root(tree, nid)

    # Y coordinates: farthest leaf at ymax=0, root at most negative
    ymax <- dist_to_root - y_offset
    ymin <- ymax - node$dist

    if (length(tree$children[[nid]]) == 0) {
      # Leaf node: sequential X from cursor
      node_size <- node$size
      xmax_local <- xmin_cursor + node_size
      x <- xmin_cursor + node_size / 2
      rects[[nid]] <- list(
        xmin = xmin_cursor, xmax = xmax_local,
        ymin = ymin, ymax = ymax,
        x = x,
        name = node$name,
        is_leaf = TRUE
      )
      xmin_cursor <- xmax_local

      # Segment for leaf
      segs[[nid]] <- list(
        rx = x, ry = ymax - node$dist, ryend = ymax,
        px = NA_real_, pxend = NA_real_
      )
    } else {
      # Internal node: X spans from first to last child leaf
      child_leaves <- get_leaves(tree, nid)
      xmin_local <- rects[[child_leaves[1]]]$xmin
      xmax_local <- rects[[child_leaves[length(child_leaves)]]]$xmax
      x <- xmin_local + (xmax_local - xmin_local) / 2

      # Filter NoName from display name
      display_name <- if (grepl("^NoName", node$name)) {
        NA_character_
      } else {
        node$name
      }

      rects[[nid]] <- list(
        xmin = xmin_local, xmax = xmax_local,
        ymin = ymin, ymax = ymax,
        x = x,
        name = display_name,
        is_leaf = FALSE
      )

      # Segment for internal node
      kids <- tree$children[[nid]]
      px <- segs[[kids[1]]]$rx
      pxend <- segs[[kids[length(kids)]]]$rx
      segs[[nid]] <- list(
        rx = px + (pxend - px) / 2,
        ry = ymax - node$dist, ryend = ymax,
        px = px, pxend = pxend
      )
    }
  }

  # Post-processing: leaf_mode = "extended"
  if (leaf_mode == "extended") {
    # Find global max ymax among leaves (should be 0.0)
    leaf_ymaxs <- vapply(
      which(vapply(rects, function(r) !is.null(r) && r$is_leaf, logical(1))),
      function(i) rects[[i]]$ymax,
      numeric(1)
    )
    global_ymax <- max(leaf_ymaxs)
    for (i in seq_along(rects)) {
      if (!is.null(rects[[i]]) && rects[[i]]$is_leaf) {
        rects[[i]]$ymax <- global_ymax
      }
    }
  }

  list(rects = rects, segments = segs, total_size = total_size)
}
