#' Area calculation
#'
#' @param x A SpatRaster with presence-absence data (0 or 1) for a
#' given species.
#' @param unit Character. Default is "km", "m" and "ha" also
#' available.
#' @param ... Additional arguments to be passed passed down from
#' a calling function.
#'
#' @return A vector with an area in the chosen unit.
range.rast <- function(x, unit = "km", ...) {
  # Create a temporary file for saving intermediate raster calculations
  temp <- tempfile(fileext = ".tif")

  # Calculate the area of each cell in the specified unit (e.g., square kilometers)
  area <- terra::cellSize(terra::rast(x[[1]]), filename = temp, unit = unit)

  # Calculate the range size for each layer in the SpatRaster object
  rs <- sapply(1:terra::nlyr(x), function(i, area, x) {
    az <- terra::zonal(area, x[[i]], sum)
    az <- az[az[, 1] == 1, 2]
    if (length(az) == 0) 0 else az
  }, area = area, x = x)

  # Assign names to the resulting range sizes
  names(rs) <- names(x)

  # Remove the temporary file
  unlink(temp)

  return(rs)
}

#' Area calculation
#'
#' @param x A list containing multiple SpatRaster with
#' presence-absence data (0 or 1) for a set of species.
#' @param unit Character. Default is "km", but "m" and "ha"
#' are also available.
#' @param r2 A SpatRaster with the same extent as "x".
#' @param r3 A SpatRaster with the same extent as "x".
#' @param filename Character. Save results if a name is provided.
#'
#' @return A data.frame with area values in the chosen unit.
range.list <- function(x, unit = "km", r2 = NULL, r3 = NULL,
                       filename = "") {
  # Initialize empty objects to store results
  total <- numeric(terra::nlyr(x[[1]])) # total suitable area
  res <- data.frame() # to store area values

  # Initialize empty objects to store overlay areas if needed
  if (!is.null(r2)) {
    area2 <- numeric(terra::nlyr(x[[1]]))
  }

  if (!is.null(r3)) {
    area3 <- numeric(terra::nlyr(x[[1]]))
  }

  if (!is.null(r2) && !is.null(r3)) {
    area.all <- numeric(terra::nlyr(x[[1]]))
  }

  # Loop through scenarios
  for (j in seq_along(x)) {
    # Loop through species
    for (i in 1:terra::nlyr(x[[j]])) {
      # Calculate total suitable area for each species
      total[i] <- range.rast(x[[j]][[i]], unit = unit)

      # Calculate overlay area with r2 if provided
      if (!is.null(r2)) {
        overlay2 <- x[[j]][[i]] + r2 == 2
        area2[i] <- range.rast(overlay2, unit = unit)
      }

      # Calculate overlay area with r3 if provided
      if (!is.null(r3)) {
        overlay3 <- x[[j]][[i]] + r3 == 2
        area3[i] <- range.rast(overlay3, unit = unit)
      }

      # Calculate overlay area with both r2 and r3 if provided
      if (!is.null(r2) && !is.null(r3)) {
        overlay.all <- x[[j]][[i]] + r2 + r3 == 3
        area.all[i] <- range.rast(overlay.all, unit = unit)
      }
    }

    # Create a data frame to store the results
    result <- data.frame(sp = names(x[[j]]),
                         scenario = names(x)[j],
                         total.area = total)

    # Add overlay areas to the result data frame if provided
    if (!is.null(r2)) {
      result$area2 <- area2
    }

    if (!is.null(r3)) {
      result$area3 <- area3
    }

    if (!is.null(r2) && !is.null(r3)) {
      result$area.all <- area.all
    }

    # Bind the result data frame to the final result
    res <- rbind(res, result)
  }

  if (filename != "") {
    utils::write.csv(res, file = filename)
  }

  return(res)
}
