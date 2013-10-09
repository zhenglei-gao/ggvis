#' Transformation: stack the data
#'
#' \code{transform_stack} is a data transformation that stacks values in a
#' a data object. Typically, y values are stacked at each unique x value,
#' although it's also possible to stack x values at each unique y.
#'
#' @section Input:
#' \code{transform_stack} takes a data frame or a split_df as input.
#'
#' @section Ouput:
#'
#' \code{transform_stack} returns a sorted data frame or split_df with the same
#'   columns as the input as well as columns named \code{y_lower__} and
#'   \code{y_upper__} (or \code{x_lower__} and \code{x_upper__} if stacking x
#'   values). These columns specify the upper and lower bounds of each stacked
#'   object.
#'
#'  Note that \code{transform_stack} does not sort the values. If you want to
#'  sort on another variable, you can use \code{\link{transform_sort}} before
#'  stacking. This is useful when, for example, your data is unsorted and you
#'  want stacked bar chart where each stack of bars appears in the same order.
#'  Also, if you use \code{by_group}, it will result in the data being sorted
#'  by the grouping variables.
#'
#' @param var The variable to stack. This is the variable name after mapping,
#'   and must be either \code{"y"} (the default) or \code{"x"}.
#'   For example, with \code{props(y = ~mpg)}, you would use \code{"y"}, not
#'   \code{"mpg"}.
#' @examples
#'
#' library(plyr)
#' hec <- as.data.frame(HairEyeColor)
#' # Collapse across Sex
#' hec <- ddply(hec, c("Hair", "Eye"), summarise, Freq = sum(Freq))
#'
#' # Without stacking - bars overlap
#' ggvis(hec,
#'   props(x = ~Hair, y = ~Freq, fill = ~Eye, fillOpacity := 0.5),
#'   dscale("x", "nominal", range = "width", padding = 0, points = FALSE),
#'   mark_rect(props(y2 = 0, width = band()))
#' )
#'
#' # With stacking
#' ggvis(hec, transform_stack(),
#'   props(x = ~Hair, y = ~Freq, fill = ~Eye, fillOpacity := 0.5),
#'   dscale("x", "nominal", range = "width", padding = 0, points = FALSE),
#'   mark_rect(props(y = ~y_lower__, y2 = ~y_upper__, width = band()))
#' )
#'
#' # Stacking in x direction instead of default y
#' ggvis(hec, transform_stack(var = "x"),
#'   props(x = ~Freq, y = ~Hair, fill = ~Eye, fillOpacity := 0.5),
#'   dscale("y", "nominal", range = "height", padding = 0, points = FALSE),
#'   mark_rect(props(x = ~x_lower__, x2 = ~x_upper__, height = band()))
#' )
#'
#'
#' # Stack y values at each x
#' sluice(pipeline(hec, transform_stack()), props(x = ~Hair, y = ~Freq))
#'
#' # Same effect, but this time stack x values at each y
#' sluice(pipeline(hec, transform_stack(var = "x")), props(x = ~Freq, y = ~Hair))
#'
#' @export
transform_stack <- function(var = "y") {
  if (var != "y" && var != "x") {
    stop("var for transform_stack must be 'x' or 'y'.")
  }

  transform("stack", var = var)
}

#' @S3method format transform_stack
format.transform_stack <- function(x, ...) {
  paste0(" -> stack()", param_string(x["var"]))
}

#' @S3method compute transform_stack
compute.transform_stack <- function(x, props, data) {
  if (x$var == "x") {
    stack_prop <- "x"
    group_prop <- "y"
  } else if (x$var == "y") {
    stack_prop <- "y"
    group_prop <- "x"
  } else {
    stop("var for transform_stack must be 'x' or 'y'.")
  }

  stack_prop <- paste0(stack_prop, ".update")
  group_prop <- paste0(group_prop, ".update")

  check_prop(x, props, data, stack_prop, "numeric")
  check_prop(x, props, data, group_prop)

  output <- compute_stack(data, x, props[[stack_prop]], props[[group_prop]])
  preserve_constants(data, output)
}

compute_stack <- function(data, trans, stack_var, group_var) {
  UseMethod("compute_stack")
}

#' @S3method compute_stack split_df
compute_stack.split_df <- function(data, trans, stack_var, group_var) {
  # Record split variables
  vars <- split_vars(data)

  # Unsplit the data and compute stacking
  df <- as.data.frame(data)
  df <- compute_stack(df, trans, stack_var, group_var)

  # Re-split the data
  split_df(df, vars, emptyenv())
}

#' @S3method compute_stack data.frame
compute_stack.data.frame <- function(data, trans, stack_var, group_var) {
  # Get the x and y values (these are named as if we're stacking y, but it
  # will work when stacking x - we just need to rename at end)
  x <- prop_value(group_var, data)
  y <- prop_value(stack_var, data)

  # Split y by x
  y_split <- split(y, x)

  # Stack y var at each x
  y_upper__ <- lapply(y_split, cumsum)
  y_lower__ <- lapply(y_upper__, function(x) c(0, x[-length(x)]))

  # Convert back to vector
  y_upper__ <- unsplit(y_upper__, x)
  y_lower__ <- unsplit(y_lower__, x)

  # Add the y lower and upper values to the data frame
  if (trans$var == "y") {
    cbind(data, y_lower__, y_upper__)
  } else {
    # If we were actually stacking along x, change names to use x instead
    cbind(data, x_lower__ = y_lower__, x_upper__ = y_upper__)
  }
}