#' Calculate average trait generalization
#'
#' @param trait Numeric vector with trait value for each species
#' @param r Object of class SpatRaster with binarized distribution projected to all species in a given climate scenario
#'
#' @return Object of class SpatRaster with the average trait chosen
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 750), rep(0, 250))), dim = c(20, 20, 10)))
#' set.seed(100)
#' mass <- runif(10, 10, 800) # grams
#' mass
#' t <- ecogen(ref, mass)
#' t
#' terra::plot(t)
#' }
ecogen <- function(r, trait){
  nm <- deparse(substitute(trait))
  res <- terra::app(r,
                    function(x, trait){
                      x1 <- x == 1
                      mean((x * trait)[x1], na.rm = TRUE)
                    }, trait = trait)
  return(stats::setNames(res, nm))
}
