#' Calculates Zonal or Total Area for Species Rasters
#'
#' @description
#' This function calculates the area of suitable habitat from a binary species raster (`r1_multi`)
#' and, optionally, the area of overlap with a second raster (`r2`). The second
#' raster `r2` can be continuous (requiring a threshold) or already binary.
#' The calculation can be performed for the entire raster extent ("total") or be
#' separated by categories defined in a polygon vector (`polys`).
#'
#' @param r1_multi A SpatRaster with multiple layers (species), with values of 1 (presence) and 0 (absence).
#' @param r2 A single-layer SpatRaster. Can be continuous or binary (0/1). Optional.
#' @param polys A SpatVector of polygons with categories. Optional.
#' @param threshold A numeric threshold to binarize `r2`. Only required if `r2` is continuous.
#' @param category_col The name of the column in `polys` with the categories. Required if `polys` is used.
#' @param cellSz A pre-calculated SpatRaster of cell sizes in km^2. If NULL (default), it will be
#'   calculated automatically. Providing this can increase efficiency.
#'
#' @return A standard R data.frame with the calculated areas in square kilometers.
#'
area.calc2 <- function(r1_multi, r2 = NULL, polys = NULL,
                       threshold, category_col = NULL, cellSz = NULL) {

  # Ensure necessary packages are loaded
  if (!requireNamespace("terra", quietly = TRUE)) stop("Package 'terra' is required.")
  if (!requireNamespace("dplyr", quietly = TRUE)) stop("Package 'dplyr' is required.")

  # --- Step 1: Prepare and Standardize Rasters ---

  # Prepare r2 if it exists
  if (!is.null(r2)) {
    # NEW: Check if r2 is binary or continuous
    r2_vals <- terra::minmax(r2)
    is_binary <- all(r2_vals %in% c(0, 1))

    if (is_binary) {
      message("Note: 'r2' detected as binary. 'threshold' argument will be ignored.")
      r2_binary <- r2
    } else {
      # r2 is continuous, threshold is mandatory
      if (missing(threshold)) {
        stop("Argument 'r2' is continuous. 'threshold' must be provided to binarize it.")
      }
      r2_binary <- r2 >= threshold
    }

    # Standardize grid alignment if necessary
    if (!isTRUE(all.equal(terra::res(r1_multi), terra::res(r2)))) {
      message("Note: Raster grids differ. Resampling r2 to match r1...")
      r2_binary <- terra::resample(r2_binary, r1_multi, method = "near") # 'near' for binary data
    }
  }

  # Prepare the cell size raster (cellSz)
  if (is.null(cellSz)) {
    cellSz <- terra::cellSize(r1_multi[[1]], unit = "km")
  }

  final_results_list <- list()

  # --- Step 2: Loop through each species layer ---
  for (i in 1:terra::nlyr(r1_multi)) {
    current_species_raster <- r1_multi[[i]]
    species_name <- names(current_species_raster)

    # SCENARIO A: Polygons ARE provided (Zonal Statistics)
    if (!is.null(polys)) {
      if (is.null(category_col)) stop("'category_col' must be specified when using 'polys'.")
      categories <- unique(polys[[category_col, drop = TRUE]])

      for (cat in categories) {
        current_poly <- polys[polys[[category_col]] == cat, ]

        # Mask the area raster once per polygon for efficiency
        area_masked <- terra::mask(cellSz, current_poly)

        # Calculate species area
        species_masked <- terra::mask(current_species_raster, current_poly)
        area_species_km2 <- terra::global(species_masked * area_masked,
                                          "sum", na.rm = TRUE)$sum

        result <- dplyr::tibble(species = species_name, category = cat,
                                analysis_type = "Species only", area_km2 = area_species_km2)

        # Calculate overlay area if r2 is provided
        if (!is.null(r2)) {
          overlay_raster <- species_masked + terra::mask(r2_binary, current_poly)

          area_overlay_km2 <- terra::global((overlay_raster == 2) * area_masked,
                                            "sum", na.rm = TRUE)$sum

          result <- dplyr::bind_rows(result, dplyr::tibble(species = species_name, category = cat,
                                                           analysis_type = "Overlay", area_km2 = area_overlay_km2))
        }
        final_results_list[[paste(species_name, cat)]] <- result
      }

      # SCENARIO B: Polygons ARE NOT provided (Total Area)
    } else {
      # Calculate total species area
      area_species_km2 <- terra::global(current_species_raster * cellSz,
                                        "sum", na.rm = TRUE)$sum

      result <- dplyr::tibble(species = species_name, category = "total",
                              analysis_type = "Species only", area_km2 = area_species_km2)

      # CORRECTED: Add overlay calculation for the total area scenario
      if (!is.null(r2)) {
        overlay_raster <- current_species_raster + r2_binary
        area_overlay_km2 <- terra::global((overlay_raster == 2) * cellSz,
                                          "sum", na.rm = TRUE)$sum

        result <- dplyr::bind_rows(result, dplyr::tibble(species = species_name, category = "total",
                                                         analysis_type = "Overlay", area_km2 = area_overlay_km2))
      }
      final_results_list[[species_name]] <- result
    }
  }

  # Combine all results and return a standard data.frame
  return(data.frame(dplyr::bind_rows(final_results_list)))
}
