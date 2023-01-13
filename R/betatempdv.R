#' Beta diversity parameters
#'
#' @param r Binary vector of reference climate scenario
#' @param f Binary vector of future climate scenario
#'
#' @return SpatRaster of beta diversity parameters
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
#' pars <- .abc(ref, fut)
#' pars
#' }
.abc <- function(r, f){
  a <- sum((r + f) == 2)
  b <- sum(r > f)
  c <- sum(f > r)
  return(c(a, b, c))
}
#'
#' Temporal beta diversity calculation
#'
#' It calculates beta diversity based on Jaccard dissimilarity index between reference and future scenarios
#'
#' @param ref SpatRaster object with binarized distribution projected to all species from climate scenario 1
#' @param fut SpatRaster object with binarized distribution projected to all species from climate scenario 2
#' @param ... Additional arguments to be passed passed down from a calling function
#' @param filename Output filename
#'
#' @return SpatRaster object with each metric as an individual layer (beta total, turnover, nestedness, and ratio)
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
#' b <- betatempdv(ref, fut)
#' b
#' }
betatempdv <- function(ref, fut, filename = NULL, ...){
  nspp <- terra::nlyr(ref)
  if(class(ref) != "SpatRaster"){
    stop("'ref' must be a SpatRaster object")
  }
  if(class(fut) != "SpatRaster"){
    stop("'fut' must be a SpatRaster object")
  }
  if(!all(names(ref) == names(fut))){
    stop("names of 'ref' and 'fut' must match")
  }
  if(terra::nlyr(ref) != terra::nlyr(fut)){
    stop("'ref' and 'fut' must have the same number of layers")
  }
  r <- terra::app(c(ref, fut),
                  function(x, nspp){
                    res <- numeric(4)
                    pars <- .abc(r = x[1:nspp], f = x[nspp + (1:nspp)])
                    res[1] <- (pars[2] + pars[3]) / (pars[1] + pars[2] + pars[3])
                    res[2] <- (2 * min(pars[2], pars[3])) / (pars[1] + (2 * min(pars[2], pars[3]))) # turn
                    res[3] <- ((pars[2] + pars[3]) / (pars[1] + pars[2] + pars[3])) - ((2 * min(pars[2], pars[3])) / (pars[1] + (2 * min(pars[2], pars[3])))) # nest
                    res[4] <- ((2 * min(pars[2], pars[3])) / (pars[1] + (2 * min(pars[2], pars[3])))) / ((pars[2] + pars[3]) / (pars[1] + pars[2] + pars[3]))
                    names(res) <- c("Beta total", "Beta turnover", "Beta nestedness", "Beta ratio")
                    return(res)
                  }, nspp = nspp, ...)
  if(!is.null(filename)){ # to save the rasters when the output filename is provide
    r <- terra::writeRaster(r, filename)
  }
  return(r)
}
