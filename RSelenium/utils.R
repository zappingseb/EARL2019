#' Boxplot with facetting
#' 
#' @param x \code{character} x-Columns to plot - Numeric
#' @param y \code{character} y-Columns to plot - Numeric
#' @param facet_cols \code{character} columns for facetting
#' @param pat_data \code{tibble} or \code{data.frame} data frame containing all columns
boxplot_intern <- function(x, y, facet_cols, pat_data = get("pat_data", parent.frame())) {
  set.seed(1)
  ggplot2::ggplot(pat_data) +
    aes_string(x = y, y = x) +
    geom_boxplot() + coord_flip() +
    if (length(facet_cols) == 1 && is.factor(pat_data[[facet_cols]])) {
      facet_grid(reformulate(facet_cols))
    } else {
      NULL
    }
}

split_cols <- function(x) {
  if (!is.null(x)) {
    columns_selected <- strsplit(x, split = ",")[[1]]
    columns_selected[columns_selected != ""]
  }
}