#' Spatial beta diversity for raster
#'
#' @description Calculates spatial beta diversity for
#' taxonomic (TD), functional (FD), and phylogenetic (PD)
#' dimensions. Adapted from \code{\link[BAT]{beta}}.
#'
#' @param x A SpatRaster with presence-absence data (0 or 1) for a
#' set of species. (This maps to `layers` in `BAT::raster.beta`).
#' @param tree It can be a 'data.frame' with species traits or a
#' 'phylo' with a rooted phylogenetic tree. Species names in 'tree'
#' and 'x' must match!
#' @param filename Character. Save results if a name is provided.
#' @param func Character. Distance function for beta diversity calculation.
#'             Defaults to "jaccard". Passed to `BAT::beta`.
#' @param neighbour Numeric. Number of neighbours to consider (e.g., 4 or 8).
#'                  Defaults to 8. Passed to `BAT::raster.beta`.
#' @param abund Logical. Whether to use abundance data (TRUE) or presence-absence (FALSE).
#'             Defaults to FALSE. Passed to `BAT::beta`.
#' @param ... Additional arguments to be passed to internal functions
#'            within `BAT::raster.beta` (e.g., `BAT::beta`).
#'
#' @return A SpatRaster with beta results (total, replacement,
#' richness difference, and ratio).
#' @export
spat.beta <- function(x, tree, filename = "",
                      func = "jaccard", # Directly expose these arguments
                      neighbour = 8,
                      abund = FALSE,
                      ...) {

  # Input validation (assuming 'inputs_chk' is defined elsewhere in your package)
  # This function should ensure 'x' is a SpatRaster, 'tree' is appropriate, etc.
  if (exists("inputs_chk", mode = "function")) {
    inputs_chk(bin1 = x, tree = tree)
  }

  # Call BAT::raster.beta directly.
  # Map 'x' from spat.beta to 'layers' in BAT::raster.beta
  betaR_from_BAT <- BAT::raster.beta(layers = x,
                                     tree = tree,
                                     func = func,
                                     neighbour = neighbour,
                                     abund = abund,
                                     ...) # Pass any other arguments to BAT::raster.beta

  # BAT::raster.beta returns a SpatRaster with 3 layers named "Btotal", "Brepl", "Brich"
  # Confirming this structure is essential for the next steps.
  # The code snippet you provided shows:
  # names(res) = c("Btotal", "Brepl", "Brich")
  # So, we expect 3 layers with these specific names.

  if (!inherits(betaR_from_BAT, "SpatRaster") || terra::nlyr(betaR_from_BAT) != 3) {
    stop("BAT::raster.beta did not return an expected 3-layer SpatRaster.")
  }

  # Calculate the Bratio layer
  # Ensure we use the named layers to be robust against potential order changes,
  # though the provided BAT code implies a fixed order.
  Btotal_layer <- betaR_from_BAT[["Btotal"]]
  Brepl_layer <- betaR_from_BAT[["Brepl"]]

  if (is.null(Btotal_layer) || is.null(Brepl_layer)) {
    stop("Could not find 'Btotal' or 'Brepl' layers in the output from BAT::raster.beta.
            Please check BAT::raster.beta documentation or source code for layer names.")
  }

  Bratio_layer <- Brepl_layer / Btotal_layer
  names(Bratio_layer) <- "Bratio" # Name the new layer

  # Combine the original layers with the new Bratio layer
  # Ensure the original names from BAT::raster.beta are preserved first.
  final_betaR <- c(betaR_from_BAT, Bratio_layer)

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
