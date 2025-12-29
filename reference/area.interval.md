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
  verbose = TRUE,
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

- verbose:

  Logical. Print progress messages? Default TRUE

- ...:

  Additional arguments passed to the classify function

## Value

A data.frame containing area calculations for each interval class and
scenario

## Examples

``` r
# \donttest{
library(terra)

# Single raster - automatic min/max detection with rounding
r1 <- rast(ncol=10, nrow=10, vals=runif(100, 0.12, 0.98))
result <- area.interval(r1, interval = 0.1, round = TRUE)
#> Single SpatRaster detected. Converting to list.
#> Calculating min/max values from 1 raster(s)...
#> Detected minimum value: 0.120519
#> Detected maximum value: 0.977443
#> Rounded minimum: 0.120519 -> 0.1
#> Rounded maximum: 0.977443 -> 1
#> Using 10 breaks from 0.1 to 1 (interval: 0.1)
#> Processing layer: lyr.1
# min 0.12 becomes 0.1, max 0.98 becomes 1.0

# Multiple rasters without rounding (use exact detected values)
r2 <- rast(ncol=10, nrow=10, vals=runif(100, 0, 1))
raster_list <- list(scenario1 = r1, scenario2 = r2)
result <- area.interval(raster_list, interval = 0.1, round = FALSE)
#> Calculating min/max values from 2 raster(s)...
#>   Processing raster 1/2
#>   Processing raster 2/2
#> Detected minimum value: 0.005146
#> Detected maximum value: 0.996688
#> Using 10 breaks from 0.005146 to 0.996688 (interval: 0.1)
#> Processing layer: lyr.1
#> Processing layer: lyr.1

# Specify custom min/max values (rounding not applied to manual values)
result <- area.interval(
  raster_list = raster_list,
  min_value = 0.6,
  max_value = 0.8,
  interval = 0.1
)
#> Using 3 breaks from 0.6 to 0.8 (interval: 0.1)
#> Processing layer: lyr.1
#> Processing layer: lyr.1

# Save results to file
result <- area.interval(
  raster_list = raster_list,
  interval = 0.1)
#> Calculating min/max values from 2 raster(s)...
#>   Processing raster 1/2
#>   Processing raster 2/2
#> Detected minimum value: 0.005146
#> Detected maximum value: 0.996688
#> Rounded minimum: 0.005146 -> 0
#> Rounded maximum: 0.996688 -> 1
#> Using 11 breaks from 0 to 1 (interval: 0.1)
#> Processing layer: lyr.1
#> Processing layer: lyr.1
# }
```
