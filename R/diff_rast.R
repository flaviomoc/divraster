#' @title Calculate Absolute or Percentage Difference Between SpatRaster Objects
#'
#' @description
#' Computes the difference between two `SpatRaster` objects, either as an absolute value
#' or as a percentage of change relative to the first raster (`r1`).
#' This function is commonly used to assess changes in spatial patterns, such as
#' shifts in species richness or environmental variables over time or between scenarios.
#'
#' @param r1 A `SpatRaster` object representing the baseline or initial values.
#'           Can have one or multiple layers.
#' @param r2 A `SpatRaster` object representing the future or comparison values.
#'           Must have the same dimensions, resolution, CRS, and number of layers as `r1`.
#' @param perc Logical (default is `TRUE`). If `TRUE`, the percentage of change
#'             relative to `r1` is calculated: `((r2 - r1) / r1) * 100`.
#'             If `FALSE`, the absolute difference (`r2 - r1`) is returned.
#' @param filename Character string. Optional path and filename to save the resulting
#'                `SpatRaster`. Supported formats are those recognized by `terra::writeRaster`
#'                 (e.g., ".tif", ".grd"). If provided, the `SpatRaster` will be saved to
#'                 this file.
#'
#' @return A `SpatRaster` object containing the calculated differences.
#'         \itemize{
#'           \item If `perc = TRUE`, the layer name will be "Percentage_Difference".
#'           \item If `perc = FALSE`, the layer name will be "Absolute_Difference".
#'         }
#'         The output `SpatRaster` will have the same dimensions, resolution, and CRS as
#'         the input rasters.
#' @export
#'
#' @details
#' This function performs a cell-wise subtraction (`r2 - r1`).
#' \itemize{
#'   \item For **percentage difference**, the formula used is `((r2 - r1) / r1) * 100`.
#'         Cells where `r1` is `NA` or `0` will result in `NA` in the output
#'         `SpatRaster` for percentage calculations, to avoid division by zero or
#'         meaningless percentages.
#'   \item It is crucial that `r1` and `r2` are aligned spatially (same extent,
#'         resolution, and Coordinate Reference System - CRS) and have the
#'         same number of layers, with corresponding layers representing the
#'         same variable or species.
#' }
#'
#' @examples
#' library(terra)
#'
#' # Load rasters
#' rich1 <- terra::rast(system.file("extdata", "rich_ref.tif",
#' package = "divraster"))
#' rich2 <- terra::rast(system.file("extdata", "rich_fut.tif",
#' package = "divraster"))
#'
#' # Calculate absolute difference in richness
#' abs_diff_rast <- differ.rast(rich1, rich2, perc = FALSE)
#' abs_diff_rast
#' plot(abs_diff_rast, main = "Absolute Difference in Richness")
#'
#' # Calculate percentage difference in richness
#' perc_diff_rast <- differ.rast(rich1, rich2, perc = TRUE)
#' perc_diff_rast
#' plot(perc_diff_rast, main = "Percentage Difference in Richness")
differ.rast <- function(r1, r2, perc = TRUE, filename = "") {
  # Validate input types
  if (!inherits(r1, "SpatRaster") || !inherits(r2, "SpatRaster")) {
    stop("Both 'r1' and 'r2' must be SpatRaster objects.")
  }

  # Check that the rasters have the same dimensions, resolution, and CRS
  if (!terra::compareGeom(r1, r2, res = TRUE, ext = TRUE, crs = TRUE)) {
    stop("Rasters 'r1' and 'r2' must have the same extent, resolution, and CRS.")
  }

  # Also check if they have the same number of layers for meaningful comparison
  if (terra::nlyr(r1) != terra::nlyr(r2)) {
    stop("Rasters 'r1' and 'r2' must have the same number of layers for comparison.")
  }

  # Calculate the difference (r2 - r1)
  diff_rast <- r2 - r1

  # Calculate percentage difference if requested
  if (perc) {
    # Calculate percentage difference, handling division by zero or NA values in r1
    # Cells where r1 is NA or 0 will result in NA in the output for percentage diff
    perc_diff_rast <- (diff_rast / r1) * 100
    perc_diff_rast[is.na(r1) | r1 == 0] <- NA # Ensure NA or 0 in r1 yields NA in perc_diff

    names(perc_diff_rast) <- "Percentage_Difference"
    diff_final <- perc_diff_rast
  } else {
    names(diff_rast) <- "Absolute_Difference"
    diff_final <- diff_rast
  }

  # Save the result if a filename is provided
  if (filename != "") {
    terra::writeRaster(diff_final, filename = filename, overwrite = TRUE)
  }

  return(diff_final)
}
