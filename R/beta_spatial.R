#' Compute beta diversity on vectors
#'
#' This function will compute beta diversity on vectors containing
#' multiple species at multiple sites. Species at sites should be
#' placed sequentially, so that the vector can be transformed in a
#' matrix with species at columns and sites at rows
#'
#' @param x numeric vector with multiple species and multiple sites
#' @param nspp numeric. number of species to transform the vector
#' into a matrix with nspp columns
#' @inheritParams betapart::phylo.beta.pair
#' @inheritParams betapart::beta.pair
# #' @export
beta.focal.vec <- function(x, nspp, index.family="sorensen", tree=NA){
  # print(nspp)
  x <- matrix(x, ncol=nspp, byrow = F)
  # print(x)
  # tofill <- apply(x, 1, function(x){sum(is.na(x))}) #rowSums(x) < nspp

  # xna <- is.na(x)
  # tofill <- rowSums(xna)
  # tofill <- tofill > 0 & tofill < nspp
  # x[tofill, is.na(x[tofill,])] <- 0
  x <- x[stats::complete.cases(x) & rowSums(x, na.rm = T)>0,] # maybe replace NAs with 0

  mean_turnover <- mean_nestedness <- mean_beta <- numeric(1)

  if(all(is.na(x))){
    return(c(turnover=NA, nestedness=NA, beta=NA, beta_ratio=NA))
  } else if(!inherits(x, "matrix")) {
    return(c(turnover=mean_turnover, nestedness=mean_nestedness, beta=mean_beta, beta_ratio=mean_nestedness/mean_beta))
  } else if(sum(x, na.rm = T)==0) {
    return(c(turnover=mean_turnover, nestedness=mean_nestedness, beta=mean_beta, beta_ratio=mean_nestedness/mean_beta))
  } else {
    if(is.na(tree)){
      res <- betapart::beta.pair(x, index.family=index.family)
    } else {
      res <- betapart::phylo.beta.pair(x, tree, index.family=index.family)
    }
    if(sum(res[[1]], na.rm = T)==0){
      mean_turnover <- 0
    } else {
      mean_turnover <- mean(res[[1]][lower.tri(res[[1]])], na.rm=T) # mean(as.matrix(res[[1]])[2:length(as.matrix(res[[1]])[,1]),1], na.rm=TRUE)
    }
    if(sum(res[[2]], na.rm = T)==0){
      mean_nestedness <- 0
    } else {
      mean_nestedness <- mean(res[[2]][lower.tri(res[[2]])], na.rm=T) # mean(as.matrix(res[[2]])[2:length(as.matrix(res[[2]])[,1]),1], na.rm=TRUE)
    }
    if(sum(res[[3]], na.rm = T)==0){
      mean_beta <- 0
    } else {
      # print(x)
      # print(res[[3]])
      mean_beta <- mean(res[[3]][lower.tri(res[[3]])], na.rm=T) # mean(as.matrix(res[[3]])[2:length(as.matrix(res[[3]])[,1]),1], na.rm=TRUE)
    }
    return(c(turnover=mean_turnover, nestedness=mean_nestedness, beta=mean_beta, beta_ratio=mean_nestedness/mean_beta))
    # return(c(mean_turnover, mean_nestedness, mean_beta, mean_nestedness/mean_beta))
  }
}

#' Compute beta diversity on spatRast objects
#'
#' This function will compute beta diversity on spatRast objects
#' that contain binary (presence/absence) species distribution data
#'
#' @param x raster brick or raster stack of species presence/absence
#' @param fm focal matrix. Numeric. Make a focal ("moving window")
#' weight matrix for use in the focal function
# #' @param d window radius to compute beta diversity metrics
#' @param numCores Number of cores to be used in parallel calculation
#' @param filetype file format expresses as GDAL driver names. If this
#' argument is not supplied, the driver is derived from the filename.
#' For details see \code{\link[terra]{writeRaster}}
#' @param overwrite Logical. Should saved files be overwritten with new values?
#' @inheritParams betapart::phylo.beta.pair
#' @inheritParams betapart::beta.pair
#' @inheritParams terra::focalMat
#' @inheritParams terra::writeRaster
#' @export
beta.focal.spat <- function(x, fm=NULL, d = mean(terra::res(terra::rast(x)))*2, type = "circle",
                       index.family="sorensen", tree=NA,
                       filetype="GTiff", filename=NULL, overwrite=T,
                       numCores=1, ...) {
  if(!inherits(x, c("SpatRaster"))){
    x <- terra::rast(x)
  }

  # nspp <- terra::nlyr(x)

  if(is.null(fm)){
    min.d <- sqrt(prod(terra::res(x))) #mean(res(x)*112)
    if(d < min.d) {
      stop(paste("radius too small to build a focal window.
                 Minimum d should be larger than:", min.d)) #111.1194*res(x)[2]/(cos(y*(pi/180)))))
    }

    fm <- terra::focalMat(x, d,
                          type = type,
                          fillNA = F)
  }
  # transformar tudo em 1 para encontrar valores exatos
  fm[] <- fm/max(fm, na.rm = T)

  ## test even-odd dimensions in window
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
      x <- c(x, terra::rast(x, nlyrs=1, vals=0))
      # create array to 3D focal calculations
      fmA <- replicate(terra::nlyr(x), fm)
      # set weight 0 for last layer
      fmA[,,terra::nlyr(x)] <- 0
    } else {
      # create array to 3D focal calculations
      fmA <- replicate(terra::nlyr(x), fm)
    }
  } else {
    # create array to 3D focal calculations
    fmA <- replicate(terra::nlyr(x), fm)
  }

  # print(terra::nlyr(x))

  betaR <- terra::focal3D(x, fmA,
                          beta.focal.vec,
                          index.family=index.family,
                          tree=tree, nspp=terra::nlyr(x), # nspp=nspp
                          na.policy="all")#[[1:4]]
  # names(betaR) <- c("turnover", "nestedness", "beta_div", "beta_ratio")

  if(!is.null(filename)){
    betaR <- terra::writeRaster(betaR, filename = filename,
                                 overwrite=overwrite, filetype=filetype, ...)
  }
  return(betaR)
}


#' Compute temporal beta diversity on vectors
#'
#' This function will compute beta diversity on vectors containing
#' multiple species at two sites. Species at sites should be
#' placed sequentially, so that the vector can be transformed in a
#' matrix with species at columns and sites at rows
#'
#' @param x numeric vector with multiple species at two sites
#' @param ... additional arguments for fun. Not in use.
#' @inheritParams betapart::beta.temp
# #' @export
beta.temp.vec <- function(x, index.family="sorensen", ...){
  if(all(is.na(x))){
    return(c(turnover=NA, nestedness=NA, beta_div=NA, beta_ratio=NA))
  }

  x <- matrix(x, ncol = 2, byrow = F)
  tofill <- apply(x, 1, function(x){sum(is.na(x))}) #rowSums(x) < nspp
  tofill <- tofill > 0 & tofill < 2
  x[tofill, is.na(x[tofill,])] <- 0
  x <- x[stats::complete.cases(x),] # maybe replace NAs with 0
  mean_turnover <- mean_nestedness <- mean_beta <- numeric(1)

  if(sum(x, na.rm = T)==0) {
    return(c(turnover=mean_turnover, nestedness=mean_nestedness, beta_div=mean_beta, beta_ratio=mean_nestedness/mean_beta))
  } else {
    res <- betapart::beta.temp(matrix(x[,1], nrow = 1),
                               matrix(x[,2], nrow = 1),
                               index.family)

    if(sum(res[,1], na.rm = T)==0){
      mean_turnover <- 0
    } else {
      mean_turnover <- mean(res[,1], na.rm=T) # mean(as.matrix(res[[1]])[2:length(as.matrix(res[[1]])[,1]),1], na.rm=TRUE)
    }
    if(sum(res[,2], na.rm = T)==0){
      mean_nestedness <- 0
    } else {
      mean_nestedness <- mean(res[,2], na.rm=T) # mean(as.matrix(res[[2]])[2:length(as.matrix(res[[2]])[,1]),1], na.rm=TRUE)
    }
    if(sum(res[,3], na.rm = T)==0){
      mean_beta <- 0
    } else {
      mean_beta <- mean(res[,3], na.rm=T) # mean(as.matrix(res[[3]])[2:length(as.matrix(res[[3]])[,1]),1], na.rm=TRUE)
    }
    return(c(turnover=mean_turnover, nestedness=mean_nestedness,
             beta_div=mean_beta, beta_ratio=mean_nestedness/mean_beta))
  }
}


#' Compute beta diversity on spatRast objects
#'
#' This function will compute beta diversity on spatRast objects
#' that contain binary (presence/absence) species distribution data
#'
#' @param x raster brick or raster stack of species presence/absence
#' @param y raster brick or raster stack of species presence/absence
#' @param numCores Number of cores to be used in parallel calculation
#' @param filetype file format expresses as GDAL driver names. If this
#' argument is not supplied, the driver is derived from the filename.
#' For details see \code{\link[terra]{writeRaster}}
#' @param overwrite Logical. Should saved files be overwritten with new values?
#' @inheritParams betapart::beta.temp
#' @inheritParams terra::app
#' @inheritParams terra::writeRaster
#' @export
beta.temp.spat <- function(x, y,
                            index.family="sorensen",
                            filetype="GTiff", filename=NULL, overwrite=T,
                            numCores=1, ...) {
  betatR <- terra::app(c(x, y), beta.temp.vec, cores=numCores)

  names(betatR) <- c("turnover", "nestedness", "beta_div", "beta_ratio")

  if(!is.null(filename)){
    betatR <- terra::writeRaster(betatR, filename = filename,
                                overwrite=overwrite, filetype=filetype, ...)
  }
  return(betatR)
}
