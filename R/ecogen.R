#' Average trait generalization
#'
#' @param trait A numeric vector with trait value for each species
#' @param r A SpatRaster object with binarized distribution projected to all species in a given climate scenario
#' @param ... Additional arguments to be passed down from a calling function
#' @param filename Output filename
#' @param cores A positive integer indicating if parallel processing should be used (cores > 1)
#'
#' @return A SpatRaster object with the average trait chosen
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' r <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
#' names(r) <- paste0("sp", 1:10)
#' r
#' set.seed(100)
#' mass <- runif(10, 10, 800)
#' mass
#' t <- ecogen(r, mass)
#' t
#' }
ecogen <- function(r, trait, filename = NULL, cores = 1, ...){
  if (missing(trait) || is.null(trait)) {
    stop("Please provide a trait dataset", call. = FALSE)
  }
  if(class(r) != "SpatRaster"){
    stop("'r' must be a SpatRaster object")
  }
  if(class(trait) != "numeric"){
    stop("'trait' must be a numeric vector")
  }
  if(terra::nlyr(r) == 1){
    stop("'ref' must have at least 2 layers")
  }
  if(terra::nlyr(r) != length(trait)){
    stop("'trait' length must be same as the number of 'r' layers in the same order")
  }
  nm <- deparse(substitute(trait))
  res <- terra::app(r,
                    function(x, trait, cores, ...){
                      x1 <- x == 1
                      mean((x * trait)[x1], na.rm = TRUE)
                    }, trait = trait, cores = cores, ...)
  if(!is.null(filename)){ # to save the rasters when the output filename is provide
    res <- terra::writeRaster(res, filename, overwrite = TRUE)
  }
  return(stats::setNames(res, nm))
}
