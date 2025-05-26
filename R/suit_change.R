#' @title Species Suitability Change Between Climate Scenarios
#'
#' @description Compares two `SpatRaster` objects, each containing species presence-absence data
#' for multiple species under different climate scenarios (e.g., baseline vs. future).
#' It calculates and encodes the change in habitat suitability (gain, loss, unchanged, unsuitable)
#' for each species in each raster cell.
#'
#' @param r1 A `SpatRaster` with multiple layers. Each layer represents a species'
#'           presence-absence data (0 for absence, 1 for presence) for the
#'           **baseline climate scenario**. Layer names should correspond to species names.
#' @param r2 A `SpatRaster` with multiple layers. Each layer represents a species'
#'           presence-absence data (0 for absence, 1 for presence) for the
#'           **future climate scenario**. Layer names should correspond to species names
#'           and must match those in `r1`.
#' @param filename Character string. Optional path and filename to save the resulting `SpatRaster`
#'                  stack. Supported formats are those recognized by `terra::writeRaster`
#'                  (e.g., ".tif", ".grd"). If provided, the `SpatRaster` will be saved to this file.
#'
#' @return A `SpatRaster` object with multiple layers, where each layer corresponds to a species
#' from the input SpatRasters. Cell values are encoded as follows:
#' 1 = Gain: Species absent in r1 (baseline) becomes present in r2 (future).
#' 2 = Loss: Species present in r1 (baseline) becomes absent in r2 (future).
#' 3 = Unchanged (Presence): Species present in both r1 and r2.
#' 4 = Unsuitable (Both): Species absent in both r1 and r2.
#' The dimensions, resolution, and layer names of the output raster will match those of the input
#' r1 and r2.
#'
#' @details This function processes each species layer independently. It's crucial that
#'          both input `SpatRaster`s (`r1` and `r2`) have the same extent, resolution, and
#'          the same number of layers, with corresponding layers representing the same species.
#'          The function expects binary (0 or 1) presence-absence data.
#'
#' @export
#'
#' @examples
#' library(terra)
#'
#' # Load example rasters for baseline and future climate scenarios
#' r1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
#' r2 <- terra::rast(system.file("extdata", "fut.tif", package = "divraster"))
#'
#' # Calculate suitability change
#' change_map <- suit.change(r1, r2)
#' change_map
suit.change <- function(r1, r2, filename = "") {
  # Ensure inputs are SpatRaster objects with the same number of layers
  if (!inherits(r1, "SpatRaster") || !inherits(r2, "SpatRaster")) {
    stop("Both r1 and r2 must be SpatRaster objects.")
  }

  if (terra::nlyr(r1) != terra::nlyr(r2)) {
    stop("r1 and r2 must have the same number of layers.")
  }

  # Add check for extent and resolution consistency, which is crucial for
  # comparison
  if (!terra::compareGeom(r1, r2, res = TRUE,
                          ext = TRUE, rowcol = TRUE)) {
    stop("Input rasters r1 and r2 must have the same extent,
         resolution, and dimensions.")
  }

  # Initialize a list to collect change layers
  change_layers <- list()

  # Loop over each layer to compare presence-absence data
  for (i in 1:terra::nlyr(r1)) {
    r1_layer <- r1[[i]]  # Extract the current layer from the baseline raster
    r2_layer <- r2[[i]]  # Extract the current layer from the future raster

    # Determine changes in species suitability
    gain <- (r2_layer == 1) & (r1_layer == 0)       # Species gained (1)
    loss <- (r2_layer == 0) & (r1_layer == 1)       # Species lost (2)
    no_change <- (r2_layer == 1) & (r1_layer == 1)  # No change in presence (3)
    unsuitable_both <- (r2_layer == 0) & (r1_layer == 0) # Both scenarios unsuitable (4)

    # Encode changes into a single map
    change_map <- gain * 1 + loss * 2 + no_change * 3 + unsuitable_both * 4
    names(change_map) <- names(r1)[i] # Assign the name of the layer

    change_layers[[i]] <- change_map  # Store the change map in the list
  }

  # Combine all change maps into one SpatRaster
  result_stack <- terra::rast(change_layers)

  # Save output if filename is provided
  if (filename != "") {
    terra::writeRaster(result_stack, filename = filename, overwrite = TRUE)
  }

  return(result_stack)  # Return the SpatRaster with suitability changes
}
