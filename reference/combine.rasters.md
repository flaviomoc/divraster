# Combine GeoTIFF rasters into a multilayer SpatRaster

Reads GeoTIFF files from a directory OR combines already-loaded
SpatRasters. Computes the union of their extents, resamples them to a
common grid, and returns a single multilayer SpatRaster.

## Usage

``` r
combine.rasters(
  raster_list = NULL,
  dir_path = NULL,
  pattern = NULL,
  method = "bilinear"
)
```

## Arguments

- raster_list:

  Optional list of SpatRaster objects already loaded in R. If provided,
  dir_path and pattern are ignored.

- dir_path:

  Character. Directory containing input GeoTIFF files. Only used if
  raster_list is NULL.

- pattern:

  Character. Pattern that file names must contain. Only used if
  raster_list is NULL.

- method:

  Character. Resampling method passed to terra::resample(), e.g.
  "bilinear" (default) or "near" for categorical data.

## Value

A single multilayer SpatRaster with one layer per input. Layers are
named from list names or file basenames without extension.

## Details

The first raster (file or list element) defines the target resolution,
origin and CRS; the union of all extents defines the spatial coverage.
Areas where a raster has no data are filled with NA.

## Examples

``` r
if (FALSE) { # \dontrun{
library(terra)

# Create 3 separate rasters with different extents
r1 <- rast(ncol = 30, nrow = 30, xmin = 0, xmax = 10,
           ymin = 0, ymax = 10, crs = "EPSG:4326")
values(r1) <- runif(ncell(r1), 0, 100)

r2 <- rast(ncol = 30, nrow = 30, xmin = 1, xmax = 11,
           ymin = 1, ymax = 11, crs = "EPSG:4326")
values(r2) <- runif(ncell(r2), 0, 100)

r3 <- rast(ncol = 30, nrow = 30, xmin = -1, xmax = 9,
           ymin = -1, ymax = 9, crs = "EPSG:4326")
values(r3) <- runif(ncell(r3), 0, 100)

# Combine into single multilayer SpatRaster
raster_list <- list(baseline = r1, future_A = r2, future_B = r3)
combined <- combine.rasters(raster_list = raster_list)
combined
} # }
```
