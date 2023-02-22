#' Beta temporal of phylogenetic diversity
#'
#' @param ref A SpatRaster object with binary maps of species distributions
#' @param fut A SpatRaster object with binary maps of species distributions
#' @param tree A phylo object including branch lengths
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
#' tree <- ape::rtree(n = 10, tip.label = paste0("sp", 1:10))
#' beta.pd <- betatemp_pd(ref, fut, tree)
#' beta.pd
#' }
betatemp_pd <- function(ref, fut, tree, cores = 1, filename = NULL, ...){
  nspp <- terra::nlyr(ref)
  spp <- names(ref)
  res <- numeric(3)
  names(res) <- c("Btotal.PD", "Bturn.PD", "Bnest.PD")
  terra::app(c(ref, fut),
             function(x, tree, nspp, spp, res, cores, ...){
               if(all(is.na(x))){
                 res[] <- NA
               } else {
                 x[is.na(x)] <- 0
                 x <- rbind(r = x[1:nspp], f = x[nspp + (1:nspp)])
                 colnames(x) <- spp
                 sbeta <- BAT::beta(x,
                                    tree,
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
             }, tree = tree, nspp = nspp, spp = spp, res = res, cores = cores, ...)
}
