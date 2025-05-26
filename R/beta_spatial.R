#' Spatial beta diversity for raster
#'
#' @description Calculates spatial beta diversity for
#' taxonomic (TD), functional (FD), and phylogenetic (PD)
#' dimensions. See \code{\link[BAT]{raster.beta}}.
#'
#' @param x A SpatRaster with presence-absence data (0 or 1) for a
#' set of species. (This maps to `layers` in `BAT::raster.beta`).
#' @param tree It can be a 'data.frame' with species traits or a
#' 'phylo' with a rooted phylogenetic tree. Species names in 'tree'
#' and 'x' must match!
#' @param filename Character. Save results if a name is provided.
#' @param func Character. Distance function for beta diversity calculation.
#'             Defaults to "jaccard". Passed to `BAT::beta`.
#' @param abund Logical. Whether to use abundance data (TRUE) or presence-absence (FALSE).
#'             Defaults to FALSE. Passed to `BAT::beta`.
#' @param ... Additional arguments to be passed to internal functions
#'            within `BAT::raster.beta` (e.g., `BAT::beta`).
#'            Note: `BAT::raster.beta` does not accept a 'neighbour' argument.
#'
#' @return A SpatRaster with beta results (total, replacement,
#' richness difference, and ratio).
#' @export
#'
#' @examples
#' \donttest{
#' library(terra)
#' bin1 <- terra::rast(system.file("extdata", "fut.tif",
#' package = "divraster"))
#' traits <- read.csv(system.file("extdata", "traits.csv",
#' package = "divraster"), row.names = 1)
#' tree <- ape::read.tree(system.file("extdata", "tree.tre",
#' package = "divraster"))
#' spat.beta(bin1)
#' spat.beta(bin1, traits)
#' spat.beta(bin1, tree)
#' }
spat.beta <- function(x, tree, filename = "",
                      func = "jaccard",
                      abund = FALSE,
                      ...) {

  # Input validation (assuming 'inputs_chk' is defined elsewhere in your package)
  if (exists("inputs_chk", mode = "function")) {
    inputs_chk(bin1 = x, tree = tree)
  }

  # Call BAT::raster.beta directly.
  # Removed 'neighbour' from the arguments passed to BAT::raster.beta
  betaR <- BAT::raster.beta(layers = x,
                            tree = tree,
                            func = func,
                            abund = abund,
                            ...) # Pass any other arguments to BAT::raster.beta

  # Calculate the Bratio layer
  Btotal_layer <- betaR[["Btotal"]]
  Brepl_layer <- betaR[["Brepl"]]

  if (is.null(Btotal_layer) || is.null(Brepl_layer)) {
    stop("Could not find 'Btotal' or 'Brepl' layers in the output from BAT::raster.beta.
            Please check BAT::raster.beta documentation or source code for layer names.")
  }

  Bratio_layer <- Brepl_layer / Btotal_layer
  names(Bratio_layer) <- "Bratio"

  # Combine the original layers with the new Bratio layer
  final_betaR <- c(betaR, Bratio_layer)

  # Assign the final names with the correct suffix
  lyrnames <- c("Btotal", "Brepl", "Brich", "Bratio")
  suffix <- if (missing(tree)) "_TD" else if (inherits(tree, "data.frame")) "_FD" else "_PD"
  names(final_betaR) <- paste0(lyrnames, suffix)

  # Save if requested
  if (filename != "") {
    terra::writeRaster(final_betaR, filename = filename, overwrite = TRUE)
  }

  return(final_betaR)
}
