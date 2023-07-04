#' Alpha calculation for vector
#'
#' @param x A numeric vector with presence-absence data (0 or 1)
#' for a set of species.
#' @param tree It can be a data frame with species traits or a
#' phylogenetic tree.
#' @param resu Numeric. A vector to store results.
#' @param ... Additional arguments to be passed passed down from
#' a calling function.
#'
#' @return A vector with alpha result.
#'
spat.alpha.vec <- function(x, tree, resu, ...) {
  if (all(is.na(x))) {
    resu[] <- NA
  } else if (sum(x, na.rm = TRUE) == 0) {
    resu[] <- 0
  } else {
    x[is.na(x)] <- 0
    resu <- BAT::alpha(x, tree)
  }
  return(resu)
}

#' Alpha calculation for raster
#'
#' @description Calculates alpha diversity for taxonomic (TD),
#' functional (FD), and phylogenetic (PD) dimensions.
#' Adapted from \code{\link[BAT]{alpha}}
#'
#' @param bin A SpatRaster with presence-absence data (0 or 1) for
#' a set of species.
#' @param tree It can be a data frame with species traits or a
#' phylogenetic tree.
#' @param cores A positive integer. If cores > 1, a 'parallel'
#' package cluster with that many cores is created and used.
#' @param filename Character. Save results if a name is provided.
#' @param ... Additional arguments to be passed passed down from a
#' calling function.
#'
#' @details Alpha calculations use a tree-based approach for TD,
#' FD, and PD (Cardoso et al. 2014). In the FD calculation, a
#' species traits matrix is transformed into a distance matrix
#' and clustered to create a regional dendrogram (i.e. a
#' dendrogram with all species in the raster stack),
#' from which the total branch length is calculated. When
#' computing FD for each community (i.e. raster cell), the
#' regional dendrogram is subsetted to create a local dendrogram
#' that includes only the species present in the local community.
#' The branch lengths connecting these species are then summed to
#' represent the functional relationships of the locally present
#' species (Petchey and Gaston, 2002, 2006). Similarly, in PD,
#' the cumulative branch lengths connecting species within a
#' community indicate their shared phylogenetic relationships
#' (Faith, 1992). Alpha TD can also be visualized using a tree
#' diagram, where each species is directly connected to the root
#' by an edge of unit length, reflecting the number of different
#' taxa in the community (i.e. species richness) since all taxa
#' are at the same level (Cardoso et al. 2014).
#'
#' @references Cardoso, P. et al. 2014. Partitioning taxon,
#' phylogenetic and functional beta diversity into replacement
#' and richness difference components. - Journal of Biogeography
#' 41: 749–761.
#'
#' @references Faith, D. P. 1992. Conservation evaluation and
#' phylogenetic diversity. - Biological Conservation 61: 1–10.
#'
#' @references Petchey, O. L. and Gaston, K. J. 2002.
#' Functional diversity (FD), species richness and community
#' composition. - Ecology Letters 5: 402–411.
#'
#' @references Rodrigues, A. S. L. and Gaston, K. J. 2002.
#' Maximising phylogenetic diversity in the selection of
#' networks of conservation areas. - Biological Conservation
#' 105: 103–111.
#'
#' @return A SpatRaster with alpha result.
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' traits <- read.csv(system.file("extdata", "traits.csv",
#' package = "divraster"), row.names = 1)
#' tree <- ape::read.tree(system.file("extdata", "tree.tre",
#' package = "divraster"))
#' spat.alpha(bin1)
#' spat.alpha(bin1, traits)
#' spat.alpha(bin1, tree)
#' }
spat.alpha <- function(bin,
                       tree,
                       cores = 1,
                       filename = NULL, ...) {
  if (is.null(bin) || !inherits(bin, "SpatRaster")) {
    stop("'bin' must be a SpatRaster.")
  }
  # Check if coordinates are geographic
  if (!terra::is.lonlat(bin)) {
    stop("'bin' must has geographic coordinates.")
  }
  if (terra::nlyr(bin) < 2) {
    stop("'bin' must has at least 2 layers.")
  }
  # Create numeric vector to store result
  resu <- numeric(1)
  # Apply the function to SpatRaster object
  if (missing(tree)) {
    res <- terra::app(bin,
                      spat.alpha.vec,
                      resu = resu,
                      cores = cores, ...)
  } else {
    # Check if 'tree' object is valid
    if (!inherits(tree, c("data.frame", "phylo"))) {
      stop("'tree' must be a data.frame or a phylo object.")
    }
    res <- terra::app(bin,
                      spat.alpha.vec,
                      resu = resu,
                      cores = cores,
                      tree = tree, ...)
  }
  # Define names
  if (missing(tree)) {
    names(res) <- "Alpha_TD"
  }
  else if (inherits(tree, "data.frame")) {
    names(res) <- "Alpha_FD"
  }
  else {
    names(res) <- "Alpha_PD"
  }
  # Save the output if filename is provided
  if (!is.null(filename)) {
    terra::writeRaster(res, filename, overwrite = TRUE)
  }
  return(res)
}
