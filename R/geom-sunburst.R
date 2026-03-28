#' Sunburst layer for ggplot2
#'
#' Creates a sunburst (or icicle) layer from a parent-child data.frame.
#' Uses `StatSunburst` to convert the hierarchy into rectangle coordinates
#' and `GeomRect` to render them.
#'
#' Add `coord_polar()` for a sunburst layout, or leave Cartesian for an
#' icicle layout. Fill mapping works via standard ggplot2 aesthetics.
#'
#' @param mapping Set of aesthetic mappings. **Required:** `aes(id, parent)`.
#'   The `id` column identifies each node and `parent` gives its parent
#'   node (use `NA` for the root). Optional: `fill`, `colour`, `alpha`.
#' @param data A data.frame with at least `id` (or `child`/`node`) and
#'   `parent` columns. Extra columns are available for aesthetic mapping.
#' @param stat The statistical transformation. Default `"sunburst"`.
#' @param position Position adjustment. Default `"identity"`.
#' @param ... Other arguments passed to the layer.
#' @param values Column name (string) for value-weighted sizing.
#'   `NULL` for equal weight. Default `NULL`.
#' @param branchvalues How parent values relate to children.
#'   `"remainder"` (default) or `"total"`.
#' @param leaf_mode How short branches are handled.
#'   `"actual"` (default) or `"extended"`.
#' @param colour Border colour for rectangles. Default `"white"`.
#' @param linewidth Border line width. Default `0.2`.
#' @param na.rm If `FALSE`, missing values produce warnings. Default `FALSE`.
#' @param show.legend Logical. Include this layer in legends?
#' @param inherit.aes If `TRUE`, inherit aesthetics from `ggplot()`.
#'
#' @return A ggplot2 layer.
#'
#' @examples
#' df <- data.frame(
#'   parent = c(NA, "root", "root", "A", "A"),
#'   child  = c("root", "A", "B", "a1", "a2"),
#'   group  = c("r", "g1", "g2", "g1", "g1")
#' )
#'
#' # Icicle (Cartesian)
#' ggplot2::ggplot(df) +
#'   geom_sunburst(ggplot2::aes(id = child, parent = parent, fill = group))
#'
#' # Sunburst (polar)
#' ggplot2::ggplot(df) +
#'   geom_sunburst(ggplot2::aes(id = child, parent = parent, fill = group)) +
#'   ggplot2::coord_polar()
#'
#' @seealso [sunburst()], [icicle()] for the convenience-function API.
#'
#' @export
geom_sunburst <- function(mapping = NULL, data = NULL,
                          stat = "sunburst", position = "identity",
                          ..., colour = "white", linewidth = 0.2,
                          values = NULL,
                          branchvalues = "remainder",
                          leaf_mode = "actual",
                          na.rm = FALSE, show.legend = NA,
                          inherit.aes = TRUE) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = StatSunburst,
    geom = ggplot2::GeomRect,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      colour = colour,
      linewidth = linewidth,
      values = values,
      branchvalues = branchvalues,
      leaf_mode = leaf_mode,
      na.rm = na.rm,
      ...
    )
  )
}
