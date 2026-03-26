# R/parse-lineage.R
# Parse tab-delimited lineage files into the internal tree structure.
# Not exported. Called by sunburst_data() when type = "lineage".
# See SPEC.md §2.2.4 for format specification.

# Parse a lineage file where each line is a separated root-to-leaf path.
# Nodes can have attributes: "name->attr1:val1;attr2:val2".
# Shared path prefixes reuse existing nodes.
parse_lineage <- function(infile, sep = "\t") {
  lines <- readLines(infile)
  tree <- new_tree()

  for (line in lines) {
    lineage <- trimws(gsub("^[\"']|[\"']$", "", strsplit(line, sep)[[1]]))
    parent_id <- tree$root

    for (name_raw in lineage) {
      # Check for attribute syntax: "name->attr1:val1;attr2:val2"
      attrs <- list()
      if (grepl("->", name_raw)) {
        parts <- strsplit(name_raw, "->")[[1]]
        name_raw <- trimws(parts[1])
        attr_parts <- strsplit(parts[2], ";")[[1]]
        for (a in attr_parts) {
          kv <- strsplit(a, ":")[[1]]
          if (length(kv) == 2) attrs[[kv[1]]] <- kv[2]
        }
      }
      name_raw <- trimws(name_raw)

      # Check if this child already exists under the current parent
      existing <- NULL
      for (cid in tree$children[[parent_id]]) {
        if (tree$nodes[[cid]]$name == name_raw) {
          existing <- cid
          break
        }
      }

      if (!is.null(existing) && length(attrs) == 0) {
        # Reuse existing node (shared prefix)
        parent_id <- existing
      } else {
        new_id <- add_child(tree, parent_id, name_raw, extra = attrs)
        tree <- attr(new_id, "tree")
        parent_id <- new_id
      }
    }
  }
  tree
}
