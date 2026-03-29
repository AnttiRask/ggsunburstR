# R/parse-dataframe.R
# Parse a data.frame with parent-child columns into the internal tree.
# Not exported. Called by sunburst_data() when type = "dataframe".
# See SPEC.md §2.2.3 for format specification.

# Parse a data.frame (or tibble) with parent/child columns.
# Accepts either "child" or "node" as the non-parent column (case-insensitive).
# Extra columns are attached as node attributes in `extra`.
parse_dataframe <- function(df) {
  # Normalise column names to lowercase
  orig_names <- names(df)
  names(df) <- tolower(names(df))

  # Detect child column: accept "child" or "node"
  child_col <- if ("child" %in% names(df)) {
    "child"
  } else if ("node" %in% names(df)) {
    "node"
  } else {
    NULL
  }

  if (!"parent" %in% names(df) || is.null(child_col)) {
    cli::cli_abort(c(
      "Input data.frame must have {.val parent} and {.val child} (or {.val node}) columns.",
      i = "Found columns: {.val {orig_names}}."
    ))
  }

  extra_cols <- setdiff(names(df), c("parent", child_col))

  tree <- new_tree()
  # Map from node name to node ID for parent lookups.
  # Handles duplicate names by tracking the most recently added node per name,
  # but we also search by parent context for duplicate children.
  name_to_id <- list()

  for (i in seq_len(nrow(df))) {
    parent_name <- as.character(df[["parent"]][i])
    child_name <- as.character(df[[child_col]][i])

    # Build extra attributes
    extras <- list()
    for (col in extra_cols) {
      extras[[col]] <- df[[col]][i]
    }

    # Find parent
    if (is.na(parent_name) || parent_name == "") {
      parent_id <- tree$root
    } else {
      parent_id <- name_to_id[[parent_name]]
      if (is.null(parent_id)) {
        # Parent not yet seen — add it under root
        pid <- add_child(tree, tree$root, parent_name)
        tree <- attr(pid, "tree")
        parent_id <- pid
        name_to_id[[parent_name]] <- parent_id
      }
    }

    # Add child
    new_id <- add_child(tree, parent_id, child_name, extra = extras)
    tree <- attr(new_id, "tree")
    name_to_id[[child_name]] <- as.integer(new_id)
  }

  tree
}
