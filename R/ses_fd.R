#' Standardized Functional Richness calculation for raster
#'
#' @param fd A SpatRaster object with functional richness
#' @param aleats A positive integer indicating how many times the calculation should be repeated
#' @param cores A positive integer indicating if parallel processing should be used (cores > 1)
#' @param filename Output filename
#' @param ... Additional arguments to be passed down from a calling function
#'
#' @return A SpatRaster object with mean, standard deviation, observed functional richness, and standardized functional richness
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
#' fd <- alphadv_fd(ref, traits)
#' fd
#' ses.fd <- ses_fd(fd)
#' ses.fd
#' }
ses_fd <- function(fd, aleats = 999, cores = 1, filename = NULL, ...){
  if(class(fd) != "SpatRaster"){
    stop("'fd' must be a SpatRaster object")
  }
  rand <- list()
  for(i in 1:aleats){
    rand[[i]] <- terra::spatSample(fd, aleats, "random", as.raster = TRUE)
  }
  rand <- terra::rast(rand)
  rand.mean <- terra::mean(rand, na.rm = TRUE)
  rand.sd <- terra::stdev(rand, na.rm = TRUE)
  res <- terra::app(terra::rast(c(fd.mean = rand.mean, fd.sd = rand.sd, fd.obs = fd)),
                    function(x){
                      (x[[3]] - x[[1]])/x[[2]]
                    }, cores = cores, ...)
  names(res) <- "SES FD"
  out <- c(rand.mean, rand.sd, fd, res)
  names(out) <- c("Mean", "SD", "FD Observed", "SES FD")
  return(out)
  if(!is.null(filename)){ # to save the rasters when the output filename is provide
    out <- terra::writeRaster(out, filename, overwrite = TRUE)
  }
  return(out)
}
