#' Geographical detectors: risk means in risk detector.
#'
#' @description Function for calculating risk means within intervals and visualization.
#'
#' @usage riskmean(formula, data = NULL)
#' \method{print}{riskmean}(x, ...)
#' \method{plot}{riskmean}(x, ...)
#'
#' @aliases riskmean print.riskmean plot.riskmean
#'
#' @param formula a formula of response and explanatory variables
#' @param data a data.frame includes response and explanatory variables
#' @param x a list of risk mean values
#' @param ... ignore
#'
#' @examples
#' rm1 <- riskmean(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
#' rm1
#' plot(rm1)
#' \donttest{
#' data <- ndvi_40[,1:3]
#' rm2 <- riskmean(NDVIchange ~ ., data = data)
#' rm2
#' }
#'
#' @export
#'
riskmean <- function(formula, data = NULL){
  formula <- stats::as.formula(formula)
  formula.vars <- all.vars(formula)
  response <- data[, formula.vars[1], drop = TRUE]
  if (formula.vars[2] == "."){
    explanatory <- data[, !(colnames(data) %in% formula.vars[1]), drop = FALSE]
  } else {
    explanatory <- data[, formula.vars[-1], drop = FALSE]
  }
  ncolx <- ncol(explanatory)

  result <- lapply(1:ncolx, function(x){ # debug: use lapply and tapply to replace loops
    meanrisk <- tapply(response, explanatory[, x, drop = TRUE], mean)
    meanrisk <- cbind(itv = names(meanrisk), data.frame(meanrisk))
    meanrisk$itv <- factor(meanrisk$itv, levels = levels(factor(explanatory[, x])))
    row.names(meanrisk) <- c()
    return(meanrisk)
  })
  names(result) <- colnames(explanatory)

  ## define class
  class(result) <- "riskmean"
  result
}

print.riskmean <- function(x, ...){
  lr <- length(x)
  names.result <- names(x)
    for (i in 1:lr){
      resulti <- x[[i]]
      cat(names.result[i])
      cat("\n")
      print(resulti)
      cat("\n")
    }
  invisible(x)
}

plot.riskmean <- function(x, ...){
  lr <- length(x)
  names.result <- names(x)

  if (lr == 1){
    cols <- 1
  } else if (lr > 1 & lr <= 4) {
    cols <- 2
  } else if (lr > 4 & lr <= 9) {
    cols <- 3
  } else {
    cols <- 4
  }
  rows <- ceiling(lr/cols)

  max.length.name <- max(sapply(x, function(x) max(nchar(as.character(x$itv)))))
  graphics::par(mfrow = c(rows, cols), mar = c(4.1, 3.1 + max.length.name/4, 3.1, 2.1))
  for (i in 1:lr){ # debug: use barplot
    vec <- rev(x[[i]]$meanrisk)
    names(vec) <- rev(as.character(x[[i]]$itv))
    vec.col <- ifelse(vec == min(vec), "blue", ifelse(vec == max(vec), "red", "gray"))
    graphics::barplot(vec, horiz = TRUE, col = vec.col, xlab = "Mean Value",
                      main = names.result[i], las = 1)
  }
  graphics::par(mfrow = c(1, 1), mar = c(5.1, 4.1, 4.1, 2.1))
}

