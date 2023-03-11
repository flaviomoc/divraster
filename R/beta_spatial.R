#' Compute beta diversity on vectors
#'
#' This function will compute beta diversity on vectors containing
#' multiple species at multiple sites. Species at sites should be
#' placed sequentially, so that the vector can be transformed in a
#' matrix with species at columns and sites at rows
#' @param x numeric vector with multiple species and multiple sites
#' @param tree a data.frame with species traits or a phylogenetic tree
#' @param global default = FALSE to compare dissimilarity between focal cell and its neighboring cells
#' @param func dissimilarity index. default = jaccard
#' @param spp species names
#' @param nspp numeric. number of species to transform the vector
#' into a matrix with nspp columns#'
#' @return spatraster object
spat.beta.vec <- function(x, tree, global = FALSE, func = "jac", spp, nspp){
  x <- matrix(x, ncol = nspp, byrow = F, dimnames = list(NULL, spp))
  x <- subset(x, select = colnames(x) != "lyr1")
  fcel <- ceiling(nrow(x)/2)
  x[] <- x[c(fcel, 1:(fcel - 1), (fcel + 1):nrow(x)), ]
  x <- x[stats::complete.cases(x) & rowSums(x, na.rm = T) > 0, ] # maybe replace NAs with 0
  if(all(is.na(x))) {
    return(c(Btotal = NA, Brepl = NA, Brich = NA))
  } else if(!inherits(x, "matrix")) {
    return(c(Btotal = 0, Brepl = 0, Brich = 0))
  } else if(sum(x, na.rm = T) == 0) {
    return(c(Btotal = 0, Brepl = 0, Brich = 0))
  } else {
    res <- sapply(BAT::beta(x, tree, func = func, abund = FALSE),
                  function(x, global) {
                    ifelse(global,
                           mean(x),
                           mean(as.matrix(x)[-1, 1])) #DESCREVER (FOCAL VS VIZINHOS)
                  }, global)
    return(res)
  }
}

#' Compute beta diversity on spatRast objects
#'
#' This function will compute beta diversity on spatRast objects
#' that contain binary (presence/absence) species distribution data
#'
#' @param x raster brick or raster stack of species presence/absence
#' @param tree a data.frame with species traits or a phylogenetic tree
#' @param global default = FALSE to compare dissimilarity between focal cell and its neighboring cells
#' @param func dissiminarity index. default = jaccard
#' @param fm focal matrix. Numeric. Make a focal ("moving window")
#' @param d window radius to compute beta diversity metrics
#' @param type window format
#' @param filetype file format expresses as GDAL driver names. If this
#' argument is not supplied, the driver is derived from the filename.
#' @param overwrite Logical. Should saved files be overwritten with new values?
#' @param na.policy default = omit
#' @param ... additional arguments
#' @param filename character save output if a filename is provided
#'
#' @return spatraster object
#' @export
#'
#' @examples
#' \dontrun{
#' library(terra)
#' library(ape)
#' set.seed(100)
#' bin1 <- terra::rast(ncol = 5, nrow = 5, nlyr = 10)
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
#' tree <- ape::rtree(n = 10, tip.label = paste0("sp", 1:10))
#' spat.beta(bin1)
#' spat.beta(bin1, traits)
#' spat.beta(bin1, tree)
#' }
spat.beta <- function(x, tree, global = FALSE, func = "jac",
                      fm = NULL,
                      d = mean(terra::res(terra::rast(x)))*2, #MENOR JANELA MAIOR DIFERENÇA
                      type = "circle", #2X PIXEL
                      filetype = "GTiff", #CONFERIR
                      filename = NULL,
                      overwrite = TRUE,
                      na.policy = "omit", ...) {
  if(!inherits(x, c("SpatRaster"))) {
    x <- terra::rast(x) #ADICIONAR NAS OUTRAS FUNÇÕES (ACEITAR APENAS RASTER - ERRO)
  }

  if(is.null(fm)) {
    min.d <- sqrt(prod(terra::res(x))) #mean(res(x)*112)
    if(d < min.d) {
      stop(paste("radius too small to build a focal window.
                 Minimum d should be larger than:", min.d)) #111.1194*res(x)[2]/(cos(y*(pi/180)))))
    }
    fm <- terra::focalMat(x,
                          d, #TAMANHO DA JANELA (SE NÃO DER, CRIAR BASEADO EM DISTÂNCIA)
                          type = type,
                          fillNA = FALSE)
  }
  # transformar tudo em 1 para encontrar valores exatos
  fm[] <- fm/fm
  fm[is.nan(fm)] <- 0 #SUBSTITUI NaN por 0
  ## test even-odd dimensions in window
  # 'terra::focal3D' only works with odd dimensions
  even <- (c(dim(fm), terra::nlyr(x)) %% 2) == 0
  if(any(even)) {
    # test if fm dims are even
    if(even[1]) {
      fm <- rbind(fm, 0)
    }
    if(even[2]) {
      fm <- cbind(fm, 0)
    }
    # test if number of spp layers is even
    if(even[3]) {
      # add layer to get odd dimensions
      x <- c(x, terra::app(x, function(x) {
        ifelse(all(is.na(x)), NA, 0)
      })) ##############################
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
  if (missing(tree)) {
    betaR <- terra::focal3D(x,
                            fmA,
                            spat.beta.vec,
                            global = global,
                            func = func,
                            spp = names(x),
                            nspp = terra::nlyr(x), # nspp=nspp
                            na.policy = na.policy, ...)#[[1:4]] #PRADRONIZAR ORDEM ARGUMENTOS
  } else {
    betaR <- terra::focal3D(x,
                            fmA,
                            spat.beta.vec,
                            tree = tree,
                            global = global,
                            func = func,
                            spp = names(x),
                            nspp = terra::nlyr(x), # nspp=nspp
                            na.policy = na.policy, ...)#[[1:4]]
  }
  # Define names
  lyrnames <- c("Beta total", "Beta turn", "Beta nest")
  if (missing(tree)) {
    names(betaR) <- paste0(lyrnames, ".TD")
  } else if (inherits(tree, "data.frame")) {
    names(betaR) <- paste0(lyrnames, ".FD")
  } else {
    names(betaR) <- paste0(lyrnames, ".PD")
  }
  if(!is.null(filename)) {
    betaR <- terra::writeRaster(betaR,
                                filename = filename,
                                overwrite = overwrite,
                                filetype = filetype, ...)
  }
  return(betaR)
}
