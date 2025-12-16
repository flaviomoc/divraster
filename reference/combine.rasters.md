# Combine GeoTIFF rasters into a multilayer SpatRaster

Reads all GeoTIFF files in a directory that match a given pattern,
computes the union of their extents, resamples them to a common grid,
and returns a single multilayer `SpatRaster`.

## Usage

``` r
combine.rasters(dir_path, pattern, method = "bilinear")
```

## Arguments

- dir_path:

  Character. Directory containing the input GeoTIFF files.

- pattern:

  Character. Pattern that file names must contain before the extension
  (used inside `list.files(pattern = ...)`).

- method:

  Character. Resampling method passed to
  [`terra::resample()`](https://rspatial.github.io/terra/reference/resample.html),
  e.g. `"bilinear"` (default) or `"near"` for categorical data.

## Value

A `SpatRaster` with one layer per input file. Layers are named from the
file basenames without the `.tif` / `.tiff` extension.

## Details

The first file found (after sorting) defines the target resolution,
origin and CRS; the union of all input extents defines the spatial
coverage. Areas where a raster has no data are filled with `NA`.

## Extent handling

The function always uses the union of the input extents. The grid
(resolution, origin, CRS) comes from the first file, and that grid is
extended to cover the union of all extents before resampling.
