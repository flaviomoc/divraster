#' Temporal beta diversity calculation
#'
#' It calculates beta diversity based on Jaccard dissimilarity index between reference and future scenarios
#'
#' @param ref Object of class SpatRaster with binarized distribution projected to all species from climate scenario 1
#' @param fut Object of class SpatRaster with binarized distribution projected to all species from climate scenario 2
#' @param index Metric chosen
#'
#' @return Object of class SpatRaster with the metric chosen. If "index" is missing, it return a list with all metrics (i.e., beta total, turnover, nestedness, and ratio)
#' @export
#'
#' @examples
#' \dontrun{
#' set.seed(100)
#' ref <- terra::rast(array(sample(c(rep(1, 750), rep(0, 250))), dim = c(20, 20, 10)))
#' names(ref) <- paste0("sp", 1:10)
#' ref
#' fut <- terra::rast(array(sample(c(rep(1, 300), rep(0, 700))), dim = c(20, 20, 10)))
#' names(fut) <- paste0("sp", 1:10)
#' fut
#' b <- betatempdv(ref, fut, "beta")
#' b
#' }
betatempdv <- function(ref, fut, index){
  total <- ref + fut # total number of species
  a <- sum(total == 2) # species in both scenarios simultaneously
  b <- sum(ref > fut, 1, 0) # species in reference scenario only
  c <- sum(fut > ref, 1, 0) # species in future scenario only
  if(missing(index) == "TRUE"){
    res <- list()
    res[1] <- (b + c) / (a + b + c) # beta
    res[2] <- (2 * min(b, c)) / (a + (2 * min(b, c))) # turn
    res[3] <- ((b + c) / (a + b + c)) - ((2 * min(b, c)) / (a + (2 * min(b, c)))) # nest
    res[4] <- ((2 * min(b, c)) / (a + (2 * min(b, c)))) / ((b + c) / (a + b + c))
    names(res) <- c("Beta total", "Beta turnover", "Beta nestedness", "Beta ratio")
    return(res)
  } else if(index == "beta"){
    res <- (b + c) / (a + b + c) # beta diversity calculation (Jaccard dissimilarity index)
    names(res) <- "Beta total"
    return(res)
  } else if(index == "turn"){
    res <- (2 * min(b, c)) / (a + (2 * min(b, c)))
    names(res) <- "Beta turnover"
    return(res)
  } else if(index == "nest"){
    Beta <- (b + c) / (a + b + c)
    Bturn <- (2 * min(b, c)) / (a + (2 * min(b, c)))
    res <- Beta - Bturn
    names(res) <- "Beta nestedness"
    return(res)
  } else if(index == "ratio"){
    Beta <- (b + c) / (a + b + c)
    Bturn <- (2 * min(b, c)) / (a + (2 * min(b, c)))
    res <- Bturn / Beta
    names(res) <- "Beta ratio"
    return(res)
  }
}
