#' @title Alternative Method to Calculate Alpha Taxonomic Diversity
#'
#' @description
#' Calculates the alpha taxonomic diversity, specifically **species richness**,
#' for each cell in a `SpatRaster` object containing species presence-absence data.
#' This function provides a straightforward method to sum the number of species present
#' in each grid cell.
#'
#' @param bin A `SpatRaster` object with multiple layers, where each layer represents
#'            a species and cell values are binary (0 for absence, 1 for presence).
#'            Species names should correspond to layer names (e.g., `names(bin)`).
#' @param cores A positive integer (default is 1). If `cores > 1`, a parallel processing cluster
#'              is created using the `parallel` package to speed up calculations across raster cells.
#' @param filename Character string. Optional path and filename to save the resulting `SpatRaster`.
#'                 Supported formats are those recognized by `terra::writeRaster` (e.g., ".tif", ".grd").
#'                 If provided, the `SpatRaster` will be saved to this file.
#'
#' @return A `SpatRaster` object with a single layer named "Richness". Each cell in this
#'         `SpatRaster` contains the calculated species richness (number of species present).
#'         The output `SpatRaster` will have the same dimensions, resolution, and CRS as the input `bin`.
#' @export
#'
#' @details
#' This function calculates species richness by summing the presence (value 1) of all
#' species across layers for each individual raster cell. It is an alternative
#' to `spat.alpha()` when only Taxonomic Diversity (TD) is required, offering
#' a more direct and potentially faster computation for this specific metric.
#' `NA` values in input cells are ignored during the sum calculation.
#'
#' @examples
#' library(terra)
#'
#' # Load an example SpatRaster with binary presence-absence data
#' bin_rast <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
#'
#' # Calculate species richness (alpha taxonomic diversity)
#' richness_map <- spat.alpha2(bin_rast)
#' richness_map
#'
#' # Plot the resulting richness map
#' plot(richness_map, main = "Species Richness Map")
spat.alpha2 <- function(bin, cores = 1, filename = "") {
  # Validate input type
  if (!inherits(bin, "SpatRaster")) {
    stop("Input 'bin' must be a SpatRaster object.")
  }

  # Calculate richness by summing presence-absence values across layers for each cell
  res <- terra::app(bin, sum, na.rm = TRUE, cores = cores) # Pass cores to terra::app
  names(res) <- "Richness"

  # Save the result if a filename is provided
  if (filename != "") {
    terra::writeRaster(res,
                       filename = filename,
                       overwrite = TRUE)
  }

  return(res)
}
