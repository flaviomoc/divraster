#' Combine GeoTIFF rasters into a multilayer SpatRaster
#'
#' Reads all GeoTIFF files in a directory that match a given pattern,
#' computes the union of their extents, resamples them to a common grid,
#' and returns a single multilayer \code{SpatRaster}.
#'
#' The first file found (after sorting) defines the target resolution,
#' origin and CRS; the union of all input extents defines the spatial
#' coverage. Areas where a raster has no data are filled with \code{NA}.
#'
#' @param dir_path Character. Directory containing the input GeoTIFF files.
#' @param pattern Character. Pattern that file names must contain before
#'   the extension (used inside \code{list.files(pattern = ...)}).
#' @param method Character. Resampling method passed to
#'   \code{terra::resample()}, e.g. \code{"bilinear"} (default) or
#'   \code{"near"} for categorical data.
#'
#' @return A \code{SpatRaster} with one layer per input file. Layers are
#'   named from the file basenames without the \code{.tif} / \code{.tiff}
#'   extension.
#'
#' @section Extent handling:
#' The function always uses the union of the input extents. The grid
#' (resolution, origin, CRS) comes from the first file, and that grid is
#' extended to cover the union of all extents before resampling.
#'
#'
#' @export
combine.rasters <- function(dir_path, pattern, method = "bilinear") {

  stopifnot(dir.exists(dir_path))

  # Find .tif and .tiff files (case-insensitive) whose names contain `pattern`
  files <- list.files(
    dir_path,
    pattern     = paste0(pattern, ".*\\.(tif|tiff)$"),
    full.names  = TRUE,
    ignore.case = TRUE
  )
  if (length(files) == 0) {
    stop("No .tif/.tiff files found with pattern: ", pattern)
  }
  files <- sort(files)

  # Base grid comes from the first raster
  ref0 <- terra::rast(files[1])

  # Union extent across all rasters
  all_ext <- Reduce(`+`, lapply(files, function(f) terra::ext(terra::rast(f))))

  # Extend the reference grid to cover the union extent (new cells become NA)
  template <- terra::extend(ref0, all_ext)

  # Resample every raster to the template grid and combine into a multilayer object
  out <- do.call(
    c,
    lapply(files, function(f) terra::resample(terra::rast(f), template, method = method))
  )

  # Name layers after files
  names(out) <- sub("(?i)\\.(tif|tiff)$", "", basename(files), perl = TRUE)

  out
}
