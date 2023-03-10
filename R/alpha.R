#' Alpha calculation for a vector
#'
#' @param x A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param tree It can be a phylo object with phylogenetic tree for a set of species or a data.frame object with species traits.
#' @param resu numeric vector
#' @param ... additional arguments
#'
#' @return A numeric vector with alpha result.
spat.alpha.vec <- function(x, tree, resu, ...) {
  if (all(is.na(x))) {
    resu[] <- NA
  } else if (sum(x, na.rm = TRUE) == 0) {
    resu[] <- 0
  } else {
    x[is.na(x)] <- 0
    resu <- BAT::alpha(x, tree)
  }
  return(resu)
}

#' Alpha calculation for each raster cell
#'
#' @param bin A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param tree It can be a phylo object with phylogenetic tree for a set of species or a data.frame object with species traits.
#' @param cores A positive integer. If cores > 1, a 'parallel' package cluster with that many cores is created and used.
#' @param filename A character. Output filename.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return A SpatRaster with alpha result.
#' @export
#'
#' @examples
#' \dontrun {
#' library(terra)
#' set.seed(100)
#' bin1 <- terra::rast(ncol = 5, nrow = 5, nlyr = 10)
#' values(bin1) <- round(runif(ncell(bin1) * nlyr(bin1)))
#' names(bin1) <- paste0("sp", 1:10)
#' set.seed(100)
#' mass <- runif(10, 10, 800)
#' beak.size <- runif(10, .2, 5)
#' tail.length <- runif(10, 2, 10)
#' wing.length <- runif(10, 15, 60)
#' range.size <- runif(10, 10000, 100000)
#' traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
#' rownames(traits) <- names(bin)
#' set.seed(100)
#' tree <- ape::rtree(n = 10, tip.label = paste0("sp", 1:10))
#' spat.alpha(bin1)
#' spat.alpha(bin1, traits)
#' spat.alpha(bin1, tree)
#' }
spat.alpha <- function(bin, tree, cores = 1, filename = NULL, ...) {
  # Check if bin is NULL or invalid
  stopifnot(!is.null(substitute(bin)), inherits(bin, "SpatRaster"))
  # Check if bin and fut have at least 2 layers
  stopifnot(terra::nlyr(bin) >= 2)
  # Apply the function to SpatRaster object
  if (missing(tree)) {
    res <- terra::app(bin, spat.alpha.vec, cores = cores, ...)
  } else {
    res <- terra::app(bin, spat.alpha.vec, cores = cores, tree = tree, ...)
  }
  # Define names
  if (missing(tree)) {
    names(res) <- "Alpha.TD"
  }
  else if (inherits(tree, "data.frame")) {
    names(res) <- "Alpha.FD"
  }
  else {
    names(res) <- "Alpha.PD"
  }
  # Save the output if filename is provided
  if (!is.null(filename)) {
    terra::writeRaster(res, filename, overwrite = TRUE)
  }
  return(res)
}
