#' Geographical detectors: risk detector.
#'
#' @description Function for risk detector calculation, risk matrix and visualization.
#'
#' @usage gdrisk(formula, data = NULL)
#' \method{print}{gdrisk}(x, ...)
#' \method{plot}{gdrisk}(x, ...)
#'
#' @aliases gdrisk print.gdrisk plot.gdrisk
#'
#' @param formula A formula of response and explanatory variables
#' @param data A data.frame includes response and explanatory variables
#' @param x A list of risk detector results
#' @param ... Ignore
#'
#' @examples
#' gr1 <- gdrisk(NDVIchange ~ Climatezone + Mining, data = ndvi_40)
#' gr1
#' plot(gr1)
#' \donttest{
#' data <- ndvi_40[,1:3]
#' gr2 <- gdrisk(NDVIchange ~ ., data = data)
#' gr2
#' }
#'
#' @export
gdrisk <- function(formula, data = NULL){
  formula <- stats::as.formula(formula)
  formula.vars <- all.vars(formula)
  response <- data[, formula.vars[1], drop = TRUE]
  if (formula.vars[2] == "."){
    explanatory <- data[, !(colnames(data) %in% formula.vars[1]), drop = FALSE]
  } else {
    explanatory <- data[, formula.vars[-1], drop = FALSE]
  }
  ncolx <- ncol(explanatory)

  variable <- colnames(explanatory)

  FunT.itv <- function(y1, y2){ # debug: use function
    lengthy <- ifelse(length(y1) >= length(y2), length(y1), length(y2))

    tt <- tryCatch({
      stats::t.test(y1,y2)
    }, error = function(y1,y2){
      data.frame("statistic" = 0,
                 "parameter" = lengthy - 1,
                 "p.value" = 1)
    })

    risk <- ifelse(tt$p.value < 0.05, "Y", "N")
    risk <- factor(risk, levels = c("Y", "N"))

    t.risk <- cbind(data.frame(t = tt$statistic, df = tt$parameter, sig = tt$p.value,
                               row.names = c()), risk)
  }

  FunT.var <- function(y, x){ # debug: use function and lapply
    # t test by pairs
    itv <- levels(factor(x))
    citv <- length(itv)
    tv <- as.data.frame(t(utils::combn(itv,2)))
    names(tv) <- c("itv1","itv2")
    tv$itv1 <- factor(tv$itv1, levels = itv)
    tv$itv2 <- factor(tv$itv2, levels = itv)

    t.var <- do.call(rbind, lapply(1:nrow(tv), function(u){
      y1 <- y[x %in% as.character(tv[u, 1])]
      y2 <- y[x %in% as.character(tv[u, 2])]
      t.itv <- FunT.itv(y1, y2)
    }))

    tv <- cbind(tv, t.var)
  }

  result <- lapply(1:ncolx, function(u) FunT.var(response, explanatory[, u, drop = TRUE]))
  names(result) <- variable

  ## define class
  class(result) <- "gdrisk"
  result
}

print.gdrisk <- function(x, ...){
  lr <- length(x)
  names.result <- names(x)
  plotriskmatrix <- list()
  for (i in 1:lr){
    vec <- x[[i]]
    riskmatrix <- v2m(as.character(vec$risk), diag=FALSE)
    itvname <- c(as.character(vec$itv1),as.character(vec$itv2))
    interval <- itvname[!duplicated(itvname)]

    ## export matrix data.frame
    riskmatrix <- as.data.frame(riskmatrix)
    names(riskmatrix) <- interval
    riskmatrix <- cbind(interval, riskmatrix)

    cat(names.result[i])
    cat("\n")
    print(riskmatrix)
    cat("\n")
  }
  invisible(x)
}

plot.gdrisk <- function(x, ...){
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

  max.length.name <- max(sapply(x, function(x)
    max(nchar(c(as.character(x$itv1),as.character(x$itv2))))))
  mar.y <- max.length.name/4
  graphics::par(mfrow = c(rows, cols), pty = "s", mar = c(2, mar.y + 3.1, 2, 2))

  for (i in 1:lr){
    vec <- x[[i]]
    itvname <- unique(c(as.character(vec$itv1),as.character(vec$itv2)))
    matrix.dim <- length(itvname)

    riskmatrix <- v2m(as.character(vec$risk), diag = FALSE)
    riskmatrix <- t(riskmatrix[-1, -matrix.dim])

    col.vector <- as.character(vec$risk)
    col.vector <- ifelse(col.vector == "Y", "#FFA500", "#7FDBFF")
    col.matrix <- v2m(col.vector, diag = FALSE)
    col.matrix <- t(col.matrix[-1, -matrix.dim])

    # debug: use plot to increase speed

    # debug: adjust cex.size
    cex.size <- ifelse(rows == cols, (40 - mar.y * cols)/(cols * (matrix.dim - 1)),
                       (60 - mar.y * cols)/(rows * floor(cols/rows) * (matrix.dim - 1))) * 1.1
    graphics::plot(row(riskmatrix), col(riskmatrix),
                   cex = cex.size, pch = 15, col = col.matrix,
                   xlim = c(0.5, (matrix.dim - 1) + 0.5), ylim = c(0.5, (matrix.dim - 1) + 0.5),
                   axes = FALSE, ann = FALSE, asp = 1)
    graphics::axis(1, at = 1:(matrix.dim - 1), labels = unique(vec$itv1), tck = -0.025)
    graphics::axis(2, at = 1:(matrix.dim - 1), labels = unique(vec$itv2), las = 1, tck = -0.025)
    graphics::title(main = names.result[i])
    graphics::text(row(riskmatrix), col(riskmatrix), labels = riskmatrix)
    graphics::box()
  }

  graphics::par(mfrow = c(1, 1), pty = "m", mar = c(5.1, 4.1, 4.1, 2.1))
}

