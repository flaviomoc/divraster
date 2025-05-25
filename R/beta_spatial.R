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
#' @param ... Additional arguments to be passed down from a
#' calling function.
#'
#' @return A vector with beta results (total, replacement,
#' richness difference, and ratio).
spat.beta.vec <- function(x,
                          tree,
                          global = FALSE,
                          spp,
                          nspp, ...) {
  # Convert vector to matrix
  x <- matrix(x,
              ncol = nspp,
              byrow = FALSE,
              dimnames = list(NULL, spp))

  # Remove any unwanted column like 'lyr1' if present
  if ("lyr1" %in% colnames(x)) {
    x <- x[, colnames(x) != "lyr1", drop = FALSE]
  }

  # Reorder to place the central cell first
  fcel <- ceiling(nrow(x) / 2)
  x <- x[c(fcel, setdiff(seq_len(nrow(x)), fcel)), , drop = FALSE]

  # Remove rows with NA or no presence
  x <- x[stats::complete.cases(x) & rowSums(x, na.rm = TRUE) > 0, , drop = FALSE]

  # Early exit if empty or all NA
  if (nrow(x) == 0 || all(is.na(x))) {
    return(unname(c(Btotal = NA_real_, Brepl = NA_real_, Brich = NA_real_, Bratio = NA_real_)))
  }

  # Compute beta diversity
  res <- tryCatch({
    beta_list <- BAT::beta(x, tree, abund = TRUE)

    vals <- vapply(beta_list, function(b) {
      if (global) {
        mean(b, na.rm = TRUE)
      } else {
        mean(as.matrix(b)[-1, 1], na.rm = TRUE)
      }
    }, numeric(1))

    vals["Bratio"] <- vals["Brepl"] / vals["Btotal"]
    unname(vals)
  }, error = function(e) {
    warning("Error in beta diversity calculation: ", conditionMessage(e))
    c(NA_real_, NA_real_, NA_real_, NA_real_)
  })

  return(res)
}

#' Spatial beta diversity for raster
#'
#' @description Calculates spatial beta diversity for
#' taxonomic (TD), functional (FD), and phylogenetic (PD)
#' dimensions. Adapted from \code{\link[BAT]{beta}}.
#'
#' @param x A SpatRaster with presence-absence data (0 or 1) for a
#' set of species.
#' @param tree It can be a 'data.frame' with species traits or a
#' 'phylo' with a rooted phylogenetic tree. Species names in 'tree'
#' and 'x' must match!
#' @param filename Character. Save results if a name is provided.
#' @param global Logical. Mean of pairwise comparisons between
#' focal cell and its neighbors (default) or mean of all pairwise
#' comparisons.
#' @param fm Numeric. Focal matrix ("moving window").
#' @param d Window radius to compute beta diversity.
#' @param type Character. Window format. Default = "circle".
#' @param na.policy Character. Default = "omit".
#' @param ... Additional arguments passed to lower-level functions.
#'
#' @return A SpatRaster with beta results (total, replacement,
#' richness difference, and ratio).
#' @export
spat.beta <- function(x, tree, filename = "", global = FALSE,
                      fm = NULL,
                      d = mean(terra::res(terra::rast(x))) * 2,
                      type = "circle",
                      na.policy = "omit", ...) {

  # Input validation (custom function if defined)
  if (exists("inputs_chk", mode = "function")) {
    inputs_chk(bin1 = x, tree = tree)
  }

  # Create focal matrix if missing
  if (is.null(fm)) {
    min.d <- sqrt(prod(terra::res(x)))
    if (d < min.d) {
      stop("Radius too small to build a focal window. Minimum d must be larger than: ", min.d)
    }
    fm <- terra::focalMat(x, d, type = type, fillNA = FALSE)
  }

  fm[] <- fm / fm
  fm[is.nan(fm)] <- 0

  even <- (c(dim(fm), terra::nlyr(x)) %% 2) == 0
  if (even[1]) fm <- rbind(fm, 0)
  if (even[2]) fm <- cbind(fm, 0)

  if (even[3]) {
    x <- c(x, terra::app(x, function(x) {
      ifelse(all(is.na(x)), NA, 0)
    }))
    fmA <- replicate(terra::nlyr(x), fm)
    fmA[, , terra::nlyr(x)] <- 0
  } else {
    fmA <- replicate(terra::nlyr(x), fm)
  }

  # Apply 3D focal function
  betaR <- terra::focal3D(
    x,
    fmA,
    fun = spat.beta.vec,
    tree = tree,
    global = global,
    spp = names(x),
    nspp = terra::nlyr(x),
    na.policy = na.policy,
    ...
  )

  # Check output layer count
  if (terra::nlyr(betaR) != 4) {
    stop("Unexpected number of layers returned: ", terra::nlyr(betaR), ". Expected 4.")
  }

  # Assign names
  lyrnames <- c("Btotal", "Brepl", "Brich", "Bratio")
  suffix <- if (missing(tree)) "_TD" else if (inherits(tree, "data.frame")) "_FD" else "_PD"
  names(betaR) <- paste0(lyrnames, suffix)

  # Save if requested
  if (filename != "") {
    betaR <- terra::writeRaster(betaR, filename = filename, overwrite = TRUE)
  }

  return(betaR)
}
