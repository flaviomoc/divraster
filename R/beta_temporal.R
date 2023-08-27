#' Temporal beta diversity calculation for vector
#'
#' @param x A numeric vector with presence-absence data (0 or 1)
#' for a set of species.
#' @param nspp Numeric. Number of species.
#' @param spp Character. Species name.
#' @param tree It can be a data frame with species traits or a
#' phylogenetic tree.
#' @param resu Numeric. A vector to store results.
#' @param ... Additional arguments to be passed passed down from
#' a calling function.
#'
#' @return A vector with beta results (total, replacement,
#' richness difference, and ratio).
#'
temp.beta.vec <- function(x, nspp, spp, tree, resu, ...) {
  # Check if 'x' contains only NA values and return NA values for
  # the result vector
  if (all(is.na(x))) {
    resu[] <- NA
  }
  # Check if 'x' contains all zeros (no presence) and return zero
  # values for the result vector
  else if (sum(x, na.rm = TRUE) == 0) {
    resu[] <- 0
  }
  else {
    # Replace NA values in 'x' with 0
    x[is.na(x)] <- 0
    # Create a new matrix by stacking 'x' on top of itself to compare
    # two time points (before and after treatment)
    x <- rbind(x[1:nspp], x[nspp + (1:nspp)])
    colnames(x) <- spp  # Set column names using species names
    # Calculate beta diversity using BAT::beta function with
    # 'abund = FALSE' and store the result in 'resu'
    resu[] <- unlist(BAT::beta(x, tree, abund = FALSE))
    # Calculate beta ratio (Brepl / Btotal) and store it
    resu[4] <- resu[2] / resu[1] # See Hidasi-Neto et al. (2019)
  }
  return(resu)  # Return the result vector 'resu'
}

#' Temporal beta diversity calculation for raster
#'
#' @description Calculates temporal beta diversity for
#' taxonomic (TD), functional (FD), and phylogenetic (PD)
#' dimensions. Adapted from \code{\link[BAT]{beta}}
#'
#' @param bin1 A SpatRaster with presence-absence data (0 or 1)
#' for a set of species.
#' @param bin2 A SpatRaster with presence-absence data (0 or 1)
#' for a set of species.
#' @param tree It can be a data frame with species traits or a
#' phylogenetic tree.
#' @param filename Character. Save results if a name is provided.
#' @param cores A positive integer. If cores > 1, a 'parallel'
#' package cluster with that many cores is created and used.
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
#' richness difference, and ratio).
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' bin2 <- terra::rast(system.file("extdata", "fut.tif",
#' package = "divraster"))
#' traits <- read.csv(system.file("extdata", "traits.csv",
#' package = "divraster"), row.names = 1)
#' tree <- ape::read.tree(system.file("extdata", "tree.tre",
#' package = "divraster"))
#' temp.beta(bin1, bin2)
#' temp.beta(bin1, bin2, traits)
#' temp.beta(bin1, bin2, tree)
#' }
temp.beta <- function(bin1,
                      bin2,
                      tree,
                      filename = "",
                      cores = 1, ...) {
  # Check if 'bin1' and 'bin2' are NULL or invalid (not SpatRaster)
  if (is.null(bin1) || !inherits(bin1, "SpatRaster")) {
    stop("'bin1' must be a SpatRaster.")
  }
  if (is.null(bin2) || !inherits(bin2, "SpatRaster")) {
    stop("'bin2' must be a SpatRaster.")
  }

  # Check if coordinates of both rasters are geographic
  if (!terra::is.lonlat(bin1) | !terra::is.lonlat(bin2)) {
    stop("Both rasters must have geographic coordinates.")
  }

  # Check if both rasters have at least 2 layers
  if (terra::nlyr(bin1) < 2 | terra::nlyr(bin2) < 2) {
    stop("Both rasters must have at least 2 layers.")
  }

  # Check if the names of bin1 and bin2 match
  if (!identical(names(bin1), names(bin2))) {
    stop("The names of the rasters do not match.")
  }

  # Get number of species
  nspp <- terra::nlyr(bin1)

  # Get species names
  spp <- names(bin1)

  # Create a numeric vector to store results for Btotal, Brepl,
  # Brich,and Bratio
  resu <- numeric(4)

  # Apply the function to the SpatRaster objects 'bin1' and 'bin2'
  if (missing(tree)) {
    res <- terra::app(c(bin1, bin2),
                      temp.beta.vec,
                      resu = resu,
                      nspp = nspp,
                      spp = spp,
                      cores = cores, ...)
  } else {
    # Check if 'tree' object is valid (either a data.frame or a
    # phylo object)
    if (!inherits(tree, c("data.frame", "phylo"))) {
      stop("'tree' must be a data.frame or a phylo object.")
    }
    res <- terra::app(c(bin1, bin2),
                      temp.beta.vec,
                      resu = resu,
                      tree = tree,
                      nspp = nspp,
                      spp = spp,
                      cores = cores, ...)
  }

  # Define names for the output based on the type of 'tree'
  lyrnames <- c("Btotal", "Brepl", "Brich", "Bratio")
  if (missing(tree)) {
    names(res) <- paste0(lyrnames, "_TD")
  } else if (inherits(tree, "data.frame")) {
    names(res) <- paste0(lyrnames, "_FD")
  } else {
    names(res) <- paste0(lyrnames, "_PD")
  }

  # Save the output to a file if 'filename' is provided
  if (filename != "") {
    terra::writeRaster(res,
                       filename = filename,
                       overwrite = TRUE, ...)
  }

  # Return beta diversity values
  return(res)
}
