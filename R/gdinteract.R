#' Geographical detectors: interaction detector.
#'
#' @description Function for interaction detector calculation and visualization.
#' The types of interactions include "Enhance, nonlinear", "Independent", "Enhance, bi-",
#' "Weaken, uni-" and "Weaken, nonlinear".
#'
#' @usage gdinteract(formula, data = NULL)
#' \method{print}{gdinteract}(x, ...)
#' \method{plot}{gdinteract}(x, ...)
#'
#' @aliases gdinteract print.gdinteract plot.gdinteract
#'
#' @param formula A formula of response and explanatory variables
#' @param data A data.frame includes response and explanatory variables
#' @param x A list of interaction detector results
#' @param ... Ignore
#'
#' @examples
#' gi1 <- gdinteract(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
#' gi1
#' \donttest{
#' data <- ndvi_40[,1:3]
#' gi2 <- gdinteract(NDVIchange ~ ., data = data)
#' gi2
#' }
#'
#' @export
gdinteract <- function(formula, data = NULL){
  formula <- stats::as.formula(formula)
  formula.vars <- all.vars(formula)
  response <- data[, formula.vars[1], drop = TRUE]
  if (formula.vars[2] == "."){
    explanatory <- data[, !(colnames(data) %in% formula.vars[1]), drop = FALSE]
  } else {
    explanatory <- data[, formula.vars[-1], drop = FALSE]
  }
  ncolx <- ncol(explanatory)

  if (ncolx == 1){
    stop("multiple explanatory variables are required for interaction detector")
  }

  variable <- colnames(explanatory)
  result <- as.data.frame(t(utils::combn(variable,2)))
  names(result) <- c("var1","var2")

  y <- response

  FunI <- function(y, x1, x2){ # debug: simplify functions
    x12 <- paste(x1, x2, sep = "_") # debug: remove stra2v function
    gddata <- data.frame(y, x1, x2, x12)
    qv1 <- gd(y ~ x1, data = gddata)[[1]]$qv
    qv2 <- gd(y ~ x2, data = gddata)[[1]]$qv
    qv12 <- gd(y ~ x12, data = gddata)[[1]]$qv

    if (qv12 < min(qv1, qv2)) {
      interaction <- c("Weaken, nonlinear")
    } else if (qv12 >= min(qv1, qv2) & qv12 <= max(qv1, qv2)) {
      interaction <- c("Weaken, uni-")
    } else if (qv12 > max(qv1, qv2) & qv12 < qv1 + qv2) {
      interaction <- c("Enhance, bi-")
    } else if (qv12 == qv1 + qv2) {
      interaction <- c("Independent")
    } else {
      interaction <- c("Enhance, nonlinear")
    }

    qvi <- cbind(data.frame(qv1, qv2, qv12), interaction)
  }

  # debug: use lapply to replace for loop
  q.itr <- do.call(rbind, lapply(1:nrow(result), function(x){
    x1 <- explanatory[,which(variable == result$var1[x]), drop = TRUE]
    x2 <- explanatory[,which(variable == result$var2[x]), drop = TRUE]
    itr <- FunI(y, x1, x2)
  }))

  result <- cbind(result, q.itr)
  result <- list("Interaction" = result)
  ## define class
  class(result) <- "gdinteract"
  result
}

print.gdinteract <- function(x, ...){
  vec <- x[[1]]
  intmatrix <- v2m(round(vec$qv12, digits=4), diag=FALSE)
  intmatrix <- as.data.frame(intmatrix)
  varname <- c(as.character(vec$var1),as.character(vec$var2))
  variable <- varname[!duplicated(varname)]
  names(intmatrix) <- variable
  intmatrix <- cbind(variable, intmatrix)
  cat("Interaction detector:\n")
  print(intmatrix)
  invisible(x)
}

plot.gdinteract <- function(x, ...){
  resultdata <- x[[1]]
  if (nrow(resultdata)==1){
    stop("At least three explanatory variables are required for visulizing interaction detector.\n")
  } else {
    varname <- unique(c(as.character(resultdata$var1),as.character(resultdata$var2)))
    matrix.dim <- length(varname)

    qv.matrix <- v2m(resultdata$qv12, diag = FALSE)
    qv.matrix <- t(qv.matrix[-1, -matrix.dim])

    interact.type <- c("Enhance, nonlinear", "Independent", "Enhance, bi-",
                       "Weaken, uni-", "Weaken, nonlinear")
    interact.col <- c("#EA4848", "#E08338", "#F2C55E", "#6EE9EF", "#558DE8")
    k.type <- match(as.character(resultdata$interaction), interact.type)
    col.vector <- interact.col[k.type]

    col.matrix <- v2m(col.vector, diag = FALSE)
    col.matrix <- t(col.matrix[-1, -matrix.dim])

    # debug: use plot to reduce time consumption
    graphics::par(pty = "s") # debug: use par(pty = "s") and asp = 1 to set same axes scale
    graphics::plot(row(qv.matrix), col(qv.matrix),
                   cex = qv.matrix * 5, pch = 20, col = col.matrix,
                   xlim = c(0.5, (matrix.dim - 1) + 0.5), ylim = c(0.5, (matrix.dim - 1) + 0.5),
                   axes = FALSE, ann = FALSE, asp = 1)
    graphics::axis(1, at = 1:(matrix.dim - 1), labels = unique(resultdata$var1))
    graphics::axis(2, at = 1:(matrix.dim - 1), labels = unique(resultdata$var2), las = 1)
    graphics::title(xlab = "Variable")
    lgd.point <- c(min(qv.matrix, na.rm = TRUE), mean(qv.matrix, na.rm = TRUE), max(qv.matrix, na.rm = TRUE))

    k <- sort(unique(k.type))
    graphics::legend("bottomright", c(sprintf("%.2f", round(lgd.point, digits = 2)), interact.type[k]),
                     col = c(rep("black", 3), interact.col[k]),
                     pch = 20, pt.cex = c(lgd.point * 5, 1, 1), cex = 0.8)
    k.maxq <- which(qv.matrix == max(qv.matrix, na.rm = TRUE), arr.ind = TRUE)
    graphics::text(x = k.maxq[1], y = k.maxq[2], labels = round(qv.matrix[k.maxq], digits = 4))
    graphics::box()
    graphics::par(pty = "m")
  }
}

