#' Validate Input

#' Checks that an input is a non-empty numeric vector with at least two non missing values.
#' Missing values (`NA` and `NaN`) are removed.
#' An error is shown for empty, all missing, or single value inputs.
#' 
#' 
#' @param x A numeric vector.
#' @return The validated numeric vector with missing values removed.

validate_input <- function (x) {
  if(!is.numeric(x)) {
    stop("x must be a numeric vector", call. = FALSE)
  }
  
  if (length(x) == 0L) {
    stop("Input vector cannot be empty.", call. = FALSE)
  }
  
  valid_x <- x[!is.na(x)]
  
  if (length(valid_x) == 0L) {
    stop("Input contains only missing values.", call. = FALSE)
  }
  
  if (length(valid_x) == 1L) {
    stop(
      "Input must contain at least two non-missing values.", call. = FALSE)
  }
  
  valid_x
}
