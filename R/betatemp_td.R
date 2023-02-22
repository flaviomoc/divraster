#' Beta temporal of taxonomic diversity
#'
#' @param ref A SpatRaster object with binary maps of species distributions
#' @param fut A SpatRaster object with binary maps of species distributions
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
#' beta.td <- betatemp_td(ref, fut)
#' beta.td
#' }
betatemp_td <- function(ref, fut, cores = 1, filename = NULL, ...)
  {
  if (missing(fut) || is.null(fut)) {
    stop("'fut' object invalid", call. = FALSE)
  }
  if (class(ref) != "SpatRaster"){
    stop("'ref' must be a SpatRaster object")
  }
  if (class(fut) != "SpatRaster"){
    stop("'fut' must be a SpatRaster object")
  }
  if(!all(names(ref) == names(fut))){
    stop("names of 'ref' and 'fut' must match")
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
  names(res) <- c("Btotal.TD", "Bturn.TD", "Bnest.TD")
  terra::app(c(ref, fut),
             function(x, nspp, spp, res, cores, ...){
               if(all(is.na(x))){
                 res[] <- NA
               } else {
                 x[is.na(x)] <- 0
                 x <- rbind(r = x[1:nspp], f = x[nspp + (1:nspp)])
                 colnames(x) <- spp
                 sbeta <- BAT::beta(x,
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
             }, nspp = nspp, spp = spp, res = res, cores = cores, ...)
}
