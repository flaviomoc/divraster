#' Alpha calculation for vector
#'
#' @param x A numeric vector with presence-absence data (0 or 1) for a set of species.
#' @param tree It can be a data frame with species traits or a phylogenetic tree.
#' @param resu Numeric. A vector to store results.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return A SpatRaster with alpha result.
spat.alpha.vec <- function(x, tree, resu, ...){
  if(all(is.na(x))){
    resu[] <- NA
  } else if(sum(x, na.rm = TRUE) == 0){
    resu[] <- 0
  } else{
    x[is.na(x)] <- 0
    resu <- BAT::alpha(x, tree)
  }
  return(resu)
}

#' Alpha calculation for raster
#'
#' @description Compute alpha diversity for taxonomic, functional, and phylogenetic diversity.
#' @param bin A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param tree It can be a data frame with species traits or a phylogenetic tree.
#' @param cores A positive integer. If cores > 1, a 'parallel' package cluster with that many cores is created and used.
#' @param filename Character. Save results if a name is provided.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return A SpatRaster with alpha result.
#' @export
#'
#' @examples
#' \dontrun{
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "DMSD"))
#' traits <- read.csv(system.file("extdata", "traits.csv", package = "DMSD"), row.names = 1)
#' tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "DMSD"))
#' spat.alpha(bin1)
#' spat.alpha(bin1, traits)
#' spat.alpha(bin1, tree)
#' }
spat.alpha <- function(bin, tree, cores = 1, filename = NULL, ...){
  # Check if coordinates are geographic
  if(!terra::is.lonlat(bin)){
    stop("'bin' must has geographic coordinates.")
  }
  # Transform RasterStack into SpatRaster
  if(!inherits(bin, "SpatRaster")){
    bin <- terra::rast(bin)
  }
  # Check if bin is NULL or invalid
  if(is.null(bin) || !inherits(bin, "SpatRaster")){
    stop("'bin' must be a SpatRaster.")
  }
  if(terra::nlyr(bin) < 2){
    stop("'bin' must has at least 2 layers.")
  }
  # Create numeric vector to store result
  resu <- numeric(1)
  # Apply the function to SpatRaster object
  if(missing(tree)){
    res <- terra::app(bin, spat.alpha.vec, resu = resu, cores = cores, ...)
  } else{
    # Check if 'tree' object is valid
    if(!inherits(tree, c("data.frame", "phylo"))){
      stop("'tree' must be a data.frame or a phylo object.")
    }
    res <- terra::app(bin, spat.alpha.vec, resu = resu, cores = cores, tree = tree, ...)
  }
  # Define names
  if(missing(tree)){
    names(res) <- "Alpha_TD"
  }
  else if(inherits(tree, "data.frame")){
    names(res) <- "Alpha_FD"
  }
  else{
    names(res) <- "Alpha_PD"
  }
  # Save the output if filename is provided
  if(!is.null(filename)){
    terra::writeRaster(res, filename, overwrite = TRUE)
  }
  return(res)
}
