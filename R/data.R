.onAttach <- function(libname, pkgname) {
packageStartupMessage("Thank you for using divraster!")
packageStartupMessage("To acknowledge our work, please cite the package:")
packageStartupMessage(paste0("Mota, F. M. M., Heming, N. M., and Alves-Ferreira, G. (2023). divraster: Diversity Metrics Calculations for Rasterized Data. R package version 1.0.2. https://cran.r-project.org/package=divraster"))
}
#' Load data adapted from Mota et al. (2022), Tobias et al. (2022),
#'  and Jetz et al. (2014)
#'
#' @references Mota, F. M. M. et al. 2022. Climate change is
#' expected to restructure forest frugivorous bird communities in
#' a biodiversity hot-point within the Atlantic Forest. -
#' Diversity and Distributions 28: 2886–2897.
#' @references Tobias, J. A. et al. 2022. AVONET: morphological,
#' ecological and geographical data for all birds. -
#' Ecology Letters 25: 581–597.
#' @references Jetz, W. et al. 2014. Global Distribution and
#' Conservation of Evolutionary Distinctness in Birds. -
#' Current Biology 24: 919–930.
#'
#' @return List with climate scenarios, traits, and phylogenetic
#' tree
#' @export
#'
#' @examples
#' data <- load.data()
#' data
load.data <- function() {
  ref <- terra::rast(system.file("extdata",
                                 "ref_frugivor.tif",
                                 package = "divraster"))
  fut <- terra::rast(system.file("extdata",
                                 "fut_frugivor.tif",
                                 package = "divraster"))
  traits <- utils::read.csv(system.file("extdata",
                                        "traits_frugivor.csv",
                                        package = "divraster"),
                            sep = ";", row.names = 1)
  tree <- ape::read.tree(system.file("extdata",
                                     "tree_frugivor.tre",
                                     package = "divraster"))
  return(list(ref = ref, fut = fut, traits = traits, tree = tree))
}
