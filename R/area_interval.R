#' Calculate Area by Interval Classes for SpatRasters
#'
#' This function takes a SpatRaster or list of SpatRaster objects, classifies them into
#' intervals based on user-defined or automatically calculated min/max values, and calculates
#' the area for each class across all rasters.
#'
#' @param raster_list A SpatRaster object or a list of SpatRaster objects to analyze
#' @param min_value Numeric. Minimum value for the interval sequence. If NULL (default),
#'   automatically calculated from all input rasters
#' @param max_value Numeric. Maximum value for the interval sequence. If NULL (default),
#'   automatically calculated from all input rasters
#' @param interval Numeric. Interval size for the sequence (e.g., 0.1 for breaks every 0.1 units)
#' @param round Logical. If TRUE, rounds min_value down and max_value up to the nearest interval.
#'   For example, with interval=0.1: min 0.12 becomes 0.1, max 0.98 becomes 1.0. Default TRUE
#' @param include_lowest Logical. Should the lowest value be included in the classification? Default TRUE
#' @param right Logical. Should intervals be closed on the right (and open on the left)? Default TRUE
#' @param filename Character. Optional filename to save the output dataframe as CSV.
#'   If NULL (default), the dataframe is not saved
#' @param verbose Logical. Print progress messages? Default TRUE
#' @param ... Additional arguments passed to the classify function
#'
#' @return A data.frame containing area calculations for each interval class and scenario
#'
#' @import terra
#' @import dplyr
#' @importFrom stats setNames
#' @importFrom utils write.csv
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Single raster - automatic min/max detection with rounding
#' r1 <- rast(ncol=10, nrow=10, vals=runif(100, 0.12, 0.98))
#' result <- calculate_interval_areas(r1, interval = 0.1, round = TRUE)
#' # min 0.12 becomes 0.1, max 0.98 becomes 1.0
#'
#' # Multiple rasters without rounding (use exact detected values)
#' r2 <- rast(ncol=10, nrow=10, vals=runif(100, 0, 1))
#' raster_list <- list(scenario1 = r1, scenario2 = r2)
#' result <- calculate_interval_areas(raster_list, interval = 0.1, round = FALSE)
#'
#' # Specify custom min/max values (rounding not applied to manual values)
#' result <- calculate_interval_areas(
#'   raster_list = raster_list,
#'   min_value = 0.6,
#'   max_value = 0.8,
#'   interval = 0.1
#' )
#'
#' # Save results to file
#' result <- calculate_interval_areas(
#'   raster_list = raster_list,
#'   interval = 0.1,
#'   filename = "area_results.csv"
#' )
#' }
area.interval <- function(raster_list,
                          min_value = NULL,
                          max_value = NULL,
                          interval,
                          round = TRUE,
                          include_lowest = TRUE,
                          right = TRUE,
                          filename = NULL,
                          verbose = TRUE,
                          ...) {

  # === 1. Convert single raster to list ===
  if (inherits(raster_list, "SpatRaster")) {
    if (verbose) message("Single SpatRaster detected. Converting to list.")
    raster_name <- names(raster_list)[1]
    if (is.null(raster_name) || raster_name == "") raster_name <- "raster_1"
    raster_list <- setNames(list(raster_list), raster_name)
  }

  # === 2. Validate inputs ===
  if (!is.list(raster_list) || length(raster_list) == 0) {
    stop("raster_list must be a non-empty SpatRaster or list of SpatRasters")
  }

  if (!is.numeric(interval) || interval <= 0) {
    stop("interval must be a positive numeric value")
  }

  # Filter out non-SpatRaster objects
  valid_idx <- sapply(raster_list, inherits, "SpatRaster")
  if (!all(valid_idx)) {
    warning(paste0("Removing non-SpatRaster elements: ", paste(which(!valid_idx), collapse = ", ")))
    raster_list <- raster_list[valid_idx]
  }

  if (length(raster_list) == 0) stop("No valid SpatRaster objects found")

  # === 3. Auto-detect min/max if needed ===
  auto_min <- is.null(min_value)
  auto_max <- is.null(max_value)

  if (auto_min || auto_max) {
    if (verbose) message("Calculating min/max values from ", length(raster_list), " raster(s)...")

    minmax_vals <- lapply(seq_along(raster_list), function(i) {
      if (verbose && length(raster_list) > 1) {
        message("  Processing raster ", i, "/", length(raster_list))
      }
      terra::minmax(raster_list[[i]])
    })

    if (auto_min) {
      min_value <- min(sapply(minmax_vals, function(x) x[1, 1]))
      if (verbose) message("Detected minimum value: ", round(min_value, 6))
    }

    if (auto_max) {
      max_value <- max(sapply(minmax_vals, function(x) x[2, 1]))
      if (verbose) message("Detected maximum value: ", round(max_value, 6))
    }
  }

  # === 4. Apply rounding to auto-detected values ===
  if (round) {
    if (auto_min) {
      original_min <- min_value
      min_value <- floor(min_value / interval) * interval
      if (verbose && min_value != original_min) {
        message("Rounded minimum: ", round(original_min, 6), " -> ", round(min_value, 6))
      }
    }

    if (auto_max) {
      original_max <- max_value
      max_value <- ceiling(max_value / interval) * interval
      if (verbose && max_value != original_max) {
        message("Rounded maximum: ", round(original_max, 6), " -> ", round(max_value, 6))
      }
    }
  }

  # === 5. Final validation ===
  if (min_value >= max_value) {
    stop("min_value must be less than max_value")
  }

  if (interval > (max_value - min_value)) {
    stop("interval cannot be larger than the range (max_value - min_value)")
  }

  # === 6. Create breaks and process rasters ===
  cuts <- seq(min_value, max_value, by = interval)

  if (verbose) {
    message("Using ", length(cuts), " breaks from ", round(min_value, 6),
            " to ", round(max_value, 6), " (interval: ", interval, ")")
  }

  area_all <- lapply(seq_along(raster_list), function(i) {
    r_cat <- terra::classify(
      raster_list[[i]],
      rcl = cuts,
      include.lowest = include_lowest,
      right = right,
      ...
    )

    a <- area.calc.flex(r_cat)

    # Add scenario name
    scen_name <- names(raster_list)[i]
    if (is.null(scen_name) || scen_name == "") {
      scen_name <- names(r_cat)[1]
      if (is.null(scen_name) || scen_name == "") {
        scen_name <- paste0("raster_", i)
      }
    }
    a$scenario <- scen_name

    a
  })

  # === 7. Combine results ===
  area_tbl <- dplyr::bind_rows(area_all)

  # === 8. Save to file if requested ===
  if (!is.null(filename) && nzchar(filename)) {
    tryCatch({
      write.csv(area_tbl, file = filename, row.names = FALSE)
      if (verbose) message("Results saved to: ", filename)
    }, error = function(e) {
      warning("Could not save file: ", e$message)
    })
  }

  return(area_tbl)
}
