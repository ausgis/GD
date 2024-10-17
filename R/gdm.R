#' Geographical detectors: a one-step function.
#'
#' @description A one-step function for optimal discretization and geographical detectors for
#' multiple variables and visualization.
#'
#' @usage gdm(formula, continuous_variable = NULL, data = NULL, discmethod, discitv)
#' \method{print}{gdm}(x, ...)
#' \method{plot}{gdm}(x, ...)
#'
#' @aliases gdm print.gdm plot.gdm
#'
#' @param formula A formula of response and explanatory variables
#' @param continuous_variable A vector of continuous variable names
#' @param data A data.frame includes response and explanatory variables
#' @param discmethod A character vector of discretization methods
#' @param discitv A numeric vector of numbers of intervals
#' @param x A list of \code{gdm} result
#' @param ... Ignore
#'
#' @importFrom grid grid.newpage pushViewport viewport grid.layout
#'
#' @examples
#' ###############
#' ## NDVI: ndvi_40
#' ###############
#' ## set optional parameters of optimal discretization
#' ## optional methods: equal, natural, quantile, geometric, sd and manual
#' discmethod <- c("equal","quantile")
#' discitv <- c(4:5)
#' ## "gdm" function
#' ndvigdm <- gdm(NDVIchange ~ Climatezone + Mining + Tempchange,
#'                continuous_variable = c("Tempchange"),
#'                data = ndvi_40,
#'                discmethod = discmethod, discitv = discitv)
#' ndvigdm
#' plot(ndvigdm)
#' \dontrun{
#' #############
#' ## H1N1: h1n1_100
#' #############
#' ## set optional parameters of optimal discretization
#' discmethod <- c("equal","natural","quantile")
#' discitv <- c(4:6)
#' continuous_variable <- colnames(h1n1_100)[-c(1,11)]
#' ## "gdm" function
#' h1n1gdm <- gdm(H1N1 ~ .,
#'                continuous_variable = continuous_variable,
#'                data = h1n1_100,
#'                discmethod = discmethod, discitv = discitv)
#' h1n1gdm
#' plot(h1n1gdm)
#' }
#'
#' @export
#'
gdm <- function(formula, continuous_variable = NULL, data = NULL, discmethod, discitv){
  formula <- stats::as.formula(formula)
  formula.vars <- all.vars(formula)
  response <- data[, formula.vars[1], drop = FALSE]
  if (formula.vars[2] == "."){
    explanatory <- data[, !(colnames(data) %in% formula.vars[1]), drop = FALSE]
  } else {
    explanatory <- data[, formula.vars[-1], drop = FALSE]
  }

  ### result of optimal discretization
  if (!is.null(continuous_variable)){
    explanatory_continuous <- data[,match(continuous_variable, colnames(data)),drop=FALSE]
    n.continuous <- ncol(explanatory_continuous)
    data.ctn <- cbind(y = response[,1,drop=TRUE], explanatory_continuous)
    # debug: use new optidisc function and lapply
    odc1 <- optidisc(y ~ ., data.ctn, discmethod, discitv)
    explanatory_stra <- explanatory_continuous
    for (j in 1:n.continuous){
      breakj <- unique(odc1[[j]]$itv)
      explanatory_stra[,j] <- cut(explanatory_continuous[, j, drop = TRUE], breakj, include.lowest = TRUE)
    }
    explanatory[, match(continuous_variable, colnames(explanatory))] <- explanatory_stra
  }

  newdata <- cbind(response, explanatory)

  ### geographical detectors

  ### factor detectors
  gd1 <- gd(formula, newdata)
  ### risk detectors
  gdrm1 <- riskmean(formula, newdata)
  gdr1 <- gdrisk(formula, newdata)

  if (ncol(explanatory) == 1){
   ### interaction and ecological detectors
    cat("Factor and risk detectors are computed.
        At least two explanatory variables are required for computing
        interaction and ecological detectors.\n")
    gdi1 <- c()
    gde1 <- c()
  } else {
    ### interaction detectors
    gdi1 <- gdinteract(formula, newdata)
    ### ecological detectors
    gde1 <- gdeco(formula, newdata)
  }

  ### output
  if (is.null(continuous_variable)){
    result <- list("Factor.detector" = gd1,"Risk.mean" = gdrm1,"Risk.detector" = gdr1,
                   "Interaction.detector" = gdi1,"Ecological.detector" = gde1)
  } else {
    result <- list("Discretization" = odc1,"Factor.detector" = gd1,
                   "Risk.mean" = gdrm1,"Risk.detector" = gdr1,
                   "Interaction.detector" = gdi1,"Ecological.detector" = gde1)
  }
  ## define class
  class(result) <- "gdm"
  result
}

print.gdm <- function(x, ...){
  ### print optimal discretization
  if (length(x$Discretization)==0){
    cat("Explanatory variables are categorical variables.\n\n")
  } else {
    cat("Explanatory variables include", length(x$Discretization), "continuous variables.\n\n")
    print(x$Discretization)
  }
  ### print geographical detectors
  cat("Geographical detectors results:\n")
  cat("\nFactor detector:\n")
  print(x$Factor.detector)
  cat("\nRisk detector:\n")
  print(x$Risk.mean)
  print(x$Risk.detector)
  if (length(x$Interaction.detector) > 0){
    print(x$Interaction.detector)
    cat("\n")
    print(x$Ecological.detector)
  }
  invisible(x)
}

plot.gdm <- function(x, ...){
  ### plot optimal discretization
  lrd <- length(x$Discretization)

  if (lrd == 0){
    cat("\n\nall explanatory variables are categorical variables ...\n\n")
  } else {
    plot(x$Discretization)
  }

  ### plot geographical detectors
  cat("plot factor detectors ...\n\n")
  plot(x$Factor.detector)
  cat("plot risk mean values ...\n\n")
  plot(x$Risk.mean)
  cat("plot risk detectors ...\n\n")
  plot(x$Risk.detector)
  if (length(x$Interaction.detector) > 0){
    cat("plot interaction detectors ...\n\n")
    plot(x$Interaction.detector)
    cat("plot ecological detectors ...\n")
    plot(x$Ecological.detector)
  }
}
