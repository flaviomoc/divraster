#' Calculate average trait generalization
#'
#' @param bin Object of class SpatRaster with binarized distribution projected to all species from climate scenario 1
#' @param tab Table with species as rows and traits as columns
#' @param trait The default parameter of the argument is "one" that calculates ecological generalization to a single trait in the first column of the tab object. Alternatively, the parameter can be set to "all" that calculates ecological generalization to all traits at once
#'
#' @return Object of class SpatRaster with average trait chosen. If trait = "all", it return a list with all traits
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 750), rep(0, 250))), dim = c(20, 20, 10)))
#' names(ref) <- paste0("sp", 1:10)
#'
#' set.seed(100)
#' mass <- runif(10, 10, 800) # grams
#' beaksize <- runif(10, 5, 30) # millimeters
#' sp <- paste0("sp", 1:10)
#' traits <- as.data.frame(cbind(sp, mass, beaksize))
#' t1 <- ecogen(ref, traits, "one")
#' t1
#' t2 <- ecogen(ref, traits, "all")
#' t2
#' }
ecogen <- function(bin, tab, trait = "one"){
  tab <- as.data.frame(tab)
  tab <- tab[-1]
  if(trait == "one"){
    t <- as.numeric(tab[ , 1])
    bin[bin == 0] <- NA
    gen <- bin * t
    res <- terra::app(gen, mean, na.rm = TRUE)
    names(res) <- names(tab[1])
  } else if(trait == "all"){
    res <- list()
    for(i in seq_along(tab)){
      t <- as.numeric(tab[ , i])
      bin[bin == 0] <- NA
      gen <- bin * t
      r <- terra::app(gen, mean, na.rm = TRUE)
      names(r) <- names(tab[i])
      res[i] <- r
    }
    names(res) <- names(tab)
  }
  return(res)
}
