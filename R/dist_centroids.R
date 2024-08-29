#' Function to calculate distance and direction of change between centroids
#'
#' @param raster1 A binary spatraster.
#' @param raster2 A binary spatraster.
#'
#' @return A data frame with distance and direction.
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' r1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' r2 <- terra::rast(system.file("extdata", "fut.tif",
#' package = "divraster"))
#' dd.calc(r1, r2)
#' }
dd.calc <- function(raster1, raster2) {
  # Check if the SpatRasters have the same number of layers
  if (terra::nlyr(raster1) != terra::nlyr(raster2)) {
    stop("The SpatRasters must have the same number of layers.")
  }

  # Initialize a list to store the results
  results <- list()

  # Iterate over the layers
  for (i in 1:terra::nlyr(raster1)) {
    # Select the current layer
    layer1 <- raster1[[i]]
    layer2 <- raster2[[i]]

    # Convert values equal to 1 into SpatVector polygons
    terra::values(layer1)[terra::values(layer1) != 1] <- NA
    terra::values(layer2)[terra::values(layer2) != 1] <- NA

    # Calculate the centroids of the polygons
    cent1 <- terra::centroids(terra::as.polygons(layer1))
    cent2 <- terra::centroids(terra::as.polygons(layer2))

    # Handle the case where no centroids are found
    if (nrow(terra::crds(cent1)) == 0 || nrow(terra::crds(cent2)) == 0) {
      warning(paste("No centroids found in layer", i, "- skipping this layer."))
      next
    }

    # Get the coordinates of the centroids
    coords1 <- terra::crds(cent1)
    coords2 <- terra::crds(cent2)

    # Calculate the distance in meters (assuming the projection is appropriate)
    dist_meters <- terra::distance(coords1, coords2, lonlat = TRUE)[1, 1]

    # Function to determine the relative direction
    determine_direction <- function(coord1, coord2) {
      dx <- coord2[1] - coord1[1]
      dy <- coord2[2] - coord1[2]

      if (dx == 0 && dy == 0) {
        return("No change")
      } else if (dx > 0 && dy > 0) {
        return("Northeast")
      } else if (dx > 0 && dy < 0) {
        return("Southeast")
      } else if (dx < 0 && dy > 0) {
        return("Northwest")
      } else if (dx < 0 && dy < 0) {
        return("Southwest")
      } else if (dx > 0 && dy == 0) {
        return("East")
      } else if (dx < 0 && dy == 0) {
        return("West")
      } else if (dx == 0 && dy > 0) {
        return("North")
      } else {
        return("South")
      }
    }

    # Determine the relative direction
    direction <- determine_direction(coords1, coords2)

    # Create a data frame with the information for the current layer
    result <- data.frame(
      Layer = names(raster1)[i],
      Distance_meters = dist_meters,
      Direction = direction
    )

    # Add the result to the list
    results[[i]] <- result
  }

  # Combine all results into a single data frame
  results_df <- do.call(rbind, results)

  return(results_df)
}
