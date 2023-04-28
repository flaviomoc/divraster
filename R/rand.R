#' standardize effect size
#'
#' @param x SpatRaster
#' @param tree species traits or phylogenetic tree
#' @param aleats number of randomizations
#' @param random randomization method
#' @param cores multi-core processing
#' @param filename output name
#' @param ... additional arguments
#'
#' @return SpatRaster with mean, sd, observed, and ses
#' @export
#'
#' @examples
spat.rand <- function(x,
                      tree,
                      aleats,
                      random = "spat",
                      cores = 1,
                      filename = NULL, ...){
  rand <- list() # to store the rasters in the loop
  rich <- terra::app(x, sum, na.rm = TRUE)
  fr2prob <- function(x){
    value <- NULL
    fr <- subset(terra::freq(x), value==1)[,"count"]
    all <- unlist(terra::global(x[[1]], function(x)sum(!is.na(x), na.rm=T)))
    p <- fr/all
    pin <- sapply(seq_along(p),
                  function(i, p){
                    sum(p[-i])
                  }, p=p)
    p*pin/(1-p)
  }
  fr_prob <- fr2prob(x)
  for(i in 1:aleats){
    ### shuffle
    pres.site.null <- SESraster::bootspat_str(x = x, rich = rich,
                                              fr_prob = fr_prob)
    # calculate fd
    rand[[i]] <- DMSD::spat.alpha(pres.site.null, tree)
  }
  rand <- terra::rast(rand) # to transform a list in raster

  rand.mean <- terra::mean(rand, na.rm = TRUE) # mean pd
  rand.sd <- terra::stdev(rand, na.rm = TRUE) # sd pd

  ### PD observed
  {
    # x.reord <- x[[rownames(tree)]] # to reorder the stack according to the tree

    obs <- DMSD::spat.alpha(x, tree)
  }

  ### Concatenate rasters
  rand <- c(rand.mean, rand.sd, obs)

  ## Calculating the standard effect size (SES)
  {
    ses <- function(x){
      (x[1] - x[2])/x[3]
    }
    ses <- terra::app(c(obs, rand.mean, rand.sd),
                      ses)
    names(ses) <- "SES"
  }

  out <- c(rand, ses)
  names(out) <- c("Mean", "SD", "Observed", "SES")

  if (!is.null(filename)){ # to save the rasters when the path is provide
    out <- terra::writeRaster(out, filename)
  }
  return(out)
}
