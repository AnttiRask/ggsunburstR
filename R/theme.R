#' Sunburst theme
#'
#' A ggplot2 theme tailored for sunburst and donut charts. Based on
#' [ggplot2::theme_void()] with centred bold title, legend at bottom,
#' and tidy margins.
#'
#' @param base_size Base font size. Default `11`.
#' @param base_family Base font family. Default `""`.
#'
#' @return A ggplot2 [ggplot2::theme()] object.
#'
#' @seealso [sunburst()], [donut()]
#'
#' @examples
#' sb <- sunburst_data("((a, b, c), (d, e));")
#' sunburst(sb, fill = "depth") + theme_sunburst()
#'
#' @export
theme_sunburst <- function(base_size = 11, base_family = "") {
  ggplot2::theme_void(
    base_size = base_size,
    base_family = base_family
  ) %+replace%
    ggplot2::theme(
      plot.title = ggplot2::element_text(
        hjust = 0.5, face = "bold",
        margin = ggplot2::margin(b = 10)
      ),
      legend.position = "bottom",
      plot.margin = ggplot2::margin(5, 5, 5, 5)
    )
}
