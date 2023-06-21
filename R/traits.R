#' Average trait calculation for vector
#'
#' @param x A numeric vector with presence-absence data (0 or 1) for a set of species.
#' @param col_trait A numeric vector with trait numbers.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return Vector of average trait.
spat.trait.vec <- function(x, col_trait, ...) {
  x1 <- x == 1
  mean((x * col_trait)[x1], na.rm = TRUE)
}

#' Average trait calculation for raster
#'
#' @description Compute average for each trait.
#' @param x A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param trait A data.frame with species traits.
#' @param cores A positive integer. If cores > 1, a 'parallel' package cluster with that many cores is created and used.
#' @param filename Character. Save results if a name is provided.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return SpatRaster with average traits.
#' @export
#'
#' @examples
#' \dontrun{
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
#' traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)
#' spat.trait(bin1, traits)
#' }
spat.trait <- function(x, trait, cores = 1, filename = NULL, ...) {
  # Check if x is NULL or invalid
  if(is.null(x) || !inherits(x, "SpatRaster")){
    stop("'x' must be a SpatRaster.")
  }
  # Check if coordinates are geographic
  if(!terra::is.lonlat(x)){
    stop("'x' must has geographic coordinates.")
  }
  if(terra::nlyr(x) < 2){
    stop("'x' must has at least 2 layers.")
  }
  # Select numeric traits only
  trait <- trait[, sapply(trait, is.numeric)]
  # Create list to store result
  res <- vector("list", ncol(trait))
  # Get traits names
  trait_names <- colnames(trait)
  for (col in seq_along(trait)) {
    # Select trait
    col_trait <- trait[, col]
    # Get selected trait name
    trait_name <- trait_names[col]
    # Apply the function to SpatRaster object
    res[[col]] <- terra::app(x, spat.trait.vec, col_trait = col_trait, cores = cores, ...)
    # Add trait names
    names(res)[col] <- trait_name
  }
  # Transform list into SpatRaster
  res <- terra::rast(res)
  # Save the output if filename is provided
  if (!is.null(filename)) {
    terra::writeRaster(res, filename, overwrite = TRUE, ...)
  }
  return(res)
}
