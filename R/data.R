.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Welcome to divraster!")
  packageStartupMessage("To acknowledge our work use: citation('divraster')")
}
#' Load data adapted from Mota et al. (2025), Şekercioğlu et al. (2025),
#' Mota et al. (2022), Tobias et al. (2022), and Jetz et al. (2014)
#'
#' @references Mota, F. M. M. et al. 2025. Impact of Climate Change
#' on the Multiple Facets of Forest Bird Diversity in a Biodiversity
#' Hotspot Within the Atlantic Forest -
#' Diversity and Distributions 31: e70129.
#' @references Şekercioğlu, Ç. H. et al. 2025. BIRDBASE: A Global Dataset
#' of Avian Biogeography, Conservation, Ecology and Life History Traits. -
#' Scientific Data 12: 1558.
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
#' @return A list with binary maps of species for the reference
#' and future climate scenarios, species traits, a rooted
#' phylogenetic tree for the species. The species names across
#' these objects must match! It also includes a polygon of the CCAF,
#' and the protected areas of the CCAF.
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
  ccaf <- terra::vect(system.file("extdata",
                                  "ccaf.gpkg",
                                  package = "divraster"))
  pa <- terra::vect(system.file("extdata",
                                "pa_ccaf.gpkg",
                                package = "divraster"))
  return(list(ref = ref, fut = fut, traits = traits, tree = tree,
              ccaf = ccaf, pa = pa))
}
