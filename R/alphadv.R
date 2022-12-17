#' Alpha diversity calculation for raster
#'
#' @param bin Object of class SpatRaster with binarized distribution projected to all species for a given climate scenario
#'
#' @return Object of class SpatRaster with alpha diversity/species richness
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 750), rep(0, 250))), dim = c(20, 20, 10)))
#' names(ref) <- paste0("sp", 1:10)
#' ref
#' ref.rich <- alphadv(ref)
#' ref.rich
#' }
alphadv <- function(bin){
  r <- terra::app(bin, sum, na.rm = TRUE) # species richness
  names(r) <- "Richness"
  return(r) # terra::app function does not work when it returns only one raster
}
