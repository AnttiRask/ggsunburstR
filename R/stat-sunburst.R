# R/stat-sunburst.R
# Custom ggproto Stat that converts a parent-child data.frame into
# sunburst rectangle coordinates. Uses compute_panel() because the
# entire tree must be reconstructed from all rows at once.

StatSunburst <- ggplot2::ggproto("StatSunburst", ggplot2::Stat,

  required_aes = c("id", "parent"),

  # compute_panel receives the full panel data (not per-group subsets),
  # which is essential for tree reconstruction.
  # Drop id/parent after stat computation — GeomRect doesn't need them
  dropped_aes = c("id", "parent"),

  # Declare stat-specific params so layer() doesn't warn about them
  extra_params = c("na.rm", "values", "branchvalues", "leaf_mode"),


  # Replace NA parent with sentinel before remove_missing runs.
  # The root row has parent = NA which triggers ggplot2 warnings.
  # Note: "__ROOT__" is a reserved sentinel — user data must not

  # contain a node with this exact name.
  setup_data = function(data, params) {
    data$parent[is.na(data$parent)] <- "__ROOT__"
    data
  },

  compute_panel = function(data, scales, values = NULL,
                           branchvalues = "remainder",
                           leaf_mode = "actual", ...) {
    # Build a parent-child data.frame for parse_dataframe().
    # Restore NA for the root row (sentinel was set in setup_data).
    tree_df <- data.frame(
      parent = ifelse(data$parent == "__ROOT__", NA_character_, data$parent),
      child = data$id,
      stringsAsFactors = FALSE
    )

    # Carry extra columns (for fill mapping etc.)
    extra_cols <- setdiff(names(data), c("id", "parent", "PANEL", "group"))
    for (col in extra_cols) {
      tree_df[[col]] <- data[[col]]
    }

    # Pipeline: parse → size → coordinates
    tree <- parse_dataframe(tree_df)
    values_vec <- .resolve_stat_values(values, tree_df, tree)
    tree <- assign_sizes(tree, values = values_vec,
                         branchvalues = branchvalues)
    coords <- compute_coordinates(tree, leaf_mode = leaf_mode)

    # Convert to flat data.frame for GeomRect
    .flatten_coords(tree, coords, data)
  }
)

# Resolve the values parameter for StatSunburst.
# values can be a column name (string) or NULL.
.resolve_stat_values <- function(values, tree_df, tree) {
  if (is.null(values)) return(NULL)

  if (is.character(values) && length(values) == 1) {
    if (!values %in% names(tree_df)) {
      rlang::warn(
        paste0("Column '", values, "' not found in data. Using equal weights."),
        class = "ggsunburstR_values_not_found"
      )
      return(NULL)
    }
    vals <- setNames(
      as.numeric(tree_df[[values]]),
      as.character(tree_df$child)
    )
    vals <- vals[!is.na(vals)]
    return(vals)
  }

  NULL
}

# Convert coordinate lists into a flat data.frame with xmin/xmax/ymin/ymax.
# Joins back extra columns from the original data for fill mapping.
.flatten_coords <- function(tree, coords, original_data) {
  root <- tree$root
  desc <- get_descendants(tree, root, "postorder")
  desc <- desc[desc != root]

  rows <- lapply(desc, function(nid) {
    r <- coords$rects[[nid]]
    if (is.null(r)) return(NULL)
    data.frame(
      xmin = r$xmin,
      xmax = r$xmax,
      ymin = r$ymin,
      ymax = r$ymax,
      node_name = r$name %||% NA_character_,
      stringsAsFactors = FALSE
    )
  })
  rows <- rows[!vapply(rows, is.null, logical(1))]
  out <- do.call(rbind, rows)

  # Join extra columns from original data by matching node name to id
  node_names <- out$node_name
  match_idx <- match(node_names, original_data$id)

  extra_cols <- setdiff(
    names(original_data),
    c("id", "parent", "PANEL", "group", "x", "y",
      "xmin", "xmax", "ymin", "ymax")
  )
  for (col in extra_cols) {
    out[[col]] <- original_data[[col]][match_idx]
  }

  out$node_name <- NULL
  out
}
