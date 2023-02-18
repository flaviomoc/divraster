#' Functional alpha diversity calculation
#'
#' It calculates functional richness for a given climate scenario. It is computed as the volume of the convex hull following Villéger et al. (2008)
#'
#' @param traits A data.frame object with traits as columns and species as rownames
#' @param filename Output filename
#' @param ... Additional arguments to be passed passed down from a calling function
#' @param cores A positive integer indicating if parallel processing should be used (cores > 1)
#' @param method The distance measure to be used. This must be "euclidean" for numeric traits or "gower" for mixed traits
#' @param stand A boolean indicating whether to divide FRic values by their maximum over all species (default: TRUE). It allows to compare indices values between assemblages
#' @param sce A SpatRaster object with binarized distribution projected to all species for a given climate scenario
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
#' traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
#' rownames(traits) <- paste0("sp", 1:10)
#' traits
#' fd <- alpha_fd(ref, traits)
#' fd
#' }
alpha_fd <- function(sce, traits, method = "euclidean", filename = NULL, stand = TRUE, cores = 1, ...){
  method <- match.arg(method, c("euclidean", "gower"))
  if(terra::nlyr(sce) == 1){
    stop("'sce' must have at least 2 layers")
  }
  if (missing(traits) || is.null(traits)) {
    stop("Please provide a trait dataset", call. = FALSE)
  }
  if(terra::nlyr(sce) != nrow(traits)){
    stop("'sce' and 'traits' must have the same number of species")
  }
  if(class(sce) != "SpatRaster"){
    stop("'sce' must be a SpatRaster object")
  }
  if(class(traits) != "data.frame"){
    stop("'traits' must be a data.frame object")
  }
  if(method == "euclidean"){
    r1 <- terra::app(sce, function(x){
      axes <- stats::cmdscale(stats::dist(traits, "euclidean"))
      geometry::convhulln(axes[x > 0, , drop = FALSE],
                          output.options = T)$vol
    }, cores = cores, ...)
    r2 <- terra::app(sce, function(x){
      axes <- stats::cmdscale(stats::dist(traits, "euclidean"))
      geometry::convhulln(axes,
                          output.options = T)$vol
    }, cores = cores, ...)
  }
  else {
    r1 <- terra::app(sce, function(x){
      axes <- stats::cmdscale(FD::gowdis(traits))
      geometry::convhulln(axes[x > 0, , drop = FALSE],
                          output.options = T)$vol
    }, cores = cores, ...)
    r2 <- terra::app(sce, function(x){
      axes <- stats::cmdscale(FD::gowdis(traits))
      geometry::convhulln(axes,
                          output.options = T)$vol
    }, cores = cores, ...)
  }
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
