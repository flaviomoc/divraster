#' Alpha diversity calculation
#'
#' @param bin1 Object of class SpatRaster with binarized distribution projected to all species from climate scenario 1
#' @param bin2 Object of class SpatRaster with binarized distribution projected to all species from climate scenario 2
#'
#' @return Object of class SpatRaster with alpha diversity/species richness. If bin2 is provide, it calculates delta richness
#' @export
#'
#' @examples
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
alphadv <- function(bin1, bin2){
  if(missing(bin2) == "TRUE"){
    r <- sum(bin1 > 0) # species richness
    names(r) <- "Richness"
  } else {
    r2 <- sum(bin2 > 0)
    r1 <- sum(bin1 > 0)
    r <- r2 - r1 # delta richness
    names(r) <- "Delta richness"
  }
  return(r)
}
