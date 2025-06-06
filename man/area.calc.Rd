% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/range_size.R
\name{area.calc}
\alias{area.calc}
\title{Calculate SpatRaster Layer Areas and Overlap Areas}
\usage{
area.calc(x, y = NULL, z = NULL, filename = "", unit = "km", cellsize = NULL)
}
\arguments{
\item{x}{A \code{SpatRaster} object for which the area of each layer will be calculated.
This \code{SpatRaster} can have one or multiple layers.}

\item{y}{An optional \code{SpatRaster} object with a \strong{single layer}. If provided,
the overlapping area between each layer in \code{x} and this \code{y} raster will be calculated.
It should have the same extent and resolution as \code{x}.}

\item{z}{An optional \code{SpatRaster} object with a \strong{single layer}. If provided,
the overlapping area between each layer in \code{x} and this \code{z} raster,
as well as the three-way overlap (\code{x}, \code{y}, and \code{z}), will be calculated.
Requires \code{y} to also be provided. It should have the same extent and resolution as \code{x}.}

\item{filename}{Character string. If provided (e.g., "results.csv"), the resulting
data frame will be saved to a CSV file with this name. If not provided,
results are returned only to the R session.}

\item{unit}{Character string specifying the unit of measurement for area calculations.
Defaults to "km" (kilometers). Other options include "ha" (hectares), "m" (meters), etc.}

\item{cellsize}{Numeric. An optional value specifying the cell size (area of a single cell)
to be used for calculations. If \code{NULL} (default), the function will
automatically determine the cell size from the input raster \code{x}.}
}
\value{
A \code{data.frame} with the following columns:
\itemize{
\item \strong{Layer}: Name of each layer from the input \verb{SpatRaster x}.
\item \strong{Area}: The calculated area for each layer in \code{x} (e.g., total species range area).
\item \strong{Overlap_Area_Y} (optional): If \code{y} is provided, the area where
the \code{x} layer and \code{y} raster both have a value of 1 (overlap).
\item \strong{Overlap_Area_Z} (optional): If \code{z} is provided, the area where
the \code{x} layer and \code{z} raster both have a value of 1 (overlap).
\item \strong{Overlap_Area_All} (optional): If both \code{y} and \code{z} are provided,
the area where the \code{x} layer, \code{y} raster, and \code{z} raster all have a value of 1 (triple overlap).
}
Areas are reported in the specified \code{unit}.
}
\description{
Calculates the total area for each layer (e.g., species) within a \code{SpatRaster} object.
Optionally, it can also compute the overlapping areas between the primary \code{SpatRaster} (\code{x})
and one or two additional single-layer \code{SpatRaster} objects (\code{y} and \code{z}).
Results are returned as a \code{data.frame} and can optionally be saved to a CSV file.
}
\examples{
\donttest{
library(terra)

# Load example rasters for demonstration
# Ensure these files are present in your package's inst/extdata folder
bin_rast <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))

# Example 1: Calculate area for 'bin_rast' only
area_only <- area.calc(bin_rast)
area_only
}
}
