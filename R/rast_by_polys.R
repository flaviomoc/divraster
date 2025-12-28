#' Summarise raster values by polygons
#'
#' @description
#' Extracts values from a \code{SpatRaster} for each polygon in a
#' \code{SpatVector} and returns a data frame that combines polygon
#' identifiers with user-defined summary statistics of the raster values.
#'
#' @param x A \code{SpatRaster} object containing one or more layers.
#' @param polygons A \code{SpatVector} with polygon geometries used to
#'   summarise raster values.
#' @param id_col Optional character string giving the name of a column in
#'   \code{polygons} to be used as an identifier (for example, \code{"PA_ID"}).
#'   If \code{NULL} (default), all non-geometry attributes from
#'   \code{polygons} are joined to the summary table.
#' @param fun A function applied to the vector of raster values extracted
#'   for each polygon. The function must return a named vector. It should
#'   accept \code{...} so that arguments such as \code{na.rm = TRUE} can be
#'   passed through. The default is
#'   \code{function(v, ...) mean(v, na.rm = TRUE)}.
#' @param na.rm Logical; if \code{TRUE}, missing values are removed before
#'   applying \code{fun}. Passed to \code{fun} via \code{...}.
#'
#' @return
#' A \code{data.frame} with one row per polygon. If \code{id_col} is not
#' \code{NULL}, the first column is the specified identifier; otherwise,
#' all attribute columns from \code{polygons} are included. Additional
#' columns contain the summary statistics returned by \code{fun} for each
#' raster layer.
#'
#' @details
#' This function is a convenience wrapper around \code{terra::extract()},
#' combining extraction, summarisation and binding of polygon attributes
#' into a single step. It supports multilayer rasters; in that case the
#' summary statistics are returned for each layer.
#'
#' @examples
#' \dontrun{
#' library(terra)
#'
#' # Example SpatRaster and SpatVector
#' r <- rast(system.file("ex/elev.tif", package = "terra"))
#' v <- as.polygons(r > 500, dissolve = TRUE)
#' v$PA_ID <- paste0("PA_", seq_len(nrow(v)))
#'
#' # Mean elevation per polygon
#' pa_stats <- rast.by.polys(
#'   x        = r,
#'   polygons = v,
#'   id_col   = "PA_ID"
#' )
#'
#' # Multiple statistics per polygon
#' pa_stats_multi <- rast.by.polys(
#'   x        = r,
#'   polygons = v,
#'   id_col   = "PA_ID",
#'   fun      = function(v, ...) c(
#'     mean = mean(v, ...),
#'     min  = min(v, ...),
#'     max  = max(v, ...)
#'   ),
#'   na.rm    = TRUE
#' )
#' }
#'
#' @export
#' @importFrom terra extract
rast.by.polys <- function(x,
                          polygons,
                          id_col = NULL,
                          fun = function(v, ...) mean(v, na.rm = TRUE),
                          na.rm = TRUE) {
  # Basic type checks
  if (!inherits(x, "SpatRaster")) {
    stop("Argument 'x' must be a terra::SpatRaster.", call. = FALSE)
  }
  if (!inherits(polygons, "SpatVector")) {
    stop("Argument 'polygons' must be a terra::SpatVector with polygons.", call. = FALSE)
  }

  # If an ID column is requested, check that it exists
  if (!is.null(id_col) && !(id_col %in% names(polygons))) {
    stop("Column '", id_col, "' not found in 'polygons'.", call. = FALSE)
  }

  # Extract summaries per polygon
  summary_df <- terra::extract(
    x     = x,
    y     = polygons,
    fun   = fun,
    na.rm = na.rm,
    ID    = FALSE
  )

  # Bind polygon attributes
  if (is.null(id_col)) {
    # keep all attributes
    attr_df <- as.data.frame(polygons)
  } else {
    # keep only the chosen ID column
    attr_df <- as.data.frame(polygons[, id_col, drop = FALSE])
  }

  out <- cbind(attr_df, summary_df)
  rownames(out) <- NULL
  out
}
