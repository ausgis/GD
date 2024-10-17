#' Optimal discretization for continuous variables and visualization.
#'
#' @usage optidisc(formula, data,
#'         discmethod = discmethod, discitv = discitv)
#' \method{print}{optidisc}(x, ...)
#' \method{plot}{optidisc}(x, ...)
#'
#' @aliases optidisc print.optidisc plot.optidisc
#'
#' @param formula A formula of response and explanatory variables,
#'                where the explanatory variables must be continuous variables to be discretized.
#' @param data A data.frame includes response and explanatory variables
#' @param discmethod A character vector of discretization methods
#' @param discitv A numeric vector of numbers of intervals
#' @param x A list of \code{optidisc} result
#' @param ... Ignore
#'
#' @examples
#' ## set optional discretization methods and numbers of intervals
#' # optional methods: equal, natural, quantile, geometric, sd and manual
#' discmethod <- c("equal","quantile")
#' discitv <- c(4:5)
#' ## optimal discretization
#' odc1 <- optidisc(NDVIchange ~ Tempchange, ndvi_40, discmethod, discitv)
#' odc1
#' plot(odc1)
#'
#' @export

optidisc <- function(formula, data,
                     discmethod = discmethod, discitv = discitv){

  formula <- stats::as.formula(formula) # debug: use formula to optimize discretization
  formula.vars <- all.vars(formula)
  response <- data[, formula.vars[1], drop = TRUE]
  if (formula.vars[2] == "."){
    explanatory <- data[, !(colnames(data) %in% formula.vars[1]), drop = FALSE]
  } else {
    explanatory <- data[, formula.vars[-1], drop = FALSE]
  }
  ncolx <- ncol(explanatory)
  variable <- colnames(explanatory)

  n.itv <- length(discitv)
  n.method <- length(discmethod)
  op.itv.method <- data.frame(discmethod = rep(discmethod, each = n.itv),
                              discitv = rep(discitv, n.method)) # debug: reduce dimension

  ### calculate Q value for an explanatory variable with a number of interval and a method
  FunDiscQ <- function(y, x, f.method, f.itv){
    qv <- c()
    dc1 <- disc(x, f.itv, method = f.method)

    if (length(unique(dc1$itv)) != length(dc1$itv)){
      # remove duplicated intervals due to extremely bias data
      qv <- NA
    } else {
      x.itv <- table(cut(dc1$var, dc1$itv, include.lowest = TRUE))
      if (min(x.itv) < 2) {
        # remove number of data within itv < 2 due to sd() in q
        qv <- NA
      } else {
        stra.var1 <- cut(x, unique(dc1$itv), include.lowest = TRUE) # debug: remove stra function
        gddata <- as.data.frame(cbind(y, stra.var1))
        gd1 <- gd(y ~ stra.var1, data = gddata)
        qv <- gd1$Factor$qv
      }
    }
    return(qv)
  }
  ### optimal discretization for a continuous variable
  optidisc.list <- c()
  for (i in 1:ncolx){
    xi <- explanatory[, i, drop = TRUE]
    op.qvi <- sapply(1:nrow(op.itv.method), # debug: use sapply
                     function(x) FunDiscQ(response, xi,
                                          f.method = as.character(op.itv.method[x, 1]),
                                          f.itv = op.itv.method[x, 2]))
    k <- which(op.qvi == max(op.qvi, na.rm = TRUE))[1]
    dmk <- as.character(op.itv.method[k, 1])
    nik <- op.itv.method[k, 2]
    dc1 <- disc(xi, nik, method = dmk)
    # debug: calculate x.itv for explanatory variables
    x.itv <- table(cut(xi, dc1$itv, include.lowest = TRUE))
    qv.matrix <- matrix(op.qvi, n.itv, n.method, dimnames = list(discitv, discmethod))

    optidisc.list[[i]] <- list("method" = dmk, "n.itv" = nik, "itv" = dc1$itv,
                               "x.itv" = x.itv, "qv.matrix" = qv.matrix, "discretization" = dc1)
  }

  names(optidisc.list) <- variable

  ## define class
  class(optidisc.list) <- "optidisc"
  optidisc.list
}

print.optidisc <- function(x, ...){
  namesx <- names(x)
  for (i in 1:length(namesx)){
    cat("optimal discretization result of",namesx[i])
    cat("\n")
    cat("method             : ", x[[i]]$method)
    cat("\n")
    cat("number of intervals: ", x[[i]]$n.itv)
    cat("\n")
    cat("intervals:\n", x[[i]]$itv)
    cat("\n")
    cat("numbers of data within intervals:\n", x[[i]]$x.itv)
    cat("\n\n")
  }
  invisible(x)
}

plot.optidisc <- function(x, ...){
  # plot optimal discretization results
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

  ### optimal discretization process
  cat("Optimal discretization process ...\n\n")
  graphics::par(mfrow = c(rows, cols))
  for (i in 1:lr){
    qv.matrix <- x[[i]]$qv.matrix
    # use matplot to simplify visualization
    rname.qv <- rownames(qv.matrix)
    cname.qv <- colnames(qv.matrix)
    ncol.qv <- ncol(qv.matrix)
    graphics::matplot(x = rname.qv, y = qv.matrix, type = "p",
                      pch = 1:ncol.qv - 1,
                      col = 1:ncol.qv + 1, main = names.result[i],
                      xaxt = "n", xlab = "Number of intervals", ylab = "Q value", las = 1)
    graphics::axis(1, at = rname.qv, labels = rname.qv)
    graphics::matlines(x = rname.qv, y = qv.matrix, type = "l",
                       lty = 1:ncol.qv,
                       col = 1:ncol.qv + 1)
    # debug: use text to replace legend; use the first value !is.na to determine text location
    text.location.x <- apply(qv.matrix, 2, function(x) rname.qv[which(!is.na(x))[1]])
    text.location.y <- apply(qv.matrix, 2, function(x) x[!is.na(x)][1])
    text.k <- which(!is.na(text.location.x))
    text.location.x <- text.location.x[text.k]
    text.location.y <- text.location.y[text.k]
    text.pos <- ifelse(text.location.x == max(rname.qv), 2, 4)
    graphics::text(x = text.location.x, y = text.location.y,
                   labels = cname.qv[text.k], pos = text.pos, col = c(1:ncol.qv)[text.k] + 1)
  }
  graphics::par(mfrow = c(1, 1))

  ### optimal discretization results
  cat("Optimal discretization result ...\n\n")
  graphics::par(mfrow = c(rows, cols))
  for (i in 1:lr){
    var <- x[[i]]$discretization$var
    # debug: use basic plot functions for histogram
    graphics::hist(var, 30, col = "gray", border = "gray",
                   main = names.result[i], xlab = "Variable", las = 1)
    graphics::abline(v = x[[i]]$discretization$itv, col = "red")
    graphics::box()
  }
  graphics::par(mfrow = c(1, 1))
}


