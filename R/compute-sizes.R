# R/compute-sizes.R
# Assign angular weight sizes to tree nodes.
# Not exported. Called by sunburst_data() before coordinate computation.
# See SPEC.md §3.1 Phase 1 and §4.1 for details.

# Assign sizes to all nodes in the tree.
# - values: NULL (equal weight) or named numeric vector (node_name → size).
# - branchvalues: "remainder" (parent = own + children) or "total" (parent = children sum).
# Returns the modified tree.
assign_sizes <- function(tree, values = NULL, branchvalues = "remainder") {
  branchvalues <- match.arg(branchvalues, c("remainder", "total"))

  # Phase 1: Set leaf sizes from values or default to 1.0
  for (nid in seq_along(tree$nodes)) {
    if (length(tree$children[[nid]]) == 0) {
      # Leaf node
      if (!is.null(values) && tree$nodes[[nid]]$name %in% names(values)) {
        tree$nodes[[nid]]$size <- as.numeric(values[tree$nodes[[nid]]$name])
      } else {
        tree$nodes[[nid]]$size <- 1.0
      }
    }
  }

  # Phase 2: Postorder traversal to propagate sizes to internal nodes
  for (nid in get_descendants(tree, tree$root, "postorder")) {
    kids <- tree$children[[nid]]
    if (length(kids) == 0) next  # leaf — already set

    children_sum <- sum(vapply(
      kids, function(k) tree$nodes[[k]]$size, numeric(1)
    ))

    if (branchvalues == "remainder") {
      # Own value is the supplied value for this node (or 0 if not supplied)
      own_value <- 0
      if (!is.null(values) && tree$nodes[[nid]]$name %in% names(values)) {
        own_value <- as.numeric(values[tree$nodes[[nid]]$name])
      }
      tree$nodes[[nid]]$size <- own_value + children_sum

    } else {
      # "total" mode: parent size = children sum. Warn if supplied differs.
      if (!is.null(values) && tree$nodes[[nid]]$name %in% names(values)) {
        supplied <- as.numeric(values[tree$nodes[[nid]]$name])
        if (abs(supplied - children_sum) > 1e-8) {
          warn(paste0(
            "Node '", tree$nodes[[nid]]$name,
            "': supplied value (", supplied,
            ") does not match children sum (", children_sum,
            ") in branchvalues = \"total\" mode."
          ))
        }
      }
      tree$nodes[[nid]]$size <- children_sum
    }
  }

  tree
}
