#' Crop a continuous raster by a binary (0/1) raster footprint (value == 1)
#'
#' @param r_bin SpatRaster. Binary raster (0/1). Cells with value 1 define the footprint.
#' @param r_cont SpatRaster. Continuous raster to crop/mask.
#' @param clip Optional SpatVector. Additional polygon to crop/mask the result.
#' @param resample_method Character. Method for resampling r_cont to r_bin grid if needed.
#' @param dissolve Logical. Dissolve contiguous 1-cells when polygonizing.
#' @param filename Optional character. If provided, writes result to disk.
#' @param overwrite Logical. Passed to writeRaster if filename is provided.
#'
#' @return SpatRaster (cropped/masked continuous raster).
#'
#' @importFrom terra rast values mask crop extract classify
#'
#' @examples
#' \donttest{
#' library(terra)
#'
#' # Create continuous raster (e.g., suitability values 0-1)
#' r_continuous <- rast(ncol = 50, nrow = 50, xmin = 0, xmax = 10,
#'                      ymin = 0, ymax = 10)
#' values(r_continuous) <- runif(ncell(r_continuous), 0, 1)
#' names(r_continuous) <- "suitability"
#'
#' # Create binary raster (circular study area)
#' r_binary <- rast(r_continuous)
#' xy <- xyFromCell(r_binary, 1:ncell(r_binary))
#' center_dist <- sqrt((xy[,1] - 5)^2 + (xy[,2] - 5)^2)
#' values(r_binary) <- ifelse(center_dist <= 3, 1, 0)
#' names(r_binary) <- "study_area"
#'
#' # Crop continuous raster to binary footprint
#' result <- bin2crop(r_bin = r_binary, r_cont = r_continuous)
#'
#' # Plot comparison
#' par(mfrow = c(1, 3))
#' plot(r_binary, main = "Binary Footprint (Study Area)")
#' plot(r_continuous, main = "Original Continuous")
#' plot(result, main = "Cropped Result")
#' }
#'
#' @export
bin2crop <- function(r_bin,
                     r_cont,
                     clip = NULL,
                     resample_method = "bilinear",
                     dissolve = TRUE,
                     filename = NULL,
                     overwrite = FALSE) {

  # === 1. Validate inputs ===
  stopifnot(inherits(r_bin,  "SpatRaster"))
  stopifnot(inherits(r_cont, "SpatRaster"))
  if (!is.null(clip)) stopifnot(inherits(clip, "SpatVector"))

  # === 2. Align grids if necessary ===
  grids_match <- isTRUE(all.equal(terra::ext(r_bin), terra::ext(r_cont))) &&
    isTRUE(all.equal(terra::res(r_bin), terra::res(r_cont)))

  if (!grids_match) {
    r_cont <- terra::resample(r_cont, r_bin, method = resample_method)
  }

  # === 3. Convert binary to polygon footprint ===
  # Replace 0 with NA (keep only cells with value = 1)
  r_footprint <- terra::classify(r_bin, cbind(0, NA))

  # Convert to polygon(s)
  poly_footprint <- terra::as.polygons(
    r_footprint,
    values = FALSE,
    aggregate = dissolve,
    na.rm = TRUE
  )

  # === 4. Crop continuous raster ===
  # Check if footprint is empty (no cells with value = 1)
  if (nrow(poly_footprint) == 0) {
    # Return empty raster (all NA, same grid as input)
    result <- r_cont
    terra::values(result) <- NA
  } else {
    # Crop and mask to footprint
    result <- terra::crop(r_cont, poly_footprint, mask = TRUE)

    # Apply optional additional clipping
    if (!is.null(clip)) {
      result <- terra::crop(result, clip, mask = TRUE)
    }
  }

  # === 5. Save to file if requested ===
  if (!is.null(filename)) {
    terra::writeRaster(result, filename, overwrite = overwrite)
  }

  return(result)
}
