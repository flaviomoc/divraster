#' Function to calculate distances between centroids of multiple SpatRasters
#'
#' @param ... N number of single or multilayer spatrasters
#' @param ref Spatraster of reference
#'
#' @return A data frame with distance values
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' r1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' r2 <- terra::rast(system.file("extdata", "fut.tif",
#' package = "divraster"))
#' dist.centroids(r1, r2)
#' }
dist.centroids <- function(..., ref = 1) {
  # Collect all SpatRasters into a list
  rasters <- list(...)

  # Ensure there are at least two SpatRasters
  if (length(rasters) < 2) {
    stop("At least two SpatRaster objects are required.")
  }

  # Ensure all SpatRasters have the same number of layers
  n_layers <- terra::nlyr(rasters[[1]])
  if (!all(sapply(rasters, terra::nlyr) == n_layers)) {
    stop("All SpatRaster objects must have the same number of layers.")
  }

  # Initialize a list to store the distances for each layer
  distances <- list()

  # Get the base raster for comparison
  base_raster <- rasters[[ref]]

  # Loop over each layer
  for (i in seq_len(n_layers)) {
    # Extract the i-th layer from the base raster
    base_layer <- base_raster[[i]]

    # Convert base raster layer to binary and then to polygons
    base_true <- base_layer == 1
    base_polygons <- terra::as.polygons(base_true)
    base_centroids <- terra::centroids(base_polygons)

    # Initialize a data frame to store distances for this layer
    dist_df <- data.frame(Layer = i)

    # Loop over the other rasters and calculate distances
    for (j in seq_along(rasters)) {
      if (j != ref) {
        # Extract the i-th layer from the current raster
        current_layer <- rasters[[j]][[i]]

        # Convert the current raster layer to binary and then to polygons
        current_true <- current_layer == 1
        current_polygons <- terra::as.polygons(current_true)
        current_centroids <- terra::centroids(current_polygons)

        # Calculate the distance between centroids of base and current raster layers
        dist <- terra::distance(base_centroids, current_centroids, pairwise = FALSE, unit = "m")[2, 2]

        # Add the distance to the data frame
        dist_df[[paste0("Distance_r", ref, "_r", j)]] <- dist
      }
    }

    # Store the distance data frame in the list
    distances[[i]] <- dist_df
  }

  # Combine the list into a single data.frame
  distances_df <- do.call(rbind, distances)

  return(distances_df)
}
