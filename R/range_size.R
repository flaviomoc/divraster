#' Calculate Area of SpatRaster and Overlapping Areas
#'
#' This function calculates the total area of a SpatRaster object and the overlapping areas
#' with up to two additional SpatRaster objects. The results can be saved to a CSV file if a
#' filename is provided.
#'
#' @param x A SpatRaster object for which the area will be calculated.
#' @param y An optional SpatRaster object with a single layer to calculate the overlapping area with `x`.
#' @param z An optional SpatRaster object with a single layer to calculate the overlapping area with `x` and `y`.
#' @param filename A character string specifying the name of the CSV file to save the results.
#'                  If not provided, the results will not be saved to a file.
#' @param unit A character string specifying the unit of measurement for area calculations.
#'             Default is "km".
#' @param cellsize An optional numeric value specifying the cell size for area calculations.
#'                  If not provided, the function will use the cell size of the raster.
#' @param ... Additional arguments to be passed to other methods.
#'
#' @return A data frame containing the area of each layer in the SpatRaster object,
#'         along with the overlapping areas if `y` or `z` are provided.
#' @export
#'
#' @examples
#' library(terra)
#'
#' bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
#'
#' area.calc(bin1, bin1[[1]], bin1[[2]])
area.calc <- function(x, y = NULL, z = NULL, filename = "", unit = "km", cellsize = NULL, ...) {
  # Check if input is a SpatRaster
  if (!inherits(x, "SpatRaster")) {
    stop("Input x must be a SpatRaster object.")
  }

  # If y is provided, check if it is a SpatRaster and has only one layer
  if (!is.null(y)) {
    if (!inherits(y, "SpatRaster")) {
      stop("Input y must be a SpatRaster object.")
    }
    if (nlyr(y) != 1) {
      stop("Input y must be a SpatRaster with a single layer.")
    }
  }

  # If z is provided, check if it is a SpatRaster and has only one layer
  if (!is.null(z)) {
    if (!inherits(z, "SpatRaster")) {
      stop("Input z must be a SpatRaster object.")
    }
    if (nlyr(z) != 1) {
      stop("Input z must be a SpatRaster with a single layer.")
    }
  }

  # If cellsize is not provided, use the cell size of the raster
  if (is.null(cellsize)) {
    cellsize <- terra::cellSize(terra::rast(x[[1]]), unit = unit)
  }

  # Calculate the area for each layer in the SpatRaster object
  area_values <- terra::global(x * cellsize, fun = "sum", na.rm = TRUE)[, 1]

  # Initialize overlap_area_values
  overlap_area_values_y <- rep(NA, nlyr(x))  # Default to NA if y is not provided
  overlap_area_values_z <- rep(NA, nlyr(x))  # Default to NA if z is not provided
  overlap_area_values_all <- rep(NA, nlyr(x))  # Default to NA if y or z is not provided

  # If y is provided, calculate the overlapping area with y
  if (!is.null(y)) {
    combined_raster_y <- x + y
    overlap_area_values_y <- terra::global((combined_raster_y == 2) * cellsize, fun = "sum", na.rm = TRUE)[, 1]
  }

  # If z is provided, calculate the overlapping area with z
  if (!is.null(z)) {
    combined_raster_z <- x + z
    overlap_area_values_z <- terra::global((combined_raster_z == 2) * cellsize, fun = "sum", na.rm = TRUE)[, 1]

    # Calculate the overlapping area where all three overlap
    combined_raster_all <- x + y + z
    overlap_area_values_all <- terra::global((combined_raster_all == 3) * cellsize, fun = "sum", na.rm = TRUE)[, 1]
  }

  # Create a data frame with layer names and corresponding area values
  area_df <- data.frame(Layer = names(x), Area = area_values)

  # Add columns for overlap areas if y or z are provided
  if (!is.null(y)) {
    area_df$Overlap_Area_Y <- overlap_area_values_y
  }

  if (!is.null(z)) {
    area_df$Overlap_Area_Z <- overlap_area_values_z
    area_df$Overlap_Area_All <- overlap_area_values_all
  }

  # Save to CSV if filename is provided
  if (filename != "") {
    # Ensure the filename ends with .csv
    if (!grepl("\\.csv$", filename)) {
      filename <- paste0(filename, ".csv")
    }
    utils::write.csv(area_df, file = filename, row.names = FALSE)
  }

  return(area_df)
}
