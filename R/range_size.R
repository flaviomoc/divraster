#' Area calculation
#'
#' @param r1 A SpatRaster or a list of multiple SpatRasters.
#' @param unit Character. Default is "km", but "m" and "ha" are
#' also available.
#' @param r2 A SpatRaster with the same resolution and extent as "r1".
#' @param r3 A SpatRaster with the same resolution and extent as "r1".
#' @param filename Character. Save results if a name is provided.
#'
#' @return A vector or a data.frame with area values in the chosen
#' unit.
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' my.list <- list(bin1 = bin1[[1:2]])
#' area.calc(my.list)
#' }
area.calc <- function(r1, unit = "km",
                      r2 = NULL, r3 = NULL,
                      filename = "") {
  if (is.list(r1)) {
    res <- range.list(r1, unit = unit, r2, r3, filename = filename)

  } else {
    res <- data.frame(range.rast(r1))
  }

  if (filename != "") {
    utils::write.csv(res, file = filename)
  }

  return(res)
}
