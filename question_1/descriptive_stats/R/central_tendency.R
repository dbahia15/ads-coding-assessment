#' Calculate the mean
#' 
#' Calculates the mean of a numeric vector.
#' Missing values (`NA` and `NaN`) are removed.
#' An error is shown for empty, all missing, or single value inputs.
#' If no value occurs more than once, `NA` is returned and a message
#' is shown. 
#' All tied modes are returned.
#' 
#' @param x A numeric vector.
#' @return The mean of the numeric vector.
#' 
#'
#' @examples
#' x <- c(1,2,3,4,5)
#' calc_mean(x) # Returns 3
#' 
#' calc_mean(c(1, NA, 3)) # Returns 2
#' 
#' try(calc_mean(numeric(0))) # Shows an error
#' try(calc_mean(c(NA, NA))) # Shows an error
#' try(calc_mean(5)) # Shows an error
#' 
#' @export
calc_mean <- function(x) {
  x <- validate_input(x)
  mean(x)
}

#' Calculate the median
#' Calculates the median of a numeric vector.
#' Missing values (`NA` and `NaN`) are removed.
#' An error is shown for empty, all missing, or single value inputs.
#' 
#' @param x A numeric vector.
#' @return The median of the numeric vector.
#' 
#'
#' @examples
#' x <- c(1,2,3,4,5)
#' calc_median(x) # Returns 3
#'
#' calc_median(c(1, 2, 3, 4)) # Returns 2.5
#' calc_median(c(1, NA, 3)) # Returns 2
#'
#' try(calc_median(numeric(0))) # Shows an error
#' try(calc_median(c(NA, NA))) # Shows an error
#' try(calc_median(5)) # Shows an error
#' @export
calc_median <- function(x) {
  x <- validate_input(x)
  median(x)
}

#' Calculate the mode
#' 
#' Calculates the mode of a numeric vector.
#' Missing values (`NA` and `NaN`) are removed.
#' An error is shown for empty, all missing, or single value inputs.
#' 
#' @param x A numeric vector.
#' @return The mode of the numeric vector.
#' 
#'
#' @examples
#' calc_mode(c(1, 2, 2, 3)) # Returns 2
#' calc_mode(c(1, 1, 2, 2)) # Returns 1 and 2
#' calc_mode(c(1, 2, 3)) # Returns NA
#' calc_mode(c(1, NA, 2, 2)) # Returns 2
#'
#' try(calc_mode(numeric(0))) # Shows an error
#' try(calc_mode(c(NA, NA))) # Shows an error
#' try(calc_mode(5)) # Shows an error
#' @export
calc_mode <- function(x) {
  x <- validate_input(x)
  
  values <- unique(x)
  counts <- tabulate(match(x, values))
  highest_count <- max(counts)
  
  if (highest_count == 1L) {
    message("No mode found.")
    return(NA_real_)
  }
  
  values[counts == highest_count]
}