#' Alternative method to calculate alpha taxonomic diversity
#'
#' @param bin A SpatRaster with presence-absence data (0 or 1) for
#' a set of species.
#' @param cores A positive integer. If cores > 1, a 'parallel'
#' package cluster with that many cores is created and used.
#' @param filename Character. Save results if a name is provided.
#'
#' @return A SpatRaster object with richness.
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' spat.alpha2(bin1)
#' }
spat.alpha2 <- function(bin, cores = 1, filename = "") {
  res <- terra::app(bin, sum, na.rm = TRUE)
  names(res) <- "Richness"

  if (filename != "") {
    terra::writeRaster(res,
                       filename = filename,
                       overwrite = TRUE)
  }

  return(res)
}
