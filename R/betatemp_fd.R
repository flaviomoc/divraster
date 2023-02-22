#' Beta temporal of functional diversity
#'
#' @param ref A SpatRaster object with binary maps of species distributions
#' @param fut A SpatRaster object with binary maps of species distributions
#' @param traits A data.frame object with traits as columns and species as rownames
#' @param cores A positive integer indicating if parallel processing should be used (cores > 1)
#' @param filename Output filename
#' @param ... Additional arguments to be passed down from a calling function
#'
#' @return A SpatRaster object with beta total, turnover, and nestedness
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
#' names(ref) <- paste0("sp", 1:10)
#' fut <- terra::rast(array(sample(c(rep(1, 400), rep(0, 600))), dim = c(10, 10, 10)))
#' names(fut) <- names(ref)
#' set.seed(100)
#' mass <- runif(10, 10, 800)
#' beak.size <- runif(10, .2, 5)
#' tail.length <- runif(10, 2, 10)
#' wing.length <- runif(10, 15, 60)
#' range.size <- runif(10, 10000, 100000)
#' traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
#' rownames(traits) <- names(ref)
#' beta.fd <- betatemp_fd(ref, fut, traits)
#' beta.fd
#' }
betatemp_fd <- function(ref, fut, traits, cores = 1, filename = NULL, ...)
  {
  if (missing(fut) || is.null(fut)) {
    stop("'fut' object invalid", call. = FALSE)
  }
  if (class(ref) != "SpatRaster"){
    stop ("'ref' must be a SpatRaster object")
  }
  if (class(traits) != "data.frame"){
    stop ("'traits' must be a data.frame object")
  }
  if (!all(names(ref) == rownames(traits))){
    stop ("names of 'ref' and rownames of 'traits' must match")
  }
  if (!all(names(ref) == names(fut))){
    stop ("names of 'ref' and 'fut' must match")
  }
  if (!is.numeric(traits[1,1])){
    stop("'traits' first column must be numeric")
  }
  if (terra::nlyr(ref) == 1){
    stop("'ref' must have at least 2 layers")
  }
  if (terra::nlyr(fut) == 1){
    stop("'fut' must have at least 2 layers")
  }
  if (terra::nlyr(ref) != terra::nlyr(fut)){
    stop("'ref' and 'fut' must have the same number of layers")
  }
  nspp <- terra::nlyr(ref)
  spp <- names(ref)
  res <- numeric(3)
  names(res) <- c("Btotal.FD", "Bturn.FD", "Bnest.FD")
  terra::app(c(ref, fut),
             function(x, traits, nspp, spp, res, cores, ...){
               if(all(is.na(x))){
                 res[] <- NA
               } else {
                 x[is.na(x)] <- 0
                 x <- rbind(r = x[1:nspp], f = x[nspp + (1:nspp)])
                 colnames(x) <- spp
                 sbeta <- BAT::beta(x,
                                    traits,
                                    abund = FALSE)
                 res[] <- sapply(sbeta,
                                 function(x){
                                   x
                                 })
               }
               if(!is.null(filename)){
                 res <- terra::writeRaster(res, filename, overwrite = TRUE)
               }
               return(res)
             }, traits = traits, nspp = nspp, spp = spp, res = res, cores = cores, ...)
}
