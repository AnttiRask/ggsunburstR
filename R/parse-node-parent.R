# R/parse-node-parent.R
# Parse CSV/TSV node-parent files into the internal tree structure.
# Not exported. Called by sunburst_data() when type = "node_parent".
# See SPEC.md §2.2.5 for format specification.

# Parse a node-parent file. First line must be a header containing
# 'node' and 'parent' columns. Extra columns become node attributes.
parse_node_parent <- function(infile, sep = ",") {
  df <- utils::read.csv(infile, sep = sep, stringsAsFactors = FALSE)
  names(df) <- tolower(trimws(gsub("^[\"']|[\"']$", "", names(df))))

  if (!all(c("node", "parent") %in% names(df))) {
    abort(
      "First line must contain 'node' and 'parent' columns.",
      i = "Found columns: {.val {names(df)}}."
    )
  }

  tree <- new_tree()
  extra_cols <- setdiff(names(df), c("node", "parent"))

  for (i in seq_len(nrow(df))) {
    parent_name <- trimws(gsub("^[\"']|[\"']$", "", df$parent[i]))
    node_name <- trimws(gsub("^[\"']|[\"']$", "", df$node[i]))

    # Build extra attributes from additional columns
    extras <- as.list(df[i, extra_cols, drop = FALSE])
    names(extras) <- extra_cols

    # Find or create parent node
    if (is.na(parent_name) || parent_name == "") {
      parent_id <- tree$root
    } else {
      parent_id <- find_node_by_name(tree, parent_name)
      if (is.null(parent_id)) {
        # Parent doesn't exist yet; add it under root
        pid <- add_child(tree, tree$root, parent_name)
        tree <- attr(pid, "tree")
        parent_id <- pid
      }
    }

    new_id <- add_child(tree, parent_id, node_name, extra = extras)
    tree <- attr(new_id, "tree")
  }
  tree
}
