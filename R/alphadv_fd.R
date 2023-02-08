#' Functional alpha diversity calculation
#'
#' It calculates functional richness for a given climate scenario
#'
#' @param r SpatRaster object with binarized distribution projected to all species for a given climate scenario
#' @param traits data.frame object with traits as columns and species as rownames
#' @param filename Output filename
#' @param ... Additional arguments to be passed passed down from a calling function
#'
#' @return SpatRaster object with functional diversity calculates as functional richness
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(20, 20, 10)))
#' names(ref) <- paste0("sp", 1:10)
#' ref
#' set.seed(100)
#' mass <- runif(10, 10, 800)
#' beak.size <- runif(10, .2, 5)
#' tail.length <- runif(10, 2, 10)
#' wing.length <- runif(10, 15, 60)
#' range.size <- runif(10, 10000, 100000)
#' traits <- as.data.frame(cbind(mass, beak.size, tail.length, wing.length, range.size))
#' rownames(traits) <- paste0("sp", 1:10)
#' traits
#' alpha.fd <- alpha_fd(ref, traits)
#' alpha.fd
#' }
alpha_fd <- function(r, traits, filename = NULL, ...){
  res <- terra::app(r,
                    function(x, traits, ...){
                      dist <- vegan::vegdist(traits, "euclidean")
                      axes <- stats::cmdscale(dist, k = ncol(traits)-1)
                      geometry::convhulln(axes[x > 0, , drop = FALSE], output.options = T)$vol # convex hull by site
                    }, traits = traits, ...)
  max <- terra::app(r,
                    function(x, traits, ...){
                      dist <- vegan::vegdist(traits, "euclidean")
                      axes <- stats::cmdscale(dist, k = ncol(traits)-1)
                      geometry::convhulln(axes, output.options = T)$vol # total convex hull
                    }, traits = traits, ...)
  resu <- res/max # rescale values between 0 and 1
  names(resu) <- "Functional Richness"
  if(!is.null(filename)){ # to save the rasters when the output filename is provide
    resu <- terra::writeRaster(resu, filename)
  }
  return(resu)
}
