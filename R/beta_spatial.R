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
spat.beta.vec <- function(x,
                          tree,
                          global = FALSE,
                          spp,
                          nspp, ...) {
  # Convert 'x' to a matrix with specified species names and remove
  # the 'lyr1' column
  x <- matrix(x,
              ncol = nspp,
              byrow = FALSE,
              dimnames = list(NULL, spp))
  x <- subset(x,
              select = colnames(x) != "lyr1")

  # Reorder the rows of 'x', placing the middle row at the first
  # position
  fcel <- ceiling(nrow(x) / 2)
  x[] <- x[c(fcel, 1:(fcel - 1), (fcel + 1):nrow(x)), ]

  # Remove rows with any NA values and rows with all zeros
  # (no presence)
  x <- x[stats::complete.cases(x) & rowSums(x, na.rm = TRUE) > 0, ]

  # Check if 'x' contains only NA values and return NA values for
  # all beta diversity components
  if (all(is.na(x))) {
    return(c(Btotal = NA, Brepl = NA, Brich = NA, Bratio = NA))
  }
  # Check if 'x' is not a matrix and return zero values for all beta
  # diversity components
  else if (!inherits(x, "matrix")) {
    return(c(Btotal = 0, Brepl = 0, Brich = 0, Bratio = 0))
  }
  # Check if 'x' contains all zeros (no presence) and return zero
  # values for all beta diversity components
  else if (sum(x, na.rm = TRUE) == 0) {
    return(c(Btotal = 0, Brepl = 0, Brich = 0, Bratio = 0))
  }
  # Calculate beta diversity using BAT::beta function and return
  # the result
  else {
    res <- sapply(BAT::beta(x, tree, abund = TRUE),
                  function(x, global) {
                    ifelse(global,
                           # Calculate mean of all possible
                           # pairwise combinations
                           mean(x),
                           # Calculate mean of focal against all
                           mean(as.matrix(x)[-1, 1]))
                  }, global)
    # Calculate beta ratio (Brepl / Btotal) and store it
    res[4] <- res[2] / res[1] # See Hidasi-Neto et al. (2019)
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
#' @references Hidasi-Neto, J. et al. 2019. Climate change will
#' drive mammal species loss and biotic homogenization in the
#' Cerrado Biodiversity Hotspot. - Perspectives in Ecology and
#' Conservation 17: 57–63.
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
spat.beta <- function(x, tree, filename = "", global = FALSE,
                      fm = NULL,
                      d = mean(terra::res(terra::rast(x))) * 2,
                      type = "circle",
                      na.policy = "omit", ...) {

  # Check if 'x' is NULL or invalid (not a SpatRaster)
  if (is.null(x) || !inherits(x, "SpatRaster")) {
    stop("'x' must be a SpatRaster.")
  }

  # Check if coordinates are geographic
  if (!terra::is.lonlat(x)) {
    stop("'x' must have geographic coordinates.")
  }

  # Check if 'x' has at least 2 layers
  if (terra::nlyr(x) < 2) {
    stop("'x' must have at least 2 layers.")
  }

  # Create focal matrix
  if (is.null(fm)) {
    # Calculate the minimum distance for the focal matrix
    min.d <- sqrt(prod(terra::res(x)))

    # Check if 'd' is smaller than the minimum distance required
    # for the focal matrix
    if (d < min.d) {
      stop(paste("Radius too small to build a focal window.
                 Minimum d must be larger than:", min.d))
    }

    # Generate the focal matrix based on 'd', 'type', and the
    # SpatRaster 'x'
    fm <- terra::focalMat(x, d, type = type, fillNA = FALSE)
  }

  # Transform values to 1 to find exact values in the focal matrix
  fm[] <- fm / fm
  fm[is.nan(fm)] <- 0  # Replace NaN by 0

  # Test even-odd dimensions in the focal matrix
  even <- (c(dim(fm), terra::nlyr(x)) %% 2) == 0
  if (any(even)) {
    # Test if focal matrix dimensions are even
    if (even[1]) {
      fm <- rbind(fm, 0)
    }
    if (even[2]) {
      fm <- cbind(fm, 0)
    }

    # Test if number of spp layers is even
    if (even[3]) {
      # Add a layer to get odd dimensions (to enable 'terra::focal3D')
      x <- c(x, terra::app(x, function(x) {
        ifelse(all(is.na(x)), NA, 0)
      }))
      # Create an array for 3D focal calculations
      fmA <- replicate(terra::nlyr(x), fm)
      # Set weight 0 for the last layer to exclude it from calculations
      fmA[, , terra::nlyr(x)] <- 0
    } else {
      # Create an array for 3D focal calculations
      fmA <- replicate(terra::nlyr(x), fm)
    }
  } else {
    # Create an array for 3D focal calculations
    fmA <- replicate(terra::nlyr(x), fm)
  }

  # Apply focal3D calculation using spat.beta.vec function
  if (missing(tree)) {
    betaR <- terra::focal3D(x,
                            fmA,
                            spat.beta.vec,
                            global = global,
                            spp = names(x),
                            nspp = terra::nlyr(x),
                            na.policy = na.policy, ...)
  } else {
    # Check if 'tree' object is valid (either a data.frame
    # or a phylo object)
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

  # Define names for the output based on the type of 'tree'
  lyrnames <- c("Btotal", "Brepl", "Brich", "Bratio")
  if (missing(tree)) {
    names(betaR) <- paste0(lyrnames, "_TD")
  } else if (inherits(tree, "data.frame")) {
    names(betaR) <- paste0(lyrnames, "_FD")
  } else {
    names(betaR) <- paste0(lyrnames, "_PD")
  }

  # Save the output if 'filename' is provided
  if (filename != "") {
    terra::writeRaster(betaR,
                       filename = filename,
                       overwrite = TRUE, ...)
  }
  # Return the SpatRaster with beta diversity values
  return(betaR)
}
