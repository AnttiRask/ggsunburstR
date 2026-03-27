#' Parse hierarchical input into sunburst/icicle data
#'
#' Accepts hierarchical data in multiple formats (Newick strings/files,
#' data frames, lineage files, node-parent files), computes rectangle
#' coordinates for each node, and returns a `sunburst_data` S3 object
#' suitable for rendering with `sunburst()` or `icicle()`.
#'
#' @param input Hierarchical data. One of: Newick string, file path,
#'   data.frame with parent-child columns, or an `ape::phylo` object.
#' @param type Input type. One of `"auto"`, `"newick"`, `"phylo"`,
#'   `"lineage"`, `"node_parent"`, `"dataframe"`. Auto-detection is
#'   recommended.
#' @param values Column name (character, for data.frame input) or named
#'   numeric vector mapping node names to values for sector sizing.
#'   `NULL` for equal weight.
#' @param branchvalues How parent values relate to children.
#'   `"remainder"`: parent value is additive.
#'   `"total"`: parent value equals sum of children.
#' @param leaf_mode How short branches are handled.
#'   `"actual"`: stop at real depth.
#'   `"extended"`: extend to max depth.
#' @param ladderize Sort partitions by descendant count. `FALSE` for
#'   no sorting, `TRUE` or `"right"` for ascending, `"left"` for descending.
#' @param ultrametric If `TRUE`, convert tree to ultrametric topology.
#' @param xlim Angular span in degrees. Default `360` for full circle.
#' @param rot Rotation offset in degrees.
#' @param node_attributes Character vector of additional node attribute
#'   names to include in output.
#' @param sep Separator for file-based inputs.
#' @param ... Reserved for future parameters.
#'
#' @return An S3 object of class `"sunburst_data"` containing `$rects`,
#'   `$leaf_labels`, `$node_labels`, `$segments`, and `$tree`.
#'
#' @examples
#' # Newick string
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' sb
#'
#' # Data frame
#' df <- data.frame(
#'   parent = c(NA, "root", "root"),
#'   child  = c("root", "A", "B")
#' )
#' sb <- sunburst_data(df)
#'
#' @export
sunburst_data <- function(input, type = "auto", values = NULL,
                          branchvalues = c("remainder", "total"),
                          leaf_mode = c("actual", "extended"),
                          ladderize = FALSE, ultrametric = FALSE,
                          xlim = 360, rot = 0, node_attributes = NULL,
                          sep = NULL, ...) {
  branchvalues <- match.arg(branchvalues)
  leaf_mode <- match.arg(leaf_mode)

  # --- Detect input type ---
  if (type == "auto") {
    type <- detect_input_type(input)
  }

  # --- Parse input into internal tree ---
  tree <- switch(type,
    newick = parse_newick(input),
    phylo = phylo_to_tree(input),
    lineage = parse_lineage(input,
                            sep = if (is.null(sep)) "\t" else sep),
    node_parent = parse_node_parent(input,
                                    sep = if (is.null(sep)) "," else sep),
    dataframe = parse_dataframe(input),
    abort(
      "Unknown input type: {.val {type}}.",
      i = "Use 'newick', 'phylo', 'lineage', 'node_parent', or 'dataframe'."
    )
  )

  # --- Handle values parameter ---
  values_vec <- .resolve_values(values, input, tree, type)

  # --- Assign sizes ---
  tree <- assign_sizes(tree, values = values_vec, branchvalues = branchvalues)

  # --- Optional transforms ---
  if (!identical(ladderize, FALSE)) {
    reverse <- ladderize %in% c("L", "LEFT", "left", "Left")
    tree <- ladderize_tree(tree, reverse = reverse)
  }

  if (isTRUE(ultrametric)) {
    tree <- convert_to_ultrametric(tree)
  }

  # --- Compute coordinates ---
  coords <- compute_coordinates(tree, leaf_mode = leaf_mode)

  # --- Compute label positions ---
  labels <- compute_label_positions(
    coords$rects, tree,
    xlim = xlim, total_size = coords$total_size, rot = rot
  )

  # --- Build output ---
  output <- .build_output(tree, coords, labels, node_attributes)

  # --- Construct S3 object ---
  params <- list(
    type = type,
    values = values,
    branchvalues = branchvalues,
    leaf_mode = leaf_mode,
    ladderize = ladderize,
    ultrametric = ultrametric,
    xlim = xlim,
    rot = rot
  )

  new_sunburst_data(
    rects       = output$rects,
    leaf_labels = output$leaf_labels,
    node_labels = output$node_labels,
    segments    = output$segments,
    tree        = tree,
    params      = params
  )
}

# Resolve the values parameter into a named numeric vector or NULL.
# - NULL → NULL (equal weight)
# - character(1) → extract from data.frame column or tree node extras
# - named numeric → use directly
.resolve_values <- function(values, input, tree, type) {
  if (is.null(values)) return(NULL)

  if (is.character(values) && length(values) == 1) {
    # String column name — extract from data.frame input
    if (type == "dataframe" && inherits(input, "data.frame")) {
      col_name <- values
      col_lower <- tolower(names(input))
      match_idx <- which(col_lower == tolower(col_name))
      if (length(match_idx) == 0) {
        abort("Column '{col_name}' not found in input data.")
      }
      # Build named vector: node name → value
      child_col <- if ("child" %in% tolower(names(input))) {
        input[[which(tolower(names(input)) == "child")]]
      } else {
        input[[which(tolower(names(input)) == "node")]]
      }
      val_col <- input[[match_idx[1]]]
      named_vals <- setNames(as.numeric(val_col), as.character(child_col))
      # Remove NAs
      named_vals <- named_vals[!is.na(named_vals)]
      return(named_vals)
    }
    # For non-dataframe types, try extracting from tree node extras
    vals <- numeric(0)
    for (i in seq_along(tree$nodes)) {
      node <- tree$nodes[[i]]
      if (!is.null(node$extra[[values]])) {
        v <- as.numeric(node$extra[[values]])
        if (!is.na(v)) {
          vals[node$name] <- v
        }
      }
    }
    if (length(vals) > 0) return(vals)
    return(NULL)
  }

  if (is.numeric(values) && !is.null(names(values))) {
    return(values)
  }

  abort("'values' must be NULL, a column name (character), or a named numeric vector.")
}

# Build output data.frames from computed coordinates and labels.
.build_output <- function(tree, coords, labels, node_attributes = NULL) {
  if (is.null(node_attributes)) node_attributes <- character(0)

  # Collect non-root node IDs
  desc <- get_descendants(tree, tree$root, "postorder")
  desc <- desc[desc != tree$root]

  # --- Rects ---
  rects_list <- lapply(desc, function(nid) {
    r <- coords$rects[[nid]]
    if (is.null(r)) return(NULL)
    node <- tree$nodes[[nid]]
    parent_id <- tree$parent[nid]
    parent_name <- if (!is.na(parent_id)) tree$nodes[[parent_id]]$name else NA

    # Compute depth (distance from root in hops)
    depth <- 0L
    cur <- nid
    while (!is.na(tree$parent[cur]) && tree$parent[cur] != tree$root) {
      depth <- depth + 1L
      cur <- tree$parent[cur]
    }
    depth <- depth + 1L  # root's children are depth 1

    base <- data.frame(
      node_id     = nid,
      name        = r$name,
      parent_name = parent_name,
      depth       = depth,
      is_leaf     = r$is_leaf,
      xmin        = r$xmin,
      xmax        = r$xmax,
      ymin        = r$ymin,
      ymax        = r$ymax,
      x           = r$x,
      stringsAsFactors = FALSE
    )

    # Add node attributes
    for (attr_name in node_attributes) {
      val <- node$extra[[attr_name]]
      base[[attr_name]] <- if (is.null(val)) NA_character_ else as.character(val)
    }

    # Add extra columns from data.frame input (stored in node$extra)
    extra_names <- setdiff(names(node$extra), node_attributes)
    for (en in extra_names) {
      base[[en]] <- node$extra[[en]]
    }

    base
  })
  rects_list <- rects_list[!vapply(rects_list, is.null, logical(1))]
  rects_df <- do.call(rbind, rects_list)

  # --- Leaf labels ---
  leaf_ids <- desc[vapply(desc, function(d) {
    !is.null(labels$leaf_labels[[d]])
  }, logical(1))]
  leaf_list <- lapply(leaf_ids, function(nid) {
    l <- labels$leaf_labels[[nid]]
    data.frame(
      node_id = nid,
      label   = l$label,
      x       = l$x,
      y       = l$y,
      angle   = l$rangle,
      hjust   = l$rhjust,
      pangle  = l$pangle,
      pvjust  = l$pvjust,
      stringsAsFactors = FALSE
    )
  })
  leaf_labels_df <- if (length(leaf_list) > 0) {
    do.call(rbind, leaf_list)
  } else {
    data.frame(node_id = integer(0), label = character(0),
               x = numeric(0), y = numeric(0),
               angle = numeric(0), hjust = numeric(0),
               pangle = numeric(0), pvjust = numeric(0),
               stringsAsFactors = FALSE)
  }

  # --- Node labels (internal nodes) ---
  node_ids <- desc[vapply(desc, function(d) {
    !is.null(labels$node_labels[[d]])
  }, logical(1))]
  node_list <- lapply(node_ids, function(nid) {
    l <- labels$node_labels[[nid]]
    data.frame(
      node_id     = nid,
      label       = l$label,
      x           = l$x,
      y           = l$y,
      rangle      = l$rangle,
      rhjust      = l$rhjust,
      pangle      = l$pangle,
      pvjust      = l$pvjust,
      delta_angle = l$delta_angle,
      xfraction   = l$xfraction,
      stringsAsFactors = FALSE
    )
  })
  node_labels_df <- if (length(node_list) > 0) {
    do.call(rbind, node_list)
  } else {
    data.frame(node_id = integer(0), label = character(0),
               x = numeric(0), y = numeric(0),
               rangle = numeric(0), rhjust = numeric(0),
               pangle = numeric(0), pvjust = numeric(0),
               delta_angle = numeric(0), xfraction = numeric(0),
               stringsAsFactors = FALSE)
  }

  # --- Segments ---
  seg_list <- lapply(desc, function(nid) {
    s <- coords$segments[[nid]]
    if (is.null(s)) return(NULL)
    data.frame(
      rx = s$rx, ry = s$ry, ryend = s$ryend,
      px = s$px, pxend = s$pxend,
      stringsAsFactors = FALSE
    )
  })
  seg_list <- seg_list[!vapply(seg_list, is.null, logical(1))]
  segments_df <- if (length(seg_list) > 0) {
    do.call(rbind, seg_list)
  } else {
    data.frame(rx = numeric(0), ry = numeric(0), ryend = numeric(0),
               px = numeric(0), pxend = numeric(0),
               stringsAsFactors = FALSE)
  }

  list(
    rects       = rects_df,
    leaf_labels = leaf_labels_df,
    node_labels = node_labels_df,
    segments    = segments_df
  )
}
