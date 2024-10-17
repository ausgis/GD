#' Comparison of size effects of spatial units.
#'
#' @description Function for comparison of size effects of spatial units
#' in spatial heterogeneity analysis.
#'
#' @usage sesu(gdlist, su)
#'
#' @param gdlist A list of \code{gdm} result or \code{gd} result
#' @param su A vector of sizes of spatial units
#'
#' @examples
#' ndvilist <- list(ndvi_30, ndvi_40, ndvi_50)
#' su <- c(30, 40, 50) ## sizes of spatial units
#' ## "gdm" function
#' gdlist <- lapply(ndvilist, function(x){
#'   gdm(NDVIchange ~ Climatezone + Mining, data = x)
#' })
#' sesu(gdlist, su) ## size effects of spatial units
#'
#' @export
#'
sesu <- function(gdlist, su){
  nsu <- length(su)
  if (nsu < 2){
    stop("At least two sizes of spatial unit are required for comparison.\n\n")
  }
  # debug: use matplot to simplify visualization
  var <- as.character(gdlist[[1]]$Factor.detector$Factor$variable)
  qv <- t(sapply(gdlist, function(x) x$Factor.detector$Factor$qv))
  sig <- t(sapply(gdlist, function(x) x$Factor.detector$Factor$sig))

  qv[which(sig >= 0.05)] <- NA
  qv90 <- apply(qv, 1, function(x) quantile(x, 0.9, na.rm = TRUE))

  rnames <- su
  cnames <- var
  ncol.qv <- ncol(qv)

  graphics::par(mar = c(5.1, 4.1, 2.1, 5.1))
  graphics::matplot(x = su, y = qv, type = "p",
                    pch = 1:ncol.qv - 1, col = 1:ncol.qv + 1,
                    xaxt = "n", xlab = "Size of spatial unit", ylab = "Q value", las = 1)
  graphics::axis(1, at = rnames, labels = rnames)
  graphics::matlines(x = rnames, y = qv, type = "l",
                     lty = 1:ncol.qv,
                     col = 1:ncol.qv + 1)
  text.location.y <- apply(qv, 2, function(x) x[!is.na(x)][1])
  graphics::text(x = rnames[1], y = text.location.y,
                 labels = cnames, pos = 4, col = 1:ncol.qv + 1)

  graphics::par(new = T)
  graphics::plot(x = su, y = qv90, type = "b", pch = 16, cex = 0.8, axes = F, xlab = NA, ylab = NA)
  graphics::axis(side = 4, las = 1)
  graphics::mtext(side = 4, line = 3, 'The 90% quantile of Q values')
  graphics::text(x = rnames[nsu], y = qv90[nsu], labels = "90% quantile", pos = 2)

  graphics::par(mar = c(5.1, 4.1, 4.1, 2.1))
}


