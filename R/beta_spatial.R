#' Spatial beta diversity for vector
#'
#' @param x A numeric vector with presence-absence data (0 or 1)
#' for a set of species.
#' @param tree It can be a data frame with species traits or a
#' phylogenetic tree.
#' @param global Logical. Mean of pairwise comparisons between
#' focal cell and its neighbors (default) or mean of all pairwise
#' comparisons.
#' @param spp Character. Species names.
#' @param nspp Numeric. Number of species.
#' @param ... Additional arguments to be passed passed down from a
#' calling function.
#'
#' @return A vector with beta results (total, replacement,
#' and richness differences).
#'
spat.beta.vec <- function(x, tree, global = FALSE, spp, nspp, ...) {
  x <- matrix(x, ncol = nspp, byrow = FALSE,
              dimnames = list(NULL, spp))
  x <- subset(x, select = colnames(x) != "lyr1")
  fcel <- ceiling(nrow(x)/2)
  x[] <- x[c(fcel, 1:(fcel - 1), (fcel + 1):nrow(x)), ]
  # maybe replace NAs with 0
  x <- x[stats::complete.cases(x) & rowSums(x, na.rm = TRUE) > 0, ]
  if (all(is.na(x))) {
    return(c(Btotal = NA, Brepl = NA, Brich = NA))
  } else if (!inherits(x, "matrix")) {
    return(c(Btotal = 0, Brepl = 0, Brich = 0))
  } else if (sum(x, na.rm = TRUE) == 0){
    return(c(Btotal = 0, Brepl = 0, Brich = 0))
  } else {
    res <- sapply(BAT::beta(x, tree, abund = TRUE),
                  function(x, global) {
                    ifelse(global,
                           # mean of all possible pairwise combinations
                           mean(x),
                           # mean of focal against all
                           mean(as.matrix(x)[-1, 1]))
                  }, global)
    return(res)
  }
}

#' Spatial beta diversity for raster
#'
#' @description Calculates spatial beta diversity for
#' taxonomic (TD), functional (FD), and phylogenetic (PD)
#' dimensions. Adapted from \code{\link[BAT]{beta}}
#'
#' @param x A SpatRaster with presence-absence data (0 or 1) for a
#' set of species.
#' @param tree A data.frame with species traits or a phylogenetic
#' tree.
#' @param filename Character. Save results if a name is provided.
#' @param global Logical. Mean of pairwise comparisons between
#' focal cell and its neighbors (default) or mean of all pairwise
#' comparisons.
#' @param fm Numeric. Focal matrix ("moving window").
#' @param d Window radius to compute beta diversity.
#' @param type Character. Window format. Default = "circle".
#' @param na.policy Character. Default = "omit".
#' See ?terra::focal3D for details.
#' @param ... Additional arguments to be passed passed down from
#' a calling function.
#'
#' @details The TD beta diversity partitioning framework we used
#' was developed by Podani and Schmera (2011) and Carvalho et al.
#' (2012) and expanded to PD and FD by Cardoso et al. (2014).
#'
#' @references Cardoso, P. et al. 2014. Partitioning taxon,
#' phylogenetic and functional beta diversity into replacement
#' and richness difference components. - Journal of Biogeography
#' 41: 749–761.
#'
#' @references Carvalho, J. C. et al. 2012. Determining the
#' relative roles of species replacement and species richness
#' differences in generating beta-diversity patterns. - Global
#' Ecology and Biogeography 21: 760–771.
#'
#' @references Podani, J. and Schmera, D. 2011. A new conceptual
#' and methodological framework for exploring and explaining
#' pattern in presence - absence data. - Oikos 120: 1625–1638.
#'
#' @return A SpatRaster with beta results (total, replacement,
#' and richness differences).
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' traits <- read.csv(system.file("extdata", "traits.csv",
#' package = "divraster"), row.names = 1)
#' rownames(traits) <- names(bin1)
#' tree <- ape::read.tree(system.file("extdata", "tree.tre",
#' package = "divraster"))
#' spat.beta(bin1)
#' spat.beta(bin1, traits)
#' spat.beta(bin1, tree)
#' }
spat.beta <- function(x, tree, filename = NULL, global = FALSE,
                      fm = NULL,
                      d = mean(terra::res(terra::rast(x)))*2,
                      type = "circle",
                      na.policy = "omit", ...) {
  # Check if x is NULL or invalid
  if (is.null(x) || !inherits(x, "SpatRaster")) {
    stop("'x' must be a SpatRaster.")
  }
  # Check if coordinates are geographic
  if (!terra::is.lonlat(x)) {
    stop("'x' must has geographic coordinates.")
  }
  if (terra::nlyr(x) < 2) {
    stop("'x' must has at least 2 layers.")
  }
  # Create focal matrix
  if (is.null(fm)) {
    min.d <- sqrt(prod(terra::res(x))) # mean(res(x)*112)
    if (d < min.d) {
      # 111.1194*res(x)[2]/(cos(y*(pi/180)))))
      stop(paste("Radius too small to build a focal window.
                 Minimum d must be larger than:", min.d))
    }
    # d = window size (if not provided create based on distance)
    fm <- terra::focalMat(x,
                          d,
                          type = type,
                          fillNA = FALSE)
  }
  # Transform values to 1 to find exact values
  fm[] <- fm/fm
  fm[is.nan(fm)] <- 0 # replace NaN by 0
  # Test even-odd dimensions in window
  # 'terra::focal3D' only works with odd dimensions
  even <- (c(dim(fm), terra::nlyr(x)) %% 2) == 0
  if (any(even)) {
    # Test if fm dims are even
    if (even[1]) {
      fm <- rbind(fm, 0)
    }
    if (even[2]) {
      fm <- cbind(fm, 0)
    }
    # Test if number of spp layers is even
    if (even[3]) {
      # Add layer to get odd dimensions
      x <- c(x, terra::app(x, function(x) {
        ifelse(all(is.na(x)), NA, 0)
      }))
      # Create array to 3D focal calculations
      fmA <- replicate(terra::nlyr(x), fm)
      # Set weight 0 for last layer
      fmA[,,terra::nlyr(x)] <- 0
    } else {
      # Create array to 3D focal calculations
      fmA <- replicate(terra::nlyr(x), fm)
    }
  } else {
    # Create array to 3D focal calculations
    fmA <- replicate(terra::nlyr(x), fm)
  }
  if (missing(tree)) {
    betaR <- terra::focal3D(x,
                            fmA,
                            spat.beta.vec,
                            global = global,
                            spp = names(x),
                            nspp = terra::nlyr(x),
                            na.policy = na.policy, ...)
  } else {
    # Check if 'tree' object is valid
    if (!inherits(tree, c("data.frame", "phylo"))) {
      stop("'tree' must be a data.frame or a phylo object.")
    }
    betaR <- terra::focal3D(x,
                            fmA,
                            spat.beta.vec,
                            tree = tree,
                            global = global,
                            spp = names(x),
                            nspp = terra::nlyr(x),
                            na.policy = na.policy, ...)
  }
  # Define names
  lyrnames <- c("Btotal", "Brepl", "Brich")
  if (missing(tree)) {
    names(betaR) <- paste0(lyrnames, "_TD")
  } else if (inherits(tree, "data.frame")) {
    names(betaR) <- paste0(lyrnames, "_FD")
  } else {
    names(betaR) <- paste0(lyrnames, "_PD")
  }
  # Save the output if filename is provided
  if (!is.null(filename)) {
    betaR <- terra::writeRaster(betaR,
                                filename,
                                overwrite = TRUE, ...)
  }
  return(betaR)
}
