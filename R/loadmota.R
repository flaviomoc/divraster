#' Load data from Mota et al. 2022
#'
#' Available at <https://doi.org/10.1111/ddi.13602>
#'
#' @return List with climate scenarios and suitable area of reference climate scenario by species
#' @export
#'
#' @examples
#' data <- loadmota()
#' data
loadmota <- function(){
  ref <- terra::rast(system.file("extdata", "ref_Mota.tif", package = "DMSD"))
  fut <- terra::rast(system.file("extdata", "fut_Mota.tif", package = "DMSD"))
  area <- utils::read.csv(system.file("extdata", "area_Mota.csv", package = "DMSD"), sep = ";")
  return(list(ref = ref, fut = fut, area = area))
}
