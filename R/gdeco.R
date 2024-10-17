#' Geographical detectors: ecological detector.
#'
#' @description Function for ecological detector calculation, ecological
#' matrix and visulization.
#'
#' @usage gdeco(formula, data = NULL)
#' \method{print}{gdeco}(x, ...)
#' \method{plot}{gdeco}(x, ...)
#'
#' @aliases gdeco print.gdeco plot.gdeco
#'
#' @param formula A formula of response and explanatory variables
#' @param data A data.frame includes response and explanatory variables
#' @param x A list of ecological detector results
#' @param ... Ignore
#'
#' @examples
#' ge1 <- gdeco(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
#' ge1
#' \donttest{
#' data <- ndvi_40[,1:3]
#' ge2 <- gdeco(NDVIchange ~ ., data = data)
#' ge2
#' }
#'
#' @export
gdeco <- function(formula, data = NULL){
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
  fv <- as.data.frame(t(utils::combn(variable,2)))
  names(fv) <- c("var1","var2")

  FunF <- function(y, x1, x2){
    n <- length(y)
    g1 <- gd(y ~ x1, data = data.frame(y, x1))
    g2 <- gd(y ~ x2, data = data.frame(y, x2))
    fvalue <- g2$Factor$qv / g1$Factor$qv
    f0 <- stats::qf(0.9, df1 = n - 1, df2 = n - 1)
    eco <- ifelse(fvalue > f0 | 1/fvalue > f0 , "Y", "N")

    eco <- factor(eco, levels = c("Y", "N"))
    result <- data.frame(eco)
    return(result)
  }

  y <- response
  f.eco <- do.call(rbind, lapply(1:nrow(fv), function(x){ # debug: use lapply to replace for loop
    x1 <- explanatory[,which(variable==as.character(fv$var1[x])), drop = TRUE]
    x2 <- explanatory[,which(variable==as.character(fv$var2[x])), drop = TRUE]
    f <- FunF(y, x1, x2)
  }))

  fv <- cbind(fv, f.eco)
  fv <- list("Ecological" = fv)
  ## define class
  class(fv) <- "gdeco"
  fv
}

#' @export
print.gdeco <- function(x, ...){
  vec <- x[[1]]
  ecomatrix <- v2m(as.character(vec$eco), diag=FALSE) # debug: add as.character
  ecomatrix <- as.data.frame(ecomatrix)
  varname <- c(as.character(vec$var1),as.character(vec$var2))
  variable <- varname[!duplicated(varname)]
  names(ecomatrix) <- variable
  ecomatrix <- cbind(variable, ecomatrix)
  cat("Ecological detector:\n")
  print(ecomatrix)
  invisible(x)
}

#' @export
plot.gdeco <- function(x, ...){
  resultdata <- x[[1]]
  if (nrow(resultdata) == 1){
    stop("At least three explanatory variables are required for visulizing ecological detector.\n")
  } else {
    varname <- unique(c(as.character(resultdata$var1),as.character(resultdata$var2)))
    matrix.dim <- length(varname)

    ecomatrix <- v2m(as.character(resultdata$eco), diag = FALSE)
    ecomatrix <- t(ecomatrix[-1, -matrix.dim])

    col.vector <- as.character(resultdata$eco)
    col.vector <- ifelse(col.vector == "Y", "#FFA500", "#7FDBFF")
    col.matrix <- v2m(col.vector, diag = FALSE)
    col.matrix <- t(col.matrix[-1, -matrix.dim])

    # debug: use plot to increase speed
    graphics::par(pty = "s")
    graphics::plot(row(ecomatrix), col(ecomatrix),
                   cex = 30/(matrix.dim - 1), pch = 15, col = col.matrix,
                   xlim = c(0.5, (matrix.dim - 1) + 0.5), ylim = c(0.5, (matrix.dim - 1) + 0.5),
                   axes = FALSE, ann = FALSE, asp = 1)
    graphics::axis(1, at = 1:(matrix.dim - 1), labels = varname[1:(matrix.dim - 1)])
    graphics::axis(2, at = 1:(matrix.dim - 1), labels = varname[2:matrix.dim], las = 1)
    graphics::title(xlab = "Variable")
    graphics::text(row(ecomatrix), col(ecomatrix), labels = ecomatrix)
    graphics::box()
    graphics::par(pty = "m")
  }
}

