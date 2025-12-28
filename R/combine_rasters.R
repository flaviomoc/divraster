#' Combine GeoTIFF rasters into a multilayer SpatRaster
#'
#' Reads GeoTIFF files from a directory OR combines already-loaded SpatRasters.
#' Computes the union of their extents, resamples them to a common grid,
#' and returns a single multilayer SpatRaster.
#'
#' The first raster (file or list element) defines the target resolution,
#' origin and CRS; the union of all extents defines the spatial coverage.
#' Areas where a raster has no data are filled with NA.
#'
#' @param raster_list Optional list of SpatRaster objects already loaded in R.
#'   If provided, dir_path and pattern are ignored.
#' @param dir_path Character. Directory containing input GeoTIFF files.
#'   Only used if raster_list is NULL.
#' @param pattern Character. Pattern that file names must contain.
#'   Only used if raster_list is NULL.
#' @param method Character. Resampling method passed to terra::resample(),
#'   e.g. "bilinear" (default) or "near" for categorical data.
#'
#' @return A single multilayer SpatRaster with one layer per input.
#'   Layers are named from list names or file basenames without extension.
#'
#' @importFrom terra rast values mask crop extract classify
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Create 3 separate rasters with different extents
#' r1 <- rast(ncol = 30, nrow = 30, xmin = 0, xmax = 10,
#'            ymin = 0, ymax = 10, crs = "EPSG:4326")
#' values(r1) <- runif(ncell(r1), 0, 100)
#'
#' r2 <- rast(ncol = 30, nrow = 30, xmin = 1, xmax = 11,
#'            ymin = 1, ymax = 11, crs = "EPSG:4326")
#' values(r2) <- runif(ncell(r2), 0, 100)
#'
#' r3 <- rast(ncol = 30, nrow = 30, xmin = -1, xmax = 9,
#'            ymin = -1, ymax = 9, crs = "EPSG:4326")
#' values(r3) <- runif(ncell(r3), 0, 100)
#'
#' # Combine into single multilayer SpatRaster
#' raster_list <- list(baseline = r1, future_A = r2, future_B = r3)
#' combined <- combine.rasters(raster_list = raster_list)
#' combined
#' }
#'
#' @export
combine.rasters <- function(raster_list = NULL,
                            dir_path = NULL,
                            pattern = NULL,
                            method = "bilinear") {

  # === 1. Determine input mode (list vs. files) ===
  use_list <- !is.null(raster_list)
  use_files <- !is.null(dir_path) && !is.null(pattern)

  if (!use_list && !use_files) {
    stop("Either provide raster_list OR both dir_path and pattern")
  }

  if (use_list && use_files) {
    warning("Both raster_list and dir_path provided. Using raster_list.")
  }

  # === 2. Get rasters and names ===
  if (use_list) {
    # From loaded SpatRasters
    if (!is.list(raster_list)) {
      stop("raster_list must be a list of SpatRaster objects")
    }

    if (length(raster_list) == 0) {
      stop("raster_list cannot be empty")
    }

    # Validate all are SpatRasters
    valid_rasters <- sapply(raster_list, inherits, "SpatRaster")
    if (!all(valid_rasters)) {
      invalid_idx <- which(!valid_rasters)
      stop("Elements ", paste(invalid_idx, collapse = ", "),
           " are not SpatRaster objects")
    }

    rasters <- raster_list

    # Get names from list or create default names
    raster_names <- names(raster_list)
    if (is.null(raster_names) || any(raster_names == "")) {
      raster_names <- paste0("layer_", seq_along(raster_list))
    }

  } else {
    # From files
    stopifnot(dir.exists(dir_path))

    tif_pattern <- paste0(pattern, ".*\\.(tif|tiff)$")
    files <- list.files(
      dir_path,
      pattern = tif_pattern,
      full.names = TRUE,
      ignore.case = TRUE
    )

    if (length(files) == 0) {
      stop("No .tif/.tiff files found with pattern: ", pattern)
    }

    files <- sort(files)
    rasters <- lapply(files, terra::rast)
    raster_names <- sub("(?i)\\.(tif|tiff)$", "", basename(files), perl = TRUE)
  }

  # === 3. Define template grid from first raster ===
  template_base <- rasters[[1]]

  # === 4. Calculate union extent across all rasters ===
  all_extents <- lapply(rasters, terra::ext)
  union_extent <- Reduce(`+`, all_extents)

  # === 5. Create template covering union extent ===
  template <- terra::extend(template_base, union_extent)

  # === 6. Resample all rasters to common template ===
  resampled_layers <- lapply(seq_along(rasters), function(i) {
    r_resampled <- terra::resample(rasters[[i]], template, method = method)
    names(r_resampled) <- raster_names[i]
    r_resampled
  })

  # === 7. Combine into single multilayer SpatRaster ===
  # Use terra::rast() to properly combine layers
  result <- terra::rast(resampled_layers)

  return(result)
}
