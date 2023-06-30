#' Temporal beta diversity calculation for vector
#'
#' @description Calculates temporal beta diversity for
#' taxonomic (TD), functional (FD), and phylogenetic (PD)
#' dimensions. Adapted from \code{\link[BAT]{beta}}
#'
#' @param x A numeric vector with presence-absence data (0 or 1)
#' for a set of species.
#' @param nspp Numeric. Number of species.
#' @param spp Character. Species name.
#' @param tree It can be a data frame with species traits or a
#' phylogenetic tree.
#' @param resu Numeric. A vector to store results.
#' @param ... Additional arguments to be passed passed down from
#' a calling function.
#'
#' @return A SpatRaster with beta results (total, replacement,
#' and richness differences).
temp.beta.vec <- function(x, nspp, spp, tree, resu, ...) {
  if (all(is.na(x))) {
    resu[] <- NA
  } else if (sum(x, na.rm = TRUE) == 0) {
    resu[] <- 0
  } else {
    x[is.na(x)] <- 0
    x <- rbind(x[1:nspp], x[nspp + (1:nspp)])
    colnames(x) <- spp
    resu[] <- unlist(BAT::beta(x, tree, abund = FALSE))
  }
  return(resu)
}

#' Temporal beta diversity calculation for raster
#'
#' @param bin1 A SpatRaster with presence-absence data (0 or 1)
#' for a set of species.
#' @param bin2 A SpatRaster with presence-absence data (0 or 1)
#' for a set of species.
#' @param tree It can be a data frame with species traits or a
#' phylogenetic tree.
#' @param filename Character. Save results if a name is provided.
#' @param cores A positive integer. If cores > 1, a 'parallel'
#' package cluster with that many cores is created and used.
#' @param ... Additional arguments to be passed passed down from
#' a calling function.
#'
#' @return A SpatRaster with beta results (total, replacement,
#' and richness differences).
#' @export
#'
#' @examples
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' bin2 <- terra::rast(system.file("extdata", "fut.tif",
#' package = "divraster"))
#' traits <- read.csv(system.file("extdata", "traits.csv",
#' package = "divraster"), row.names = 1)
#' tree <- ape::read.tree(system.file("extdata", "tree.tre",
#' package = "divraster"))
#' temp.beta(bin1, bin2)
#' temp.beta(bin1, bin2, traits)
#' temp.beta(bin1, bin2, tree)
temp.beta <- function(bin1, bin2, tree, filename = NULL,
                      cores = 1, ...) {
  # Check if rasters are NULL or invalid
  if (is.null(bin1) || !inherits(bin1, "SpatRaster")) {
    stop("'bin1' must be a SpatRaster.")
  }
  if (is.null(bin2) || !inherits(bin2, "SpatRaster")) {
    stop("'bin2' must be a SpatRaster.")
  }
  # Check if coordinates are geographic
  if (!terra::is.lonlat(bin1) | !terra::is.lonlat(bin2)) {
    stop("Both rasters must have geographic coordinates.")
  }
  if (terra::nlyr(bin1) < 2 | terra::nlyr(bin2) < 2) {
    stop("Rasters must have at least 2 layers.")
  }
  # Check if the names of bin1 and bin2 match
  if (!identical(names(bin1), names(bin2))) {
    stop("The names of the rasters do not match.")
  }
  # Get number of species
  nspp <- terra::nlyr(bin1)
  # Get species names
  spp <- names(bin1)
  # Create numeric vector to store results
  resu <- numeric(3)
  # Apply the function to SpatRaster object
  if (missing(tree)) {
    res <- terra::app(c(bin1, bin2),
                      temp.beta.vec,
                      resu = resu,
                      nspp = nspp,
                      spp = spp,
                      cores = cores, ...)
  } else {
    # Check if 'tree' object is valid
    if (!inherits(tree, c("data.frame", "phylo"))) {
      stop("'tree' must be a data.frame or a phylo object.")
    }
    res <- terra::app(c(bin1, bin2),
                      temp.beta.vec,
                      resu = resu,
                      tree = tree,
                      nspp = nspp,
                      spp = spp,
                      cores = cores, ...)
  }
  # Define names
  lyrnames <- c("Btotal", "Brepl", "Brich")
  if (missing(tree)) {
    names(res) <- paste0(lyrnames, "_TD")
  } else if (inherits(tree, "data.frame")) {
    names(res) <- paste0(lyrnames, "_FD")
  } else {
    names(res) <- paste0(lyrnames, "_PD")
  }
  # Save output if filename is provided
  if (!is.null(filename)) {
    terra::writeRaster(res, filename, overwrite = TRUE, ...)
  }
  return(res)
}
