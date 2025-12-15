#' Average pairwise distance between occurrences by species
#'
#' Compute the mean of all unique pairwise great-circle distances between
#' occurrence records for each species, using longitude/latitude coordinates
#' (EPSG:4326). Distances are computed with [sf::st_distance()].
#'
#' @param df A data.frame (or tibble) containing species names and coordinates.
#' @param species_col Character scalar. Column name containing species names.
#' @param lon_col Character scalar. Column name containing longitudes (decimal degrees).
#' @param lat_col Character scalar. Column name containing latitudes (decimal degrees).
#'
#' @details
#' For each species, the function:
#' \itemize{
#' \item Filters out rows with missing species / coordinates.
#' \item Converts lon/lat to an `sf` point object with CRS = 4326.
#' \item Builds a full distance matrix within the species.
#' \item Extracts the upper triangle (unique pairs) and averages distances.
#' }
#' Species with < 2 valid records return `NA`.
#'
#' @return A tibble with columns:
#' \itemize{
#' \item `species`: unique species names.
#' \item `avg_distance_m`: mean pairwise distance (meters).
#' }
#'
#' @export
#' @importFrom rlang .data
#' @importFrom dplyr all_of
occ.avg.dist <- function(df,
                         species_col = "species",
                         lon_col = "lon",
                         lat_col = "lat") {

  # ---- Basic checks ----------------------------------------------------------
  # Fail early if required columns are missing.
  stopifnot(all(c(species_col, lon_col, lat_col) %in% names(df)))

  # ---- Use spherical distance for lon/lat -----------------------------------
  # s2 = TRUE ensures geodesic distances when data are in EPSG:4326.
  sf::sf_use_s2(TRUE)

  # ---- Clean + convert to sf -------------------------------------------------
  # Remove rows with missing values in key columns, then create POINT geometries.
  df_sf <- df |>
    dplyr::filter(
      !is.na(rlang::.data[[species_col]]),
      !is.na(rlang::.data[[lon_col]]),
      !is.na(rlang::.data[[lat_col]])
    ) |>
    sf::st_as_sf(coords = c(lon_col, lat_col), remove = FALSE, crs = 4326)

  # ---- Compute mean pairwise distances by species ----------------------------
  # group_modify() applies a function to each species group.
  out <- df_sf |>
    dplyr::group_by(rlang::.data[[species_col]]) |>
    dplyr::group_modify(function(.x, .y) {

      n <- nrow(.x)

      # If fewer than 2 points, there are no pairs to compute.
      if (n < 2) return(dplyr::tibble(avg_distance_m = NA_real_))

      # Full n x n distance matrix within the species (units in meters).
      d_mat <- as.matrix(sf::st_distance(.x))

      # Keep only unique pairs (upper triangle) and average them.
      vals <- as.numeric(d_mat[upper.tri(d_mat)])
      dplyr::tibble(avg_distance_m = mean(vals, na.rm = TRUE))
    }) |>
    dplyr::ungroup() |>
    # Standardize the grouping column name in the output.
    dplyr::rename(species = dplyr::all_of(species_col))

  out
}
