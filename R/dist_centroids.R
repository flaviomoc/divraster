#' Function to calculate distance and direction of change between centroids
#'
#' @param ... N number of single or multilayer spatrasters
#' @param ref Spatraster of reference
#'
#' @return A data frame with distance and direction values
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' r1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' r2 <- terra::rast(system.file("extdata", "fut.tif",
#' package = "divraster"))
#' d.centroids(r1, r2)
#' }
d.centroids <- function(..., ref = 1) {
  rasters <- list(...)

  if (length(rasters) < 2) {
    stop("At least two SpatRaster objects are required.")
  }

  n_layers <- terra::nlyr(rasters[[1]])
  if (!all(sapply(rasters, terra::nlyr) == n_layers)) {
    stop("All SpatRaster objects must have the same number of layers.")
  }

  distances <- list()
  base_raster <- rasters[[ref]]

  for (i in seq_len(n_layers)) {
    base_layer <- base_raster[[i]]
    base_true <- base_layer == 1
    base_polygons <- terra::as.polygons(base_true)
    base_centroids <- terra::centroids(base_polygons)

    if (nrow(base_centroids) == 0) next # Skip if no centroids found
    base_coords <- terra::crds(base_centroids)[1, ]  # Use the first centroid

    dist_df <- data.frame(Layer = i)

    for (j in seq_along(rasters)) {
      if (j != ref) {
        current_layer <- rasters[[j]][[i]]
        current_true <- current_layer == 1
        current_polygons <- terra::as.polygons(current_true)
        current_centroids <- terra::centroids(current_polygons)

        if (nrow(current_centroids) == 0) {
          dist <- NA
          direction <- NA
        } else {
          current_coords <- terra::crds(current_centroids)[1, ]
          dist <- terra::distance(base_centroids, current_centroids, pairwise = FALSE, unit = "m")[1, 1]

          delta_x <- current_coords[1] - base_coords[1]
          delta_y <- current_coords[2] - base_coords[2]

          if (delta_x > 0 && delta_y > 0) {
            direction <- "Northeast"
          } else if (delta_x > 0 && delta_y < 0) {
            direction <- "Southeast"
          } else if (delta_x < 0 && delta_y > 0) {
            direction <- "Northwest"
          } else if (delta_x < 0 && delta_y < 0) {
            direction <- "Southwest"
          } else if (delta_x == 0 && delta_y > 0) {
            direction <- "North"
          } else if (delta_x == 0 && delta_y < 0) {
            direction <- "South"
          } else if (delta_x > 0 && delta_y == 0) {
            direction <- "East"
          } else if (delta_x < 0 && delta_y == 0) {
            direction <- "West"
          } else {
            direction <- "No movement"
          }
        }

        dist_df[[paste0("Distance_r", ref, "_r", j)]] <- dist
        dist_df[[paste0("Direction_r", ref, "_r", j)]] <- direction
      }
    }

    distances[[i]] <- dist_df
  }

  distances_df <- do.call(rbind, distances)
  return(distances_df)
}
