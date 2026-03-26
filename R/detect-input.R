# R/detect-input.R
# Auto-detect input type for sunburst_data().
# Not exported. See SPEC.md §2.2 for the detection cascade.

# Detect the input type, returning one of:
# "dataframe", "newick", "lineage", "node_parent".
detect_input_type <- function(input) {
  # 1. Data.frame check

  if (inherits(input, "data.frame")) {
    return("dataframe")
  }

  # 2. Character string checks
  if (is.character(input) && length(input) == 1) {
    # 2a. File path — sniff the content
    if (file.exists(input)) {
      return(.sniff_file_type(input))
    }

    # 2b. Newick string — contains parentheses and semicolon
    if (grepl("\\(", input) && grepl(";", input)) {
      return("newick")
    }
  }

  # 3. Unrecognisable
  abort(
    "Could not auto-detect input type.",
    i = "Provide 'type' explicitly: 'newick', 'lineage', 'node_parent', or 'dataframe'."
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
