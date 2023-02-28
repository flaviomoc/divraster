#' Beta temporal calculation for a vector
#'
#' @param x A numeric vector with presence-absence data (0 or 1) for a set of species.
#' @param nspp Number of species.
#' @param spp Species names.
#' @param type It can be a phylo object with phylogenetic tree for a set of species or a data.frame object with species traits.
#'
#' @return A numeric vector with beta total, turnover, and nestedness.
#' @export

.beta.temporal.vec <- function(x, nspp, spp, type) {
  x[is.na(x)] <- 0
  x <- rbind(x[1:nspp], x[nspp + (1:nspp)])
  colnames(x) <- spp
  res <- numeric(3)
  if (is.null(type)) {
    sbeta <- BAT::beta(x, abund = FALSE)
    res[] <- sapply(sbeta, function(x) x)
  }
  else {
    sbeta <- BAT::beta(x, type, abund = FALSE)
    res[] <- sapply(sbeta, function(x) x)
  }
  return(res)
}


#' Beta temporal calculation for each raster cell
#'
#' @param bin1 A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param bin2 A SpatRaster with presence-absence data (0 or 1) for a second set of species.
#' @param type It can be a phylo object with phylogenetic tree for a set of species or a data.frame object with species traits.
#' @param cores A positive integer. If cores > 1, a 'parallel' package cluster with that many cores is created and used.
#' @param filename A character. Output filename.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return A SpatRaster with beta total, turnover, and nestedness results.
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
#' names(ref) <- paste0("sp", 1:10)
#' fut <- terra::rast(array(sample(c(rep(1, 400), rep(0, 600))), dim = c(10, 10, 10)))
#' names(fut) <- names(ref)
#' set.seed(100)
#' mass <- runif(10, 10, 800)
#' beak.size <- runif(10, .2, 5)
#' tail.length <- runif(10, 2, 10)
#' wing.length <- runif(10, 15, 60)
#' range.size <- runif(10, 10000, 100000)
#' traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
#' rownames(traits) <- names(ref)
#' set.seed(100)
#' tree <- ape::rtree(n = 10, tip.label = paste0("sp", 1:10))
#' beta.td <- beta.temporal(bin1, bin2)
#' beta.td
#' beta.fd <- beta.temporal(bin1, bin2, traits)
#' beta.fd
#' beta.pd <- beta.temporal(bin1, bin2, tree)
#' beta.pd
#' }
beta.temporal <- function(bin1, bin2, type = NULL, cores = 1, filename = NULL, ...) {
  # Check if bin2 is NULL or invalid
  stopifnot(!is.null(substitute(bin2)), is(bin2, "SpatRaster"))
  # Check if bin1 is NULL or invalid
  stopifnot(!is.null(substitute(bin1)), is(bin1, "SpatRaster"))
  # Check if bin1 and bin2 are SpatRaster objects with matching names
  stopifnot(all(names(bin1) %in% names(bin2)))
  stopifnot(all(names(bin2) %in% names(bin1)))
  # Check if bin1 and bin2 have at least 2 layers
  stopifnot(terra::nlyr(bin1) >= 2, terra::nlyr(bin2) >= 2)
  # Check if bin1 and bin2 have the same number of layers
  stopifnot(terra::nlyr(bin1) == terra::nlyr(bin2))
  # Get number of species
  nspp <- terra::nlyr(bin1)
  # Get species names
  spp <- names(bin1)
  # Apply the function to SpatRaster object
  res <- terra::app(c(bin1, bin2), .beta.temporal.vec, type = type, nspp = nspp, spp = spp, cores = cores, ...)
  # Define names
  lyrnames <- c("βtotal", "βturn", "βnest")
  if (is.null(type)) {
    names(res) <- paste0(lyrnames, ".TD")
  }
  else if (is(type, "data.frame")) {
    names(res) <- paste0(lyrnames, ".FD")
  }
  else {
    names(res) <- paste0(lyrnames, ".PD")
  }
  # Save output if filename is provided
  if (!is.null(filename)) {
    terra::writeRaster(res, filename, overwrite = TRUE)
  }
  return(res)
}
