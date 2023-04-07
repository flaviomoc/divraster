#' Temporal beta diversity calculation for vector
#'
#' @param x A numeric vector with presence-absence data (0 or 1) for a set of species.
#' @param nspp Numeric. Number of species.
#' @param spp Character. Species name.
#' @param tree It can be a data frame with species traits or a phylogenetic tree.
#' @param resu Numeric. A vector to store results.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return A SpatRaster with beta results.
temp.beta.vec <- function(x, nspp, spp, tree, resu, ...){
  if (all(is.na(x))){
    resu[] <- NA
  } else if(sum(x, na.rm = TRUE) == 0){
    resu[] <- 0
  } else{
    x[is.na(x)] <- 0
    x <- rbind(x[1:nspp], x[nspp + (1:nspp)])
    colnames(x) <- spp
    resu[] <- unlist(BAT::beta(x, tree, abund = FALSE))
  }
  return(resu)
}

#' Temporal beta diversity calculation for raster
#'
#' @param bin1 A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param bin2 A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param tree It can be a data frame with species traits or a phylogenetic tree.
#' @param filename Character. Save results if a name is provided.
#' @param cores A positive integer. If cores > 1, a 'parallel' package cluster with that many cores is created and used.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return A SpatRaster with beta results.
#' @export
#'
#' @examples
#' \dontrun{
#' library(terra)
#' set.seed(100)
#' bin1 <- rast(ncol = 5, nrow = 5, nlyr = 10)
#' values(bin1) <- round(runif(ncell(bin1) * nlyr(bin1)))
#' names(bin1) <- paste0("sp", 1:10)
#' bin2 <- rast(ncol = 5, nrow = 5, nlyr = 10)
#' values(bin2) <- round(runif(ncell(bin2) * nlyr(bin2)))
#' names(bin2) <- names(bin1)
#' set.seed(100)
#' mass <- runif(10, 10, 800)
#' beak.size <- runif(10, .2, 5)
#' tail.length <- runif(10, 2, 10)
#' wing.length <- runif(10, 15, 60)
#' range.size <- runif(10, 10000, 100000)
#' traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
#' rownames(traits) <- names(bin1)
#' set.seed(100)
#' tree <- ape::rtree(n = 10, tip.label = names(bin1))
#' temp.beta(bin1, bin2)
#' temp.beta(bin1, bin2, traits)
#' temp.beta(bin1, bin2, tree)
#' }
temp.beta <- function(bin1, bin2, tree, filename = NULL,
                      cores = 1, ...){
  # Check if bin2 is NULL or invalid
  stopifnot(!is.null(substitute(bin2)), inherits(bin2, "SpatRaster"))
  # Check if bin1 is NULL or invalid
  stopifnot(!is.null(substitute(bin1)), inherits(bin1, "SpatRaster"))
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
  # Create numeric vector to store results
  resu <- numeric(3)
  # Apply the function to SpatRaster object
  if(missing(tree)){
    res <- terra::app(c(bin1, bin2), temp.beta.vec, resu = resu, nspp = nspp, spp = spp, cores = cores, ...)
  } else{
    res <- terra::app(c(bin1, bin2), temp.beta.vec, resu = resu, tree = tree, nspp = nspp, spp = spp, cores = cores, ...)
  }
  # Define names
  lyrnames <- c("Beta total", "Beta repl", "Beta rich")
  if(missing(tree)){
    names(res) <- paste0(lyrnames, ".TD")
  } else if(inherits(tree, "data.frame")){
    names(res) <- paste0(lyrnames, ".FD")
  } else{
    names(res) <- paste0(lyrnames, ".PD")
  }
  # Save output if filename is provided
  if(!is.null(filename)){
    terra::writeRaster(res, filename, overwrite = TRUE, ...)
  }
  return(res)
}
