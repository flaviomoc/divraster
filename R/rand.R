#' Standardized Effect Size (SES) for raster
#'
#' @description Calculates the standardized effect size for
#' functional and phylogenetic alpha diversity.
#' See \code{\link[SESraster]{bootspat_str}} and
#' \code{\link[SESraster]{bootspat_naive}}
#'
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
#' \donttest{
#' x <- terra::rast(system.file("extdata", "ref.tif",
#' package = "divraster"))
#' traits <- read.csv(system.file("extdata", "traits.csv",
#' package = "divraster"), row.names = 1)
#' tree <- ape::read.tree(system.file("extdata", "tree.tre",
#' package = "divraster"))
#' spat.rand(x, tree, 3, "site")
#' spat.rand(x, traits, 3, "site")
#' }
spat.rand <- function(x,
                      tree,
                      aleats,
                      random = c("site", "species", "both", "spat"),
                      cores = 1,
                      filename = "", ...) {

  # Initial tests
  inputs_chk(bin1 = x, tree = tree)

  # Check if the 'random' argument is valid
  if (missing(random) || !(random %in% c("site", "species",
                                         "both", "spat"))) {
    stop("The randomization method must be provided: 'site',
         'species', 'both', or 'spat'.")
  }

  # Check if the 'aleats' argument is valid
  if (missing(aleats)) {
    stop("The number of randomizations must be provided.")
  }

  rand <- list()  # to store the rasters in the loop

  # Perform randomization analysis based on the chosen method
  if (random == "spat") {
    # Calculate the richness of each cell
    rich <- terra::app(x, sum, na.rm = TRUE)
    # Create a binary raster indicating presence/absence
    prob <- terra::app(x, function(x) {
      ifelse(is.na(x), 0, 1)
    })
    # Convert the binary raster to probability using the
    # SESraster package
    fr_prob <- SESraster::fr2prob(x)
    for (i in 1:aleats) {
      # Shuffle the data using 'bootspat_str' method from
      # SESraster package
      pres.site.null <- SESraster::bootspat_str(x,
                                                rich = rich,
                                                prob = prob,
                                                fr_prob = fr_prob,
                                                cores = cores)
      # Calculate alpha diversity (spat.alpha) for the
      # shuffled data
      rand[[i]] <- divraster::spat.alpha(pres.site.null,
                                         tree,
                                         cores = cores, ...)
    }
    # Convert the list to a raster object
    rand <- terra::rast(rand)
  } else if (random != "spat") {
    for (i in 1:aleats) {
      # Shuffle the data using 'bootspat_naive' method from
      # SESraster package
      pres.site.null <- SESraster::bootspat_naive(x,
                                                  random = random,
                                                  cores = cores)
      # Calculate alpha diversity (spat.alpha) for the
      # shuffled data
      rand[[i]] <- divraster::spat.alpha(pres.site.null,
                                         tree,
                                         cores = cores, ...)
    }
    # Convert the list to a raster object
    rand <- terra::rast(rand)
  } else {
    stop("The randomization method must be one of the
         following: 'spat', 'site', 'species', 'both'.")
  }

  # Calculate mean and standard deviation of the randomized
  # alpha diversity
  rand.mean <- terra::mean(rand, na.rm = TRUE)
  rand.sd <- terra::stdev(rand, na.rm = TRUE)

  # Reorder raster layers based on the 'tree' class
  # (data.frame or phylo)
  if (inherits(tree, "data.frame")) {
    x.reord <- x[[rownames(tree)]]
  }
  if (inherits(tree, "phylo")) {
    x.reord <- x[[tree$tip.label]]
  }

  # Calculate observed alpha diversity (spat.alpha) for the
  # original data
  obs <- divraster::spat.alpha(x.reord, tree, cores = cores)

  # Concatenate rasters (observed alpha diversity, mean of
  # randozimation, and standard deviation of randomization)
  rand <- c(rand.mean, rand.sd, obs)

  # Calculate the Standardized Effect Size (SES)
  ses <- function(x) {
    (x[1] - x[2]) / x[3]
  }
  ses <- terra::app(c(obs, rand.mean, rand.sd), ses)
  names(ses) <- "SES"

  # Combine the results into a single SpatRaster
  out <- c(rand, ses)

  # Define names for the output based on the type of 'tree'
  lyrnames <- c("Mean", "SD", "Observed", "SES")
  if (inherits(tree, "data.frame")) {
    names(out) <- paste0(lyrnames, "_FD")
  } else {
    names(out) <- paste0(lyrnames, "_PD")
  }

  # Save the output if 'filename' is provided
  if (filename != "") {
    terra::writeRaster(out,
                       filename = filename,
                       overwrite = TRUE, ...)
  }

  # Return a SpatRaster with alpha and SES results
  return(out)
}
