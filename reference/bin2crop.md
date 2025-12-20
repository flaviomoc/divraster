# Crop a continuous raster by a binary (0/1) raster footprint (value == 1)

Crop a continuous raster by a binary (0/1) raster footprint (value == 1)

## Usage

``` r
bin2crop(
  r_bin,
  r_cont,
  clip = NULL,
  resample_method = "bilinear",
  dissolve = TRUE,
  filename = NULL,
  overwrite = FALSE
)
```

## Arguments

- r_bin:

  SpatRaster. Binary raster (0/1). Cells with value 1 define the
  footprint.

- r_cont:

  SpatRaster. Continuous raster to crop/mask.

- clip:

  Optional SpatVector. Additional polygon to crop/mask the result.

- resample_method:

  Character. Method for resampling r_cont to r_bin grid if needed.

- dissolve:

  Logical. Dissolve contiguous 1-cells when polygonizing.

- filename:

  Optional character. If provided, writes result to disk.

- overwrite:

  Logical. Passed to writeRaster if filename is provided.

## Value

SpatRaster (cropped/masked continuous raster).
