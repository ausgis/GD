#' Generates discretization parameters for continuous data.
#'
#' @description Function for discretizing continuous data and obtaining the
#' different outputs, including discretization intervals, numbers of values
#' within intervals, and visualization of discretization.
#'
#' @usage disc(var, n, method = "quantile", ManualItv)
#' \method{print}{disc}(x, ...)
#' \method{plot}{disc}(x, ...)
#'
#' @aliases disc print.disc plot.disc
#'
#' @param var A numeric vector of continuous variable
#' @param n The numeber of intervals
#' @param method A character of discretization method
#' @param ManualItv A numeric vector of manual intervals
#' @param x A list of \code{disc} result
#' @param ... Ignore
#'
#' @examples
#' ## method is default (quantile); number of intervals is 4
#' ds1 <- disc(ndvi_40$Tempchange, 4)
#' ds1
#' ## method is equal; number of intervals is 4
#' ds2 <- disc(ndvi_40$Tempchange, 4, method = "equal")
#' ## method is manual; number of intervals is 4
#' manualitv1 <- c(-0.5, 0, 1, 2, 4)
#' ds3 <- disc(ndvi_40$Tempchange, 4, method = "manual", ManualItv = manualitv1)
#'
#' @export

disc <- function(var, n, method = "quantile", ManualItv){
  if (!is.numeric(var))
    stop("var is not numeric")
  if (any(is.na(var))) {
    warning("var has missing values, omitted in finding classes")
    var <- c(stats::na.omit(var))
  }

  MethodEqual <- function(var, n){
    seq(min(var), max(var), length.out = (n + 1))
  }

  MethodNatural <- function(var, n){ # debug: increase speed
    BAMMtools::getJenksBreaks(var, n+1)
  }

  MethodQuantile <- function(var, n){
    itv <- stats::quantile(var, probs = seq(0, 1, length = n + 1))
    l0 <- length(unique(itv))
    if (l0 < n + 1){
      l1 <- l0
      l2 <- l0
      while(l2 < n + 1){
        itv1 <- stats::quantile(var, probs = seq(0, 1, length = l1 + 1))
        l2 <- length(unique(itv1))
        l1 <- l1 + 1
      }
      itv <- unique(itv1)
    }
    return(itv)
  }

  MethodGeometric <- function(var, n){
    FunX <- function(x, n){
      x1 <- x + 1
      b <- (max(x1)/min(x1))^(1/(n - 1))
      x0 <- min(x1)/b # debug: x1 = b * x0; xn = b^n * x0
      x2 <- b^seq(n) * x0 - 1
      return(x2)
    }
    if (min(var) >= 0){
      itv <- FunX(var, n)
    } else {
      var.range <- abs(c(min(var), max(var)))
      kmax <- which(var.range == max(var.range))
      kmin <- c(1,2)[-kmax]
      n2 <- floor((n + 1)/(1 + var.range[kmin]/var.range[kmax]))
      n1 <- n + 1 - n2
      itv1 <- FunX(c(0, var.range[kmin]), n1 + 1)[-1]
      itv2 <- FunX(c(0, var.range[kmax]), n2 + 1)[-1]
      if (kmin == 1){
        itv <- c(-rev(itv1), itv2)
      } else {
        itv <- c(-rev(itv2), itv1)
      }
    }
    return(itv)
  }

  MethodSd <- function(var, n){
    seqa <- seq(2000, 2, -2)
    itv <- c()
    m <- n
    while (length(itv) < n + 1){
      m <- m + 1
      seqb <- (m-1) - seqa
      seqb <- seqb[which(seqb >= 0)]
      if (m <= 7) {
        itvb1 <- mean(var) - seqb/2 * stats::sd(var)
        itvb2 <- mean(var) + seqb/2 * stats::sd(var)
      } else {
        itvb1 <- mean(var) - seqb/4 * stats::sd(var)
        itvb2 <- mean(var) + seqb/4 * stats::sd(var)
      }
      itvb1 <- rev(itvb1)
      itvb1 <- itvb1[which(itvb1 > min(var))]
      itvb2 <- itvb2[which(itvb2 < max(var))]
      itvb <- c(itvb1, itvb2)
      itvb <- itvb[!duplicated(itvb)]
      itv <- c(min(var),itvb,max(var))
    }
    return(itv)
  }

  if (method == "equal") {
    itv <- MethodEqual(var, n)
  } else if (method == "natural") {
    itv <- MethodNatural(var, n)
  } else if (method == "quantile") {
    itv <- MethodQuantile(var, n)
  } else if (method == "geometric") {
    itv <- MethodGeometric(var, n)
  } else if (method == "sd") {
    itv <- MethodSd(var, n)
  } else if (method == "manual") {
    if (!is.null(ManualItv)){
      itv <- ManualItv
    } else {
      warning("Input a manual interval vector")
    }
  } else {
    warning("Please select a discretization method")
  }

  # debug: delete citv function
  disc.list <- list("var" = var, "itv" = itv)
  ## define class
  class(disc.list) <- "disc"
  disc.list
}

print.disc <- function(x, ...){
  cat("Intervals:\n", x$itv)
  invisible(x)
}

plot.disc <- function(x, ...){
  var <- x$var
  # debug: use basic plot functions for histogram
  graphics::hist(var, 30, col = "gray", border = "gray", main = NULL, xlab = "Variable", las = 1)
  graphics::abline(v = x$itv, col = "red")
  graphics::box()
}

