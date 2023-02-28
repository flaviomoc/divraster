#' Alpha calculation for a vector
#'
#' @param x A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param type It can be a phylo object with phylogenetic tree for a set of species or a data.frame object with species traits.
#'
#' @return A numeric vector with alpha result.
#' @export

.alpha.vec <- function(x, type) {
  if (is.null(type)) {
    salpha <- BAT::alpha(x)
  }
  else {
    salpha <- BAT::alpha(x, type)
  }
  return(salpha)
}

#' Alpha calculation for each raster cell
#'
#' @param bin A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param type It can be a phylo object with phylogenetic tree for a set of species or a data.frame object with species traits.
#' @param cores A positive integer. If cores > 1, a 'parallel' package cluster with that many cores is created and used.
#' @param filename A character. Output filename.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return A SpatRaster with alpha result.
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' bin <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
#' names(bin) <- paste0("sp", 1:10)
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
#' alpha.td <- alpha(bin)
#' alpha.td
#' alpha.fd <- alpha(bin, traits)
#' alpha.fd
#' alpha.pd <- alpha(bin, tree)
#' alpha.pd
#' }
alpha <- function(bin, type = NULL, cores = 1, filename = NULL, ...) {
  # Check if bin is NULL or invalid
  stopifnot(!is.null(substitute(bin)), inherits(bin, "SpatRaster"))
  # Check if bin and fut have at least 2 layers
  stopifnot(terra::nlyr(bin) >= 2)
  # Apply the function to SpatRaster object
  res <- terra::app(bin, .alpha.vec, type = type, cores = cores, ...)
  # Define names
  if (is.null(type)) {
    names(res) <- "α.TD"
  }
  else if (inherits(type, "data.frame")) {
    names(res) <- "α.FD"
  }
  else {
    names(res) <- "α.PD"
  }
  # Save the output if filename is provided
  if (!is.null(filename)) {
    terra::writeRaster(res, filename, overwrite = TRUE)
  }
  return(res)
}
