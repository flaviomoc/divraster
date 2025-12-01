# Flexible Area Calculation for Raster

This function calculates the area of integer categories in a primary
raster (r1). It can optionally compute an overlay area with a second
layer (r2) and/or perform calculations within distinct zones defined by
a polygon SpatVector.

## Usage

``` r
area.calc.flex(
  r1,
  r2_raster = NULL,
  r2_vector = NULL,
  threshold = NULL,
  zonal_polys = NULL,
  id_col = NULL,
  add_cols = NULL,
  omit_zero = TRUE,
  unit = "km"
)
```

## Arguments

- r1:

  The primary SpatRaster with integer categories.

- r2_raster:

  An optional SpatRaster for overlay analysis.

- r2_vector:

  An optional SpatVector for overlay analysis.

- threshold:

  A numeric value required to binarize 'r2_raster' if it's continuous.

- zonal_polys:

  An optional SpatVector for zonal analysis.

- id_col:

  A string specifying the column in 'zonal_polys'.

- add_cols:

  An optional character vector of additional column names from
  'zonal_polys'.

- omit_zero:

  A logical value. If TRUE (default), results for category = 0 are
  removed.

- unit:

  A string specifying the area unit ("km", "m", or "ha").

## Value

A data frame with the area for each category.
