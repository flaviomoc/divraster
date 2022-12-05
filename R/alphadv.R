#' Alpha diversity calculation for vector
#'
#' @param bin Object of class SpatRaster with binarized distribution projected to all species from climate scenario 1
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
.alphadv <- function(bin){
  r <- sum(bin > 0)
  return(r)
}

#' Alpha diversity calculation for raster
#'
#' @param bin1 Object of class SpatRaster with binarized distribution projected to all species from climate scenario 1
#' @param bin2 Object of class SpatRaster with binarized distribution projected to all species from climate scenario 2
#'
#' @return Object of class SpatRaster with alpha diversity/species richness. If bin2 is provide, it calculates delta richness
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 750), rep(0, 250))), dim = c(20, 20, 10)))
#' names(ref) <- paste0("sp", 1:10)
#' ref
#' fut <- terra::rast(array(sample(c(rep(1, 300), rep(0, 700))), dim = c(20, 20, 10)))
#' names(fut) <- paste0("sp", 1:10)
#' fut
#' ref.rich <- alphadv(ref)
#' ref.rich
#' fut.rich <- alphadv(fut)
#' fut.rich
#' delta.rich <- alphadv(ref, fut)
#' delta.rich
#' }
alphadv <- function(bin1, bin2){
  if(!missing(bin2)){
    r1 <- terra::app(bin1, .alphadv)
    r2 <- terra::app(bin2, .alphadv)
    r <- r2 - r1 # delta richness
    names(r) <- "Delta richness"
  } else {
    r <- terra::app(bin1, .alphadv) # species richness
    names(r) <- "Richness"
  }
  return(r)
}
