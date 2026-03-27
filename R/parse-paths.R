# R/parse-paths.R
# Parse path-delimited strings into the internal tree structure.
# Not exported. Called by sunburst_data() when type = "paths".

# Parse a character vector of delimited paths (e.g., "A/B/C") into an
# internal tree. Shared prefixes are reused.
# `extras_list` is an optional list of named lists, one per path,
# containing extra attributes to attach to the leaf node.
parse_paths <- function(paths, sep = "/", extras_list = NULL) {
  tree <- new_tree()

  for (i in seq_along(paths)) {
    parts <- strsplit(paths[i], sep, fixed = TRUE)[[1]]
    parts <- trimws(parts)
    parts <- parts[nchar(parts) > 0]  # drop empty segments

    parent_id <- tree$root

    for (j in seq_along(parts)) {
      name <- parts[j]
      is_last <- j == length(parts)

      # Check if this child already exists under the current parent
      existing <- NULL
      for (cid in tree$children[[parent_id]]) {
        if (tree$nodes[[cid]]$name == name) {
          existing <- cid
          break
        }
      }

      if (!is.null(existing) && !is_last) {
        # Reuse existing node for intermediate segments
        parent_id <- existing
      } else if (!is.null(existing) && is_last && is.null(extras_list)) {
        # Leaf already exists with no extras to add — reuse
        parent_id <- existing
      } else {
        # Create new node; attach extras only to the final (leaf) node
        extras <- if (is_last && !is.null(extras_list)) {
          extras_list[[i]]
        } else {
          list()
        }
        new_id <- add_child(tree, parent_id, name, extra = extras)
        tree <- attr(new_id, "tree")
        parent_id <- new_id
      }
    }
  }
  tree
}
