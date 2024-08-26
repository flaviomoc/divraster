#' Difference between raster objects
#'
#' @param r1 A SpatRaster object.
#' @param r2 A SpatRaster object.
#' @param perc Boolean. Default is TRUE to calculate the percentage
#' of change between r1 and r2. FALSE gives the absolute number
#' instead.
#' @param filename Character. Save results if a name is provided.
#'
#' @return A SpatRaster object with the difference between
#' r1 and r2.
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' rich1 <- terra::rast(system.file("extdata", "rich_ref.tif",
#' package = "divraster"))
#' rich2 <- terra::rast(system.file("extdata", "rich_fut.tif",
#' package = "divraster"))
#' differ.rast(rich1, rich2)
#' }
differ.rast <- function(r1, r2, perc = TRUE, filename = "") {
  # Check that the rasters have the same resolution and extent
  if (!terra::compareGeom(r1, r2, stopOnError = FALSE)) {
    stop("r1 and r2 must have the same extent and resolution")
  }

  # Calculate the difference
  diff <- r2 - r1  # Ensure this returns a raster

  # Calculate percentage difference if requested
  if (perc) {
    # Calculate percentage difference
    perc_diff <- (diff / r1) * 100
    perc_diff[is.na(r1) | r1 == 0] <- NA  # Handle NA and zero values properly
    names(perc_diff) <- "Percentage Difference"
    diff <- perc_diff
  } else {
    names(diff) <- "Absolute Difference"
  }

  # Save the result if a filename is provided
  if (filename != "") {
    terra::writeRaster(diff, filename = filename, overwrite = TRUE)
  }

  return(diff)
}
