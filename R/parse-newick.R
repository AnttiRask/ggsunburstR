# R/parse-newick.R
# Parse Newick strings and files into the internal tree structure.
# Not exported. Called by sunburst_data() when type = "newick".

# Parse a Newick string or file path into an internal tree.
# Delegates to ape::read.tree() for the actual parsing, then converts
# the ape::phylo object to our internal list structure.
parse_newick <- function(input) {
  # ape::read.tree() may warn (e.g., "no semicolon found") then return NULL,
  # or it may error. We capture warnings so we can re-emit them after a
  # successful parse, but suppress them on failure (where we abort instead).
  captured_warnings <- list()
  phylo <- tryCatch(
    withCallingHandlers(
      {
        if (file.exists(input)) {
          ape::read.tree(file = input)
        } else {
          ape::read.tree(text = input)
        }
      },
      warning = function(w) {
        captured_warnings[[length(captured_warnings) + 1L]] <<- w
        invokeRestart("muffleWarning")
      }
    ),
    error = function(e) {
      abort(
        "Failed to parse Newick input.",
        i = "Check that the input is valid Newick format.",
        parent = e
      )
    }
  )

  if (is.null(phylo)) {
    abort(
      "Failed to parse Newick input.",
      i = "Check that the input is valid Newick format."
    )
  }

  # Re-emit any warnings from ape on successful parse
  for (w in captured_warnings) {
    warn(conditionMessage(w))
  }

  phylo_to_tree(phylo)
}

# Convert an ape::phylo object to our internal tree structure.
# ape convention: tips are 1..n_tips, internals are (n_tips+1)..n_nodes,
# root is n_tips + 1.
phylo_to_tree <- function(phylo) {
  n_tips <- ape::Ntip(phylo)
  n_nodes <- n_tips + phylo$Nnode
  n_internal <- phylo$Nnode

  nodes <- vector("list", n_nodes)
  children <- vector("list", n_nodes)
  parent <- rep(NA_integer_, n_nodes)

  # Tip nodes
  for (i in seq_len(n_tips)) {
    nodes[[i]] <- list(
      name    = phylo$tip.label[i],
      dist    = 0,
      size    = 1.0,
      is_leaf = TRUE,
      extra   = list()
    )
    children[[i]] <- integer(0)
  }

  # Internal nodes
  for (i in seq_len(n_internal)) {
    node_id <- n_tips + i
    label <- if (!is.null(phylo$node.label) && i <= length(phylo$node.label)) {
      phylo$node.label[i]
    } else {
      paste0("NoName", node_id)
    }
    if (is.na(label) || label == "") label <- paste0("NoName", node_id)

    nodes[[node_id]] <- list(
      name    = label,
      dist    = 0,
      size    = 1.0,
      is_leaf = FALSE,
      extra   = list()
    )
    children[[node_id]] <- integer(0)
  }

  # Build parent-child relationships and distances from edge matrix
  for (row_i in seq_len(nrow(phylo$edge))) {
    par_id <- phylo$edge[row_i, 1]
    child_id <- phylo$edge[row_i, 2]
    children[[par_id]] <- c(children[[par_id]], child_id)
    parent[child_id] <- par_id
    if (!is.null(phylo$edge.length)) {
      nodes[[child_id]]$dist <- phylo$edge.length[row_i]
    } else {
      nodes[[child_id]]$dist <- 1.0
    }
  }

  # Mark leaf status based on children (tips with 0 children are leaves,
  # but ape may create singleton internal nodes in some cases)
  for (i in seq_len(n_nodes)) {
    nodes[[i]]$is_leaf <- length(children[[i]]) == 0
  }

  # Root

  root <- n_tips + 1L
  nodes[[root]]$dist <- 0.0

  list(
    nodes    = nodes,
    children = children,
    parent   = parent,
    root     = root,
    n_tips   = n_tips
  )
}
