#' @title Calculate SpatRaster Layer Areas and Overlap Areas
#'
#' @description
#' Calculates the total area for each layer (e.g., species) within a `SpatRaster` object.
#' Optionally, it can also compute the overlapping areas between the primary `SpatRaster` (`x`)
#' and one or two additional single-layer `SpatRaster` objects (`y` and `z`).
#' Results are returned as a `data.frame` and can optionally be saved to a CSV file.
#'
#' @param x A `SpatRaster` object for which the area of each layer will be calculated.
#'          This `SpatRaster` can have one or multiple layers.
#' @param y An optional `SpatRaster` object with a **single layer**. If provided,
#'          the overlapping area between each layer in `x` and this `y` raster will be calculated.
#'          It should have the same extent and resolution as `x`.
#' @param z An optional `SpatRaster` object with a **single layer**. If provided,
#'          the overlapping area between each layer in `x` and this `z` raster,
#'          as well as the three-way overlap (`x`, `y`, and `z`), will be calculated.
#'          Requires `y` to also be provided. It should have the same extent and resolution as `x`.
#' @param filename Character string. If provided (e.g., "results.csv"), the resulting
#'                 data frame will be saved to a CSV file with this name. If not provided,
#'                 results are returned only to the R session.
#' @param unit Character string specifying the unit of measurement for area calculations.
#'             Defaults to "km" (kilometers). Other options include "ha" (hectares), "m" (meters), etc.
#' @param cellsize Numeric. An optional value specifying the cell size (area of a single cell)
#'                 to be used for calculations. If `NULL` (default), the function will
#'                 automatically determine the cell size from the input raster `x`.
#'
#' @return A `data.frame` with the following columns:
#'         \itemize{
#'           \item \strong{Layer}: Name of each layer from the input `SpatRaster x`.
#'           \item \strong{Area}: The calculated area for each layer in `x` (e.g., total species range area).
#'           \item \strong{Overlap_Area_Y} (optional): If `y` is provided, the area where
#'                 the `x` layer and `y` raster both have a value of 1 (overlap).
#'           \item \strong{Overlap_Area_Z} (optional): If `z` is provided, the area where
#'                 the `x` layer and `z` raster both have a value of 1 (overlap).
#'           \item \strong{Overlap_Area_All} (optional): If both `y` and `z` are provided,
#'                 the area where the `x` layer, `y` raster, and `z` raster all have a value of 1 (triple overlap).
#'         }
#'         Areas are reported in the specified `unit`.
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#'
#' # Load example rasters for demonstration
#' # Ensure these files are present in your package's inst/extdata folder
#' bin_rast <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
#'
#' # Example 1: Calculate area for 'bin_rast' only
#' area_only <- area.calc(bin_rast)
#' area_only
#' }
area.calc <- function(x, y = NULL, z = NULL, filename = "", unit = "km", cellsize = NULL) {
  # Input validation
  if (!inherits(x, "SpatRaster")) {
    stop("Input 'x' must be a SpatRaster object.")
  }

  # Helper function for checking single-layer SpatRaster
  check_single_layer_rast <- function(rast_obj, param_name) {
    if (!inherits(rast_obj, "SpatRaster")) {
      stop(paste0("Input '", param_name, "' must be a SpatRaster object."))
    }
    if (terra::nlyr(rast_obj) != 1) {
      stop(paste0("Input '", param_name, "' must be a SpatRaster with a single layer."))
    }
    # Check for consistent geometry with 'x'
    if (!terra::compareGeom(x, rast_obj, res = TRUE, ext = TRUE, rowcol = TRUE)) {
      stop(paste0("Input '", param_name, "' must have the same extent, resolution, and dimensions as 'x'."))
    }
  }

  if (!is.null(y)) {
    check_single_layer_rast(y, "y")
  }
  if (!is.null(z)) {
    # 'z' requires 'y' to be present for triple overlap calculation to make sense
    if (is.null(y)) {
      stop("Input 'z' cannot be provided without 'y'.")
    }
    check_single_layer_rast(z, "z")
  }

  # Determine cell size if not provided
  if (is.null(cellsize)) {
    # terra::cellSize calculates cell area for projected rasters.
    # It returns a SpatRaster, so we take the first value (assuming uniform cell size).
    cell_area_rast <- terra::cellSize(x, unit = unit)
    cellsize_value <- terra::values(cell_area_rast[[1]])[1] # Take the area of the first cell
  } else {
    cellsize_value <- cellsize # Use provided cellsize directly
  }

  # Calculate the area for each layer in 'x'
  # We use (x > 0) to ensure we sum areas only where species are present (value 1)
  # in case x contains values other than 0 or 1, although documentation states 0 or 1.
  area_values <- terra::global((x > 0) * cellsize_value, fun = "sum", na.rm = TRUE)[, 1]

  # Initialize overlap area vectors
  overlap_area_values_y <- rep(NA, terra::nlyr(x))
  overlap_area_values_z <- rep(NA, terra::nlyr(x))
  overlap_area_values_all <- rep(NA, terra::nlyr(x))

  # If 'y' is provided, calculate the overlapping area with 'y'
  if (!is.null(y)) {
    # Sum only where x_layer is 1 AND y is 1 (overlap)
    # terra automatically handles layer-by-layer multiplication if x has multiple layers
    # and y has a single layer (broadcasts y to all layers of x).
    overlap_area_values_y <- terra::global(((x == 1) & (y == 1)) * cellsize_value,
                                           fun = "sum", na.rm = TRUE)[, 1]
  }

  # If 'z' is provided, calculate the overlapping area with 'z'
  if (!is.null(z)) {
    # Sum only where x_layer is 1 AND z is 1 (overlap)
    overlap_area_values_z <- terra::global(((x == 1) & (z == 1)) * cellsize_value,
                                           fun = "sum", na.rm = TRUE)[, 1]

    # Calculate the overlapping area where all three overlap (x, y, and z)
    overlap_area_values_all <- terra::global(((x == 1) & (y == 1) & (z == 1)) * cellsize_value,
                                             fun = "sum", na.rm = TRUE)[, 1]
  }

  # Create a data frame with layer names and corresponding area values
  area_df <- data.frame(Layer = names(x), Area = area_values)

  # Add columns for overlap areas if y or z are provided
  if (!is.null(y)) {
    area_df$Overlap_Area_Y <- overlap_area_values_y
  }
  if (!is.null(z)) { # This condition implicitly depends on y being non-null as per validation
    area_df$Overlap_Area_Z <- overlap_area_values_z
    area_df$Overlap_Area_All <- overlap_area_values_all
  }

  # Save to CSV if filename is provided
  if (filename != "") {
    if (!grepl("\\.csv$", tolower(filename))) { # Use tolower for case-insensitivity
      filename <- paste0(filename, ".csv")
    }
    utils::write.csv(area_df, file = filename, row.names = FALSE)
  }

  return(area_df)
}
