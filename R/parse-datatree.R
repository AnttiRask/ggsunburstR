# R/parse-datatree.R
# Parse data.tree::Node objects into the internal tree structure.
# Not exported. Called by sunburst_data() when type = "datatree".
# data.tree is a Suggests dependency — not required at package load.

# Reserved/method names in data.tree::Node that are not user data.
.dt_reserved_fields <- c(
  "name", "children", "parent", "isLeaf", "isRoot", "count", "totalCount",
  "path", "pathString", "position", "level", "height", "fields",
  "fieldsAll", "averageBranchingFactor", "leaves", "leafCount", "root",
  "isBinary", "levelName", "siblings", "attributes", "attributesAll",
  # Methods
  "AddChild", "AddChildNode", "AddSibling", "AddSiblingNode",
  "Climb", "clone", "Do", "Get", "Navigate", "Set", "Sort",
  "Prune", "RemoveAttribute", "RemoveChild", "Revert",
  "initialize", "printFormatters"
)

# Convert a data.tree::Node to our internal tree.
# Walks the Node tree recursively, creating nodes via add_child().
# Custom fields (non-reserved) are carried as extra attributes.
parse_datatree <- function(dt_node) {
  rlang::check_installed("data.tree",
                         reason = "to use data.tree::Node input")

  tree <- new_tree()
  # Set root name from the Node
  tree$nodes[[1]]$name <- dt_node$name

  # Recursively add children
  .add_dt_children(tree, parent_id = 1L, dt_node = dt_node)
}

# Recursively add children from a data.tree Node to our internal tree.
.add_dt_children <- function(tree, parent_id, dt_node) {
  if (dt_node$isLeaf) return(tree)

  for (child_name in names(dt_node$children)) {
    child_dt <- dt_node$children[[child_name]]

    # Extract custom fields as extras — use ls() on the R6 environment
    # since $fields may not include active-bound fields
    all_fields <- ls(envir = child_dt)
    extra_fields <- setdiff(all_fields, .dt_reserved_fields)
    extras <- list()
    for (f in extra_fields) {
      val <- child_dt[[f]]
      # Only store scalar values (not R6 objects, environments, functions)
      if (is.atomic(val) && length(val) == 1) {
        extras[[f]] <- val
      }
    }

    new_id <- add_child(tree, parent_id, child_dt$name, extra = extras)
    tree <- attr(new_id, "tree")

    # Recurse into grandchildren
    if (!child_dt$isLeaf) {
      tree <- .add_dt_children(tree, as.integer(new_id), child_dt)
    }
  }
  tree
}
