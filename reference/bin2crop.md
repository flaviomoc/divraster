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

## Examples

``` r
if (FALSE) { # \dontrun{
library(terra)

# Create continuous raster (e.g., suitability values 0-1)
r_continuous <- rast(ncol = 50, nrow = 50, xmin = 0, xmax = 10,
                     ymin = 0, ymax = 10, crs = "EPSG:4326")
values(r_continuous) <- runif(ncell(r_continuous), 0, 1)
names(r_continuous) <- "suitability"

# Create binary raster (circular study area)
r_binary <- rast(r_continuous)
xy <- xyFromCell(r_binary, 1:ncell(r_binary))
center_dist <- sqrt((xy[,1] - 5)^2 + (xy[,2] - 5)^2)
values(r_binary) <- ifelse(center_dist <= 3, 1, 0)
names(r_binary) <- "study_area"

# Crop continuous raster to binary footprint
result <- bin2crop(r_bin = r_binary, r_cont = r_continuous)

# Plot comparison
par(mfrow = c(1, 3))
plot(r_binary, main = "Binary Footprint (Study Area)")
plot(r_continuous, main = "Original Continuous")
plot(result, main = "Cropped Result")
} # }
```
