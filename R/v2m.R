#' Converts a vector to a lower triangular matrix.
#'
#' @description The function \code{v2m} is used in the functions
#' \code{gdrisk}, \code{gdinteract} and \code{gdeco} for converting
#' a vector is from the results of the risk detector result,
#' interaction detector result or ecological detector to a lower
#' triangular matrix.
#'
#' @param vec A data.frame of risk/interaction/ecological detector
#' result of a strata variable
#' @param diag TRUE/FALSE, indicating if the output matrix is a diagonal matrix.
#'
#' @export

v2m <- function (vec, diag = FALSE) {
  n <- length(vec)
  d <- floor((sqrt(1 + n*8) + 1)/2)
  ltm <- diag(d)
  ltm[lower.tri(ltm)] <- vec
  ltm[upper.tri(ltm)] <- NA
  diag(ltm) <- NA
  return(ltm)
}
