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
#' @export
bin2crop <- function(r_bin,
                     r_cont,
                     clip = NULL,
                     resample_method = "bilinear",
                     dissolve = TRUE,
                     filename = NULL,
                     overwrite = FALSE) {
  
  stopifnot(inherits(r_bin,  "SpatRaster"))
  stopifnot(inherits(r_cont, "SpatRaster"))
  if (!is.null(clip)) stopifnot(inherits(clip, "SpatVector"))
  
  # Align grids if needed (common in workflows mixing rasters)
  if (!isTRUE(all.equal(terra::ext(r_bin), terra::ext(r_cont))) ||
      !isTRUE(all.equal(terra::res(r_bin), terra::res(r_cont)))) {
    r_cont <- terra::resample(r_cont, r_bin, method = resample_method)
  }
  
  # Set 0 -> NA so polygonization yields only the footprint of 1s
  r1 <- terra::classify(r_bin, rcl = matrix(c(0, NA), ncol = 2, byrow = TRUE)) 
  
  # Polygonize the footprint
  p1 <- terra::as.polygons(r1, values = FALSE, aggregate = dissolve, na.rm = TRUE) 
  
  # If there is no area with value==1, return an all-NA raster on same grid
  if (nrow(p1) == 0) {
    out <- r_cont
    terra::values(out) <- NA
  } else {
    # Crop/mask by footprint
    out <- terra::crop(r_cont, p1, mask = TRUE) 
    
    # Optional second crop/mask
    if (!is.null(clip)) {
      out <- terra::crop(out, clip, mask = TRUE) 
    }
  }
  
  # Optional write to disk
  if (!is.null(filename)) {
    terra::writeRaster(out, filename, overwrite = overwrite) 
  }
  
  out
}
