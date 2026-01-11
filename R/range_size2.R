#' Flexible Area Calculation for Raster
#'
#' This function calculates the area of integer categories in a primary raster (r1).
#' It can optionally compute an overlay area with a second layer (r2) and/or
#' perform calculations within distinct zones defined by a polygon SpatVector.
#'
#' @param r1 The primary SpatRaster with integer categories.
#' @param r2_raster An optional SpatRaster for overlay analysis.
#' @param r2_vector An optional SpatVector for overlay analysis.
#' @param threshold A numeric value required to binarize 'r2_raster' if it's continuous.
#' @param zonal_polys An optional SpatVector for zonal analysis.
#' @param id_col A string specifying the column in 'zonal_polys'.
#' @param omit_zero A logical value. If TRUE (default), results for category = 0 are removed.
#' @param unit A string specifying the area unit ("km", "m", or "ha").
#'
#' @return A data frame with the area for each category.
#'
#' @examples
#' \donttest{
#' library(terra)
#'
#' # 1) Primary raster (integer categories)
#' land_cover <- rast(ncol = 30, nrow = 30,
#'                    xmin = -50, xmax = -49,
#'                    ymin = -15, ymax = -14)
#' values(land_cover) <- sample(1:3, ncell(land_cover), replace = TRUE)
#' crs(land_cover) <- "+proj=longlat +datum=WGS84 +no_defs"
#'
#' # Basic: total area by category
#' area.calc.flex(land_cover, unit = "km")
#'
#' # 2) Zonal polygons (two regions)
#' region1 <- vect("POLYGON ((-50 -15, -49.5 -15, -49.5 -14, -50 -14, -50 -15))")
#' region2 <- vect("POLYGON ((-49.5 -15, -49 -15, -49 -14, -49.5 -14, -49.5 -15))")
#' regions <- rbind(region1, region2)
#' crs(regions) <- crs(land_cover)
#' regions$region_id <- c("A", "B")
#'
#' area.calc.flex(
#'   land_cover,
#'   zonal_polys = regions,
#'   id_col = "region_id",
#'   unit = "km"
#' )
#'
#' # 3) Overlay raster (binary mask)
#' protected <- rast(land_cover)
#' values(protected) <- sample(0:1, ncell(protected), replace = TRUE)
#'
#' area.calc.flex(
#'   land_cover,
#'   r2_raster = protected,
#'   unit = "km"
#' )
#' }
#' @export
area.calc.flex <- function(r1, r2_raster = NULL, r2_vector = NULL, threshold = NULL,
                           zonal_polys = NULL, id_col = NULL,
                           omit_zero = TRUE, unit = "km") {

  # --- 1. Input Validation and Setup ---
  if (!requireNamespace("terra", quietly = TRUE)) stop("Package 'terra' is required.")
  if (!is.null(zonal_polys) && is.null(id_col)) stop("'id_col' is required when 'zonal_polys' is provided.")
  if (!is.null(r2_raster) && !is.null(r2_vector)) stop("Only one of 'r2_raster' or 'r2_vector' can be provided.")

  unit <- tolower(unit)
  if (!unit %in% c("m", "km", "ha")) stop("Argument 'unit' must be one of 'm', 'km', or 'ha'.")
  area_col_name <- paste0("area_", unit)

  # --- 2. Prepare Overlay Raster ---
  overlay_r <- NULL
  if (!is.null(r2_raster) || !is.null(r2_vector)) {

    if (!is.null(r2_raster)) {
      if (all(terra::minmax(r2_raster) %in% c(0, 1))) {
        overlay_r <- r2_raster
      } else {
        if (is.null(threshold)) stop("'threshold' is required for the continuous 'r2_raster'.")
        overlay_r <- r2_raster >= threshold
      }

      if (!terra::compareGeom(r1, overlay_r, stopOnError = FALSE, messages = FALSE)) {
        overlay_r <- terra::project(overlay_r, r1, method = "near")
      }
    } else {
      overlay_r <- terra::rasterize(r2_vector, r1, field = 1)
    }
  }

  # --- 3. Main Calculation Logic ---
  cell_area <- terra::cellSize(r1[[1]], unit = unit)
  final_results_list <- list()

  for (i in 1:terra::nlyr(r1)) {
    current_layer <- r1[[i]]
    layer_name <- names(current_layer)

    if (!is.null(zonal_polys)) {
      for (j in 1:nrow(zonal_polys)) {
        current_poly <- zonal_polys[j, ]
        poly_id <- current_poly[[id_col, drop = TRUE]]

        layer_masked <- terra::mask(current_layer, current_poly)
        area_masked  <- terra::mask(cell_area, current_poly)

        simple_results <- terra::zonal(area_masked, layer_masked, fun = "sum", na.rm = TRUE)
        if (nrow(simple_results) > 0) {
          result_simple <- data.frame(
            layer = layer_name,
            polygon_id = poly_id,
            area_id = "Total Area",
            category = simple_results[, 1],
            area = simple_results[, 2]
          )
          names(result_simple)[names(result_simple) == "polygon_id"] <- id_col
          names(result_simple)[names(result_simple) == "area"] <- area_col_name
          final_results_list <- append(final_results_list, list(result_simple))
        }

        if (!is.null(overlay_r)) {
          overlay_masked <- terra::mask(overlay_r, current_poly)
          overlay_results <- terra::zonal(
            area_masked,
            (layer_masked * 10) + overlay_masked,
            fun = "sum",
            na.rm = TRUE
          )

          if (nrow(overlay_results) > 0) {
            df_overlay <- as.data.frame(overlay_results)
            df_overlay$category <- floor(df_overlay[, 1] / 10)
            df_overlay$overlay_value <- df_overlay[, 1] %% 10
            df_overlay$area <- df_overlay[, 2]

            df_filtered <- df_overlay[df_overlay$overlay_value == 1, ]
            if (nrow(df_filtered) > 0) {
              agg_results <- terra::aggregate(area ~ category, data = df_filtered, FUN = sum, na.rm = TRUE)

              result_overlay <- data.frame(
                layer = layer_name,
                polygon_id = poly_id,
                area_id = "Overlay Area",
                category = agg_results$category,
                area = agg_results$area
              )
              names(result_overlay)[names(result_overlay) == "polygon_id"] <- id_col
              names(result_overlay)[names(result_overlay) == "area"] <- area_col_name
              final_results_list <- append(final_results_list, list(result_overlay))
            }
          }
        }
      }
    } else {
      simple_results <- terra::zonal(cell_area, current_layer, fun = "sum", na.rm = TRUE)
      result_simple <- data.frame(
        layer = layer_name,
        area_id = "Total Area",
        category = simple_results[, 1],
        area = simple_results[, 2]
      )
      names(result_simple)[names(result_simple) == "area"] <- area_col_name
      final_results_list <- append(final_results_list, list(result_simple))

      if (!is.null(overlay_r)) {
        overlay_results <- terra::zonal(cell_area, (current_layer * 10) + overlay_r, fun = "sum", na.rm = TRUE)
        df_overlay <- as.data.frame(overlay_results)
        df_overlay$category <- floor(df_overlay[, 1] / 10)
        df_overlay$overlay_value <- df_overlay[, 1] %% 10
        df_overlay$area <- df_overlay[, 2]

        df_filtered <- df_overlay[df_overlay$overlay_value == 1, ]
        if (nrow(df_filtered) > 0) {
          agg_results <- terra::aggregate(area ~ category, data = df_filtered, FUN = sum, na.rm = TRUE)

          result_overlay <- data.frame(
            layer = layer_name,
            area_id = "Overlay Area",
            category = agg_results$category,
            area = agg_results$area
          )
          names(result_overlay)[names(result_overlay) == "area"] <- area_col_name
          final_results_list <- append(final_results_list, list(result_overlay))
        }
      }
    }
  }

  # --- 4. Final Output Formatting ---
  final_df <- do.call(rbind, final_results_list)

  if (!is.null(final_df) && nrow(final_df) > 0 && omit_zero && "category" %in% names(final_df)) {
    final_df <- final_df[final_df$category != 0, ]
  }

  final_df
}
