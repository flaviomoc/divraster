#' Alpha diversity calculation for raster
#'
#' @param bin SpatRaster object with binarized distribution projected to all species for a given climate scenario
#' @param ... Additional arguments to be passed passed down from a calling function
#' @param filename Output filename
#'
#' @return SpatRaster object with alpha diversity/species richness
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
alphadv <- function(bin, filename = NULL, ...){
  if(class(bin) != "SpatRaster"){
    stop("'bin' must be a SpatRaster object")
  }
  if(terra::nlyr(bin) == 1){
    stop("'bin' must have at least 2 layers")
  }
  else {
    r <- terra::app(bin, sum, na.rm = TRUE, ...) # species richness
    names(r) <- "Richness"
  }
  if(!is.null(filename)){ # to save the rasters when the output filename is provide
    r <- terra::writeRaster(r, filename)
  }
  return(r) # terra::app function does not work when it returns only one raster
}
