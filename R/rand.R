#' Standardize Effect Size (SES) for functional and phylogenetic
#' diversity
#'
#' @description Calculates the standardized effect size for
#' functional and phylogenetic diversity.
#' See \code{\link[SESraster]{bootspat_str}} and
#' \code{\link[SESraster]{bootspat_naive}}


#' @param x SpatRaster. A SpatRaster containing presence-absence
#' data (0 or 1) for a set of species.
#' @param tree a data.frame with species traits or a phylogenetic
#' tree.
#' @param aleats positive integer. A positive integer indicating
#' how many times the calculation should be repeated.
#' @param random character. A character indicating the type of
#' randomization. The currently available randomization methods
#' are "spat", "site", "species" or "both" (site and species).
#' @param cores positive integer. If cores > 1, a 'parallel'
#' package cluster with that many cores is created and used.
#' @param filename character. Output filename.
#' @param ... additional arguments to be passed passed down from
#' a calling function.
#'
#' @return SpatRaster with Mean, SD, Observed, and SES.
#' @export
#'
#' @examples
#' x <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' traits <- read.csv(system.file("extdata", "traits.csv",
#' package = "divraster"), row.names = 1)
#' tree <- ape::read.tree(system.file("extdata", "tree.tre",
#' package = "divraster"))
#' spat.rand(x, tree, 3, "site")
#' spat.rand(x, traits, 3, "site")
spat.rand <- function(x,
                      tree,
                      aleats,
                      random = c("site", "species", "both", "spat"),
                      cores = 1,
                      filename = NULL, ...) {
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
  # Check if random argument is valid
  if (missing(random)) {
    stop("The randomization method must be provide: 'site',
         'species', 'both', or 'spat'.")
  }
  # Check if aleats argument is valid
  if (missing(aleats)) {
    stop("The number of randomizations must be provide.")
  }
  # Check if 'tree' object is valid
  if (!inherits(tree, c("data.frame", "phylo"))) {
    stop("'tree' must be a data.frame or a phylo object.")
  }
  rand <- list() # to store the rasters in the loop
  if (random == "spat") {
    rich <- terra::app(x, sum, na.rm = TRUE)
    prob <- terra::app(x,
                       function(x) {
                         ifelse(is.na(x), 0, 1)
                       })
    fr_prob <- SESraster::fr2prob(x)
    for (i in 1:aleats) {
      ### shuffle
      pres.site.null <- SESraster::bootspat_str(x,
                                                rich = rich,
                                                prob = prob,
                                                fr_prob = fr_prob,
                                                cores = cores)
      rand[[i]] <- divraster::spat.alpha(pres.site.null,
                                         tree,
                                         cores = cores, ...)
    }
    rand <- terra::rast(rand) # to transform a list in raster
  } else if (random != "spat") {
    for (i in 1:aleats) {
      ### shuffle
      pres.site.null <- SESraster::bootspat_naive(x,
                                                  random = random,
                                                  cores = cores)
      ### calculate FD or PD based on 'tree' class
      rand[[i]] <- divraster::spat.alpha(pres.site.null,
                                         tree,
                                         cores = cores, ...)
    }
    rand <- terra::rast(rand) # to transform a list in raster
  } else {
    stop("The randomization method must be one of the following:
         'spat', 'site', 'species', 'both'.")
  }
  # rand mean
  rand.mean <- terra::mean(rand, na.rm = TRUE)
  # rand standard deviation
  rand.sd <- terra::stdev(rand, na.rm = TRUE)
  # Reorder raster layers
  if (inherits(tree, "data.frame")) {
    x.reord <- x[[rownames(tree)]]
  }
  if (inherits(tree, "phylo")) {
    x.reord <- x[[tree$tip.label]]
  }
  ### Observed values
  obs <- divraster::spat.alpha(x.reord,
                               tree,
                               cores = cores)

  ### Concatenate rasters
  rand <- c(rand.mean, rand.sd, obs)

  ## Calculating the standard effect size (SES)
  ses <- function(x) {
    (x[1] - x[2])/x[3]
  }
  ses <- terra::app(c(obs, rand.mean, rand.sd),
                    ses)
  names(ses) <- "SES"

  out <- c(rand, ses)

  # Define names
  lyrnames <- c("Mean", "SD", "Observed", "SES")
  if (inherits(tree, "data.frame")) {
    names(out) <- paste0(lyrnames, "_FD")
  } else {
    names(out) <- paste0(lyrnames, "_PD")
  }
  # to save the rasters when the path is provide
  if (!is.null(filename)) {
    out <- terra::writeRaster(out,
                              filename,
                              overwrite = TRUE, ...)
  }
  return(out)
}
