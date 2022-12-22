#' Average trait generalization
#'
#' @param trait Numeric vector with trait value for each species
#' @param r SpatRaster object with binarized distribution projected to all species in a given climate scenario
#' @param ... Additional arguments to be passed passed down from a calling function
#'
#' @return SpatRaster object with the average trait chosen
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' r <- terra::rast(array(sample(c(rep(1, 750), rep(0, 250))), dim = c(20, 20, 10)))
#' set.seed(100)
#' mass <- runif(10, 10, 800) # grams
#' mass
#' t <- ecogen(r, mass)
#' t
#' }
ecogen <- function(r, trait, ...){
  if(class(r) != "SpatRaster"){
    stop("'r' must be a SpatRaster object")
  }
  if(class(trait) != "numeric"){
    stop("'trait' must be a numeric vector")
  }
  if(terra::nlyr(r) != length(trait)){
    stop("'trait' length must be same as the number of 'r' layers in the same order")
  }
  nm <- deparse(substitute(trait))
  res <- terra::app(r,
                    function(x, trait, ...){
                      x1 <- x == 1
                      mean((x * trait)[x1], na.rm = TRUE)
                    }, trait = trait, ...)
  return(stats::setNames(res, nm))
}
