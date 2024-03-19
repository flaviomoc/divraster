#' Species suitability change between climate scenarios
#'
#' @param r1 A SpatRaster with presence-absence data (0 or 1)
#' for a set of species.
#' @param r2 A SpatRaster with presence-absence data (0 or 1)
#' for a set of species.
#' @param filename Character. Save results if a name is provided.
#'
#' @return A SpatRaster with suitability change (gain, loss,
#' unchanged, and unsuitable).
#' @export
#'
#' @examples
#' #' \donttest{
#' library(terra)
#' r1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' r2 <- terra::rast(system.file("extdata", "fut.tif",
#' package = "divraster"))
#' suit.change(r1, r2)
#' }
suit.change <- function(r1, r2, filename = "") {
  gain <- (r2 == 1) & (r1 == 0)
  loss <- (r2 == 0) & (r1 == 1)
  no_change <- (r2 == 1) & (r1 == 1)
  unsuitable_both <- (r2 == 0) & (r1 == 0)
  change_map <- gain * 1 + loss * 2 + no_change * 3 + unsuitable_both * 4
  if (filename != "") {
    terra::writeRaster(change_map, filename = filename, overwrite = TRUE)
  }
  return(change_map)
}
