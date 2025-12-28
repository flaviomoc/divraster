#' Average pairwise distance between occurrences by species
#'
#' Compute the mean of all unique pairwise great-circle distances between
#' occurrence records for each species, using longitude/latitude coordinates
#' (EPSG:4326). Distances are computed with sf::st_distance().
#'
#' @param df A data.frame (or tibble) containing species names and coordinates.
#' @param species_col Character. Column name containing species names. Default "species".
#' @param lon_col Character. Column name containing longitudes (decimal degrees). Default "lon".
#' @param lat_col Character. Column name containing latitudes (decimal degrees). Default "lat".
#'
#' @details
#' For each species, the function:
#' - Filters out rows with missing species or coordinates
#' - Converts lon/lat to an sf point object with CRS = 4326
#' - Builds a full distance matrix within the species
#' - Extracts the upper triangle (unique pairs) and averages distances
#'
#' Species with fewer than 2 valid records return NA.
#'
#' @return A data.frame with columns:
#' - species: unique species names
#' - avg_distance_m: mean pairwise distance in meters
#'
#' @import sf
#' @importFrom dplyr all_of
#'
#' @examples
#' \dontrun{
#' library(dplyr)
#' library(sf)
#'
#' # Create example occurrence data for 3 species
#' occurrences <- tibble(
#'   species = c(
#'     rep("Species_A", 4),
#'     rep("Species_B", 5),
#'     rep("Species_C", 2)
#'   ),
#'   lon = c(
#'     # Species A: widespread across Brazil
#'     -43.2, -47.9, -38.5, -51.2,
#'     # Species B: clustered in southeast
#'     -43.9, -44.1, -43.7, -44.3, -43.8,
#'     # Species C: only 2 points
#'     -45.0, -46.0
#'   ),
#'   lat = c(
#'     # Species A
#'     -22.9, -15.8, -12.9, -30.0,
#'     # Species B
#'     -19.9, -20.1, -19.8, -20.3, -20.0,
#'     # Species C
#'     -23.5, -24.0
#'   )
#' )
#'
#' # Calculate average pairwise distances
#' result <- occ.avg.dist(occurrences)
#' result
#' }
#'
#' @export
occ.avg.dist <- function(df,
                         species_col = "species",
                         lon_col = "lon",
                         lat_col = "lat") {

  # === 1. Validate inputs ===
  required_cols <- c(species_col, lon_col, lat_col)
  missing_cols <- setdiff(required_cols, names(df))

  if (length(missing_cols) > 0) {
    stop("Missing required columns: ", paste(missing_cols, collapse = ", "))
  }

  # === 2. Enable geodesic distances ===
  sf::sf_use_s2(TRUE)

  # === 3. Clean data and convert to spatial points ===
  # Remove rows with missing values (use direct column access)
  df_clean <- df[
    !is.na(df[[species_col]]) &
      !is.na(df[[lon_col]]) &
      !is.na(df[[lat_col]]),
  ]

  # Convert to sf points (EPSG:4326 = WGS84 lon/lat)
  df_spatial <- sf::st_as_sf(
    df_clean,
    coords = c(lon_col, lat_col),
    remove = FALSE,
    crs = 4326
  )

  # === 4. Calculate average pairwise distance for each species ===
  result <- df_spatial |>
    dplyr::group_by(dplyr::across(dplyr::all_of(species_col))) |>
    dplyr::group_modify(function(group_data, group_key) {

      n_points <- nrow(group_data)

      # Need at least 2 points to calculate distance
      if (n_points < 2) {
        return(dplyr::tibble(avg_distance_m = NA_real_))
      }

      # Calculate all pairwise distances (returns matrix in meters)
      distance_matrix <- sf::st_distance(group_data)
      distance_matrix <- as.matrix(distance_matrix)

      # Extract upper triangle (unique pairs only, exclude diagonal)
      unique_distances <- distance_matrix[upper.tri(distance_matrix)]

      # Calculate mean distance
      mean_distance <- mean(as.numeric(unique_distances), na.rm = TRUE)

      dplyr::tibble(avg_distance_m = mean_distance)

    }) |>
    dplyr::ungroup() |>
    dplyr::rename(species = dplyr::all_of(species_col))

  return(data.frame(result))
}
