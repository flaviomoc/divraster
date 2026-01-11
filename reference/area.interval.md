# Calculate Area by Interval Classes for SpatRasters

This function takes a SpatRaster or list of SpatRaster objects,
classifies them into intervals based on user-defined or automatically
calculated min/max values, and calculates the area for each class across
all rasters.

## Usage

``` r
area.interval(
  raster_list,
  min_value = NULL,
  max_value = NULL,
  interval,
  round = TRUE,
  include_lowest = TRUE,
  right = TRUE,
  filename = NULL,
  ...
)
```

## Arguments

- raster_list:

  A SpatRaster object or a list of SpatRaster objects to analyze

- min_value:

  Numeric. Minimum value for the interval sequence. If NULL (default),
  automatically calculated from all input rasters

- max_value:

  Numeric. Maximum value for the interval sequence. If NULL (default),
  automatically calculated from all input rasters

- interval:

  Numeric. Interval size for the sequence (e.g., 0.1 for breaks every
  0.1 units)

- round:

  Logical. If TRUE, rounds min_value down and max_value up to the
  nearest interval. For example, with interval=0.1: min 0.12 becomes
  0.1, max 0.98 becomes 1.0. Default TRUE

- include_lowest:

  Logical. Should the lowest value be included in the classification?
  Default TRUE

- right:

  Logical. Should intervals be closed on the right (and open on the
  left)? Default TRUE

- filename:

  Character. Optional filename to save the output dataframe as CSV. If
  NULL (default), the dataframe is not saved

- ...:

  Additional arguments passed to the classify function

## Value

A data.frame containing area calculations for each interval class and
scenario

## Examples

``` r
# \donttest{
library(terra)

r1 <- rast(ncol=10, nrow=10, vals=runif(100, 0.12, 0.98))
r2 <- rast(ncol=10, nrow=10, vals=runif(100, 0, 1))
raster_list <- list(scenario1 = r1, scenario2 = r2)
result <- area.interval(
  raster_list = raster_list,
  interval = 0.1,
  round = TRUE)
# }
```
