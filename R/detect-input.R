# R/detect-input.R
# Auto-detect input type for sunburst_data().
# Not exported. See SPEC.md §2.2 for the detection cascade.

# Detect the input type, returning one of:
# "phylo", "dataframe", "paths", "newick", "lineage", "node_parent".
detect_input_type <- function(input) {
  # 1a. data.tree::Node check (R6, before phylo and data.frame)
  if (inherits(input, "Node") && inherits(input, "R6")) {
    return("datatree")
  }

  # 1b. phylo object check (before data.frame, since phylo is a list)
  if (inherits(input, "phylo")) {
    return("phylo")
  }

  # 2. Data.frame check — distinguish paths vs parent-child
  if (inherits(input, "data.frame")) {
    df_names <- tolower(names(input))
    has_parent <- "parent" %in% df_names
    has_child <- "child" %in% df_names || "node" %in% df_names
    has_path <- "path" %in% df_names
    # If it has a path column but no parent-child columns, treat as paths
    if (has_path && !has_parent) {
      return("paths")
    }
    return("dataframe")
  }

  # 3. Character checks
  if (is.character(input)) {
    # 3a. Multi-element vector → paths
    if (length(input) > 1) {
      return("paths")
    }

    # 3b. Single string
    if (length(input) == 1) {
      # File path — sniff the content
      if (file.exists(input)) {
        return(.sniff_file_type(input))
      }

      # Newick string — contains parentheses and semicolon
      if (grepl("\\(", input) && grepl(";", input)) {
        return("newick")
      }
    }
  }

  # 4. Unrecognisable
  abort(
    "Could not auto-detect input type.",
    i = "Provide 'type' explicitly: 'newick', 'phylo', 'datatree', 'paths', 'lineage', 'node_parent', or 'dataframe'."
  )
}

# Sniff a file's first line to determine its type.
# - Header with "node" and "parent" → "node_parent"
# - Starts with "(" → "newick"
# - Otherwise → "lineage"
.sniff_file_type <- function(path) {
  first_line <- readLines(path, n = 1, warn = FALSE)
  first_lower <- tolower(first_line)

  # Node-parent: header contains both "node" and "parent"
  if (grepl("\\bnode\\b", first_lower) && grepl("\\bparent\\b", first_lower)) {
    return("node_parent")
  }

  # Newick: starts with "("
  if (grepl("^\\s*\\(", first_line)) {
    return("newick")
  }

  # Default: lineage
  "lineage"
}
