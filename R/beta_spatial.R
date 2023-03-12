#' Spatial beta diversity for vector
#'
#' This function will compute beta diversity on vectors containing
#' multiple species at multiple sites. Species at sites should be
#' placed sequentially, so that the vector can be transformed in a
#' matrix with species at columns and sites at rows.
#' @param x A numeric vector with presence-absence data (0 or 1) for a set of species.
#' @param tree It can be a data frame with species traits or a phylogenetic tree.
#' @param global Logical. Mean of pairwise comparisons between focal cell and its neighbors (default) or mean of pairwise comparisons of all possible cells combinations.
#' @param spp Character. Species names.
#' @param nspp Numeric. Number of species.
#'
#' @return A SpatRaster with beta results.
spat.beta.vec <- function(x, tree, global = FALSE, spp, nspp){
  x <- matrix(x, ncol = nspp, byrow = F, dimnames = list(NULL, spp))
  x <- subset(x, select = colnames(x) != "lyr1")
  fcel <- ceiling(nrow(x)/2)
  x[] <- x[c(fcel, 1:(fcel - 1), (fcel + 1):nrow(x)), ]
  x <- x[stats::complete.cases(x) & rowSums(x, na.rm = T) > 0, ] # maybe replace NAs with 0
  if(all(is.na(x))){
    return(c(Btotal = NA, Brepl = NA, Brich = NA))
  } else if(!inherits(x, "matrix")){
    return(c(Btotal = 0, Brepl = 0, Brich = 0))
  } else if(sum(x, na.rm = T) == 0){
    return(c(Btotal = 0, Brepl = 0, Brich = 0))
  } else{
    res <- sapply(BAT::beta(x, tree, abund = FALSE),
                  function(x, global){
                    ifelse(global,
                           mean(x), # mean of all possible pairwise combinations
                           mean(as.matrix(x)[-1, 1])) # mean of focal against all
                  }, global)
    return(res)
  }
}

#' Spatial beta diversity for raster
#'
#' This function will compute beta diversity on spatRast objects
#' that contain binary (presence/absence) species distribution data.
#' @description Compute alpha diversity for taxonomic, functional, and phylogenetic diversity.
#' @param x A SpatRaster with presence-absence data (0 or 1) for a set of species.
#' @param tree A data.frame with species traits or a phylogenetic tree.
#' @param filename Character. Save results if a name is provided.
#' @param global Logical. default = FALSE to compare dissimilarity between focal cell and its neighboring cells
#' @param fm Focal matrix. Numeric. Make a focal ("moving window").
#' @param d Window radius to compute beta diversity.
#' @param type Character. Window format. Default = "circle".
#' @param na.policy Character. Default = "omit". See ?terra::focal3D for details.
#' @param ... Additional arguments to be passed passed down from a calling function.
#'
#' @return A SpatRaster with beta results.
#' @export
#'
#' @examples
#' \dontrun{
#' library(terra)
#' set.seed(100)
#' bin1 <- rast(ncol = 5, nrow = 5, nlyr = 10)
#' values(bin1) <- round(runif(ncell(bin1) * nlyr(bin1)))
#' names(bin1) <- paste0("sp", 1:10)
#' set.seed(100)
#' mass <- runif(10, 10, 800)
#' beak.size <- runif(10, .2, 5)
#' tail.length <- runif(10, 2, 10)
#' wing.length <- runif(10, 15, 60)
#' range.size <- runif(10, 10000, 100000)
#' traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
#' rownames(traits) <- names(bin1)
#' set.seed(100)
#' tree <- ape::rtree(n = 10, tip.label = names(bin1))
#' spat.beta(bin1)
#' spat.beta(bin1, traits)
#' spat.beta(bin1, tree)
#' }
spat.beta <- function(x, tree, filename = NULL, global = FALSE,
                      fm = NULL,
                      d = mean(terra::res(terra::rast(x)))*2,
                      type = "circle",
                      na.policy = "omit", ...){
  # transform data
  if(!inherits(x, "SpatRaster")){
    x <- terra::rast(x)
  }
  # create focal matrix
  if(is.null(fm)){
    min.d <- sqrt(prod(terra::res(x))) # mean(res(x)*112)
    if(d < min.d){
      stop(paste("radius too small to build a focal window.
                 Minimum d should be larger than:", min.d)) # 111.1194*res(x)[2]/(cos(y*(pi/180)))))
    }
    fm <- terra::focalMat(x,
                          d, # window size (if not provided create based on distance)
                          type = type,
                          fillNA = FALSE)
  }
  # transform values to 1 to find exact values
  fm[] <- fm/fm
  fm[is.nan(fm)] <- 0 # replace NaN by 0
  # test even-odd dimensions in window
  # 'terra::focal3D' only works with odd dimensions
  even <- (c(dim(fm), terra::nlyr(x)) %% 2) == 0
  if(any(even)){
    # test if fm dims are even
    if(even[1]){
      fm <- rbind(fm, 0)
    }
    if(even[2]){
      fm <- cbind(fm, 0)
    }
    # test if number of spp layers is even
    if(even[3]){
      # add layer to get odd dimensions
      x <- c(x, terra::app(x, function(x){
        ifelse(all(is.na(x)), NA, 0)
      }))
      # create array to 3D focal calculations
      fmA <- replicate(terra::nlyr(x), fm)
      # set weight 0 for last layer
      fmA[,,terra::nlyr(x)] <- 0
    } else{
      # create array to 3D focal calculations
      fmA <- replicate(terra::nlyr(x), fm)
    }
  } else{
    # create array to 3D focal calculations
    fmA <- replicate(terra::nlyr(x), fm)
  }
  if(missing(tree)){
    betaR <- terra::focal3D(x,
                            fmA,
                            spat.beta.vec,
                            global = global,
                            spp = names(x),
                            nspp = terra::nlyr(x),
                            na.policy = na.policy, ...)
  } else{
    betaR <- terra::focal3D(x,
                            fmA,
                            spat.beta.vec,
                            tree = tree,
                            global = global,
                            spp = names(x),
                            nspp = terra::nlyr(x),
                            na.policy = na.policy, ...)
  }
  # define names
  lyrnames <- c("Beta total", "Beta turn", "Beta nest")
  if(missing(tree)){
    names(betaR) <- paste0(lyrnames, ".TD")
  } else if(inherits(tree, "data.frame")){
    names(betaR) <- paste0(lyrnames, ".FD")
  } else{
    names(betaR) <- paste0(lyrnames, ".PD")
  }
  # save the output if filename is provided
  if(!is.null(filename)){
    betaR <- terra::writeRaster(betaR, filename, overwrite = TRUE, ...)
  }
  return(betaR)
}
