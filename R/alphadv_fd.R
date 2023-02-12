#' Functional alpha diversity calculation
#'
#' It calculates functional richness for a given climate scenario. It is computed as the volume of the convex hull following Villéger et al. (2008)
#'
#' @param traits data.frame object with traits as columns and species as rownames
#' @param filename Output filename
#' @param ... Additional arguments to be passed passed down from a calling function
#' @param cores A positive integer indicating if parallel processing should be used (cores > 1)
#' @param stand A boolean indicating whether to divide FRic values by their maximum over all species (default: TRUE). It allows to compare indices values between assemblages
#' @param sce SpatRaster object with binarized distribution projected to all species for a given climate scenario
#'
#' @references Villéger, S. et al. 2008. New Multidimensional Functional Diversity Indices for a Multifaceted Framework in Functional Ecology. - Ecology 89: 2290–2301
#'
#' @return SpatRaster object with functional richness
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
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
#' fd <- alpha_fd(ref, traits)
#' fd
#' }
alpha_fd <- function(sce, traits, filename = NULL, stand = TRUE, cores = 1, ...){
  r1 <- terra::app(sce, function(x){
    axes <- stats::cmdscale(stats::dist(traits, "euclidean"), k = ncol(traits)-1)
    geometry::convhulln(axes[x > 0, , drop = FALSE],
                        output.options = T)$vol
  }, ...)
  r2 <- terra::app(sce, function(x){
    axes <- stats::cmdscale(stats::dist(traits, "euclidean"), k = ncol(traits)-1)
    geometry::convhulln(axes,
                        output.options = T)$vol
  }, ...)
  resu <- terra::app(c(r1, r2), function(x){
    x[[1]]/x[[2]]
  })
  if(stand == TRUE){
    names(resu) <- "Functional richness"
    return(resu)
  }
  else{
    resu <- c(r1, resu)
    names(resu) <- c("Functional richness", "Functional richness stand")
    return(resu)
  }
  if(!is.null(filename)){ # to save the rasters when the output filename is provide
    resu <- terra::writeRaster(resu, filename, overwrite = TRUE)
  }
  return(resu)
}
