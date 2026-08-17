#' Calculate the first quartile
#'
#' Calculates the first quartile (25th percentile) of a numeric vector.
#' Missing values (`NA` and `NaN`) are removed.
#' An error is shown for empty, all-missing, or single-value inputs.
#'
#' @param x A numeric vector.
#' @return A single numeric value representing the first quartile.
#'
#' @examples
#' calc_q1(c(1, 2, 3, 4, 5)) # Returns 2
#' calc_q1(c(1, NA, 3, 4)) # Returns 2
#' try(calc_q1(numeric(0))) # Shows an error
#' @export
calc_q1 <- function(x) {
  x <- validate_input(x)
  unname(quantile(x, probs = 0.25))
}
#' 
#' Calculate the third quartile
#'
#' Calculates the third quartile (75th percentile) of a numeric vector.
#' Missing values (`NA` and `NaN`) are removed.
#' An error is shown for empty, all-missing, or single-value inputs.
#'
#' @param x A numeric vector.
#' @return A single numeric value representing the third quartile.
#'
#' @examples
#' calc_q3(c(1, 2, 3, 4, 5)) # Returns 4
#' calc_q3(c(1, NA, 3, 4)) # Returns 3.5
#' try(calc_q3(numeric(0))) # Shows an error
#' @export
calc_q3 <- function(x) {
x <- validate_input(x)
  unname(quantile(x, probs = 0.75))
}
#' 
#' Calculate the interquartile range
#'
#' Calculates the interquartile range (IQR), defined as Q3 minus Q1.
#' Missing values (`NA` and `NaN`) are removed.
#' An error is shown for empty, all-missing, or single-value inputs.
#'
#' @param x A numeric vector.
#' @return The interquartile range.
#'
#' @examples
#' calc_iqr(c(1, 2, 3, 4, 5)) # Returns 2
#' calc_iqr(c(1, NA, 3, 4)) # Returns 1.5
#' try(calc_iqr(numeric(0))) # Shows an error
#' @export
calc_iqr <- function(x) {
  x <- validate_input(x)
  
  q3 <- unname(quantile(x, probs = 0.75))
  q1 <- unname(quantile(x, probs = 0.25))
  
  q3 - q1
}