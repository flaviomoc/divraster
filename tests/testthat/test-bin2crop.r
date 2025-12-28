library(testthat)
library(terra)

# Helper to create test rasters
make_binary <- function(ncol = 20, nrow = 20) {
  r <- rast(ncol = ncol, nrow = nrow, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  # Create circular binary pattern
  xy <- xyFromCell(r, 1:ncell(r))
  center_dist <- sqrt((xy[,1] - 5)^2 + (xy[,2] - 5)^2)
  values(r) <- ifelse(center_dist <= 3, 1, 0)
  r
}

make_continuous <- function(ncol = 20, nrow = 20) {
  r <- rast(ncol = ncol, nrow = nrow, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- runif(ncell(r), 0, 100)
  r
}

# ==============================================================================
# Test 1: Basic functionality
# ==============================================================================

test_that("crops continuous raster to binary footprint", {
  r_bin <- make_binary()
  r_cont <- make_continuous()

  result <- bin2crop(r_bin, r_cont)

  expect_s4_class(result, "SpatRaster")
  expect_true(all(is.na(values(result)) | !is.na(values(result))))
})

test_that("result has values only where binary = 1", {
  r_bin <- make_binary()
  r_cont <- make_continuous()

  result <- bin2crop(r_bin, r_cont)

  # Result should have some non-NA values (where footprint exists)
  expect_true(any(!is.na(values(result))))
  # Result should have some NA values (outside footprint)
  expect_true(any(is.na(values(result))))
})

# ==============================================================================
# Test 2: Grid alignment and resampling
# ==============================================================================

test_that("resamples when grids don't match", {
  r_bin <- make_binary(ncol = 20, nrow = 20)
  r_cont <- make_continuous(ncol = 30, nrow = 30)  # Different resolution

  result <- bin2crop(r_bin, r_cont)

  expect_s4_class(result, "SpatRaster")
  # Result should match binary raster resolution
  expect_equal(res(result), res(r_bin))
})

test_that("uses specified resample method", {
  r_bin <- make_binary(ncol = 20, nrow = 20)
  r_cont <- make_continuous(ncol = 30, nrow = 30)

  result_bilinear <- bin2crop(r_bin, r_cont, resample_method = "bilinear")
  result_near <- bin2crop(r_bin, r_cont, resample_method = "near")

  expect_s4_class(result_bilinear, "SpatRaster")
  expect_s4_class(result_near, "SpatRaster")
})

# ==============================================================================
# Test 3: Empty footprint handling
# ==============================================================================

test_that("handles binary raster with all zeros", {
  r_bin <- make_binary()
  values(r_bin) <- 0  # All zeros
  r_cont <- make_continuous()

  result <- bin2crop(r_bin, r_cont)

  expect_s4_class(result, "SpatRaster")
  # All values should be NA
  expect_true(all(is.na(values(result))))
})

test_that("handles binary raster with all ones", {
  r_bin <- make_binary()
  values(r_bin) <- 1  # All ones
  r_cont <- make_continuous()

  result <- bin2crop(r_bin, r_cont)

  expect_s4_class(result, "SpatRaster")
  # Should have non-NA values everywhere
  expect_true(sum(!is.na(values(result))) > 0)
})

# ==============================================================================
# Test 4: Additional polygon clipping
# ==============================================================================

test_that("applies additional polygon clipping", {
  r_bin <- make_binary()
  r_cont <- make_continuous()

  # Create clipping polygon (smaller than footprint)
  clip_poly <- vect("POLYGON ((3 3, 7 3, 7 7, 3 7, 3 3))", crs = "EPSG:4326")

  result <- bin2crop(r_bin, r_cont, clip = clip_poly)

  expect_s4_class(result, "SpatRaster")
  # Extent should be smaller than original
  expect_true(ext(result) != ext(r_cont))
})

# ==============================================================================
# Test 5: File saving
# ==============================================================================

test_that("saves result to file when filename provided", {
  r_bin <- make_binary()
  r_cont <- make_continuous()
  temp_file <- tempfile(fileext = ".tif")

  result <- bin2crop(r_bin, r_cont, filename = temp_file, overwrite = TRUE)

  expect_true(file.exists(temp_file))

  # Can read saved file
  loaded <- rast(temp_file)
  expect_s4_class(loaded, "SpatRaster")

  unlink(temp_file)
})

test_that("overwrite parameter works", {
  r_bin <- make_binary()
  r_cont <- make_continuous()
  temp_file <- tempfile(fileext = ".tif")

  # First write
  bin2crop(r_bin, r_cont, filename = temp_file, overwrite = TRUE)

  # Second write with overwrite=TRUE should work
  expect_no_error(
    bin2crop(r_bin, r_cont, filename = temp_file, overwrite = TRUE)
  )

  unlink(temp_file)
})

# ==============================================================================
# Test 6: Error handling
# ==============================================================================

test_that("errors on invalid binary raster input", {
  r_cont <- make_continuous()

  expect_error(bin2crop("not a raster", r_cont))
  expect_error(bin2crop(NULL, r_cont))
})

test_that("errors on invalid continuous raster input", {
  r_bin <- make_binary()

  expect_error(bin2crop(r_bin, "not a raster"))
  expect_error(bin2crop(r_bin, NULL))
})

test_that("errors on invalid clip input", {
  r_bin <- make_binary()
  r_cont <- make_continuous()

  expect_error(bin2crop(r_bin, r_cont, clip = "not a polygon"))
})

# ==============================================================================
# Test 7: Dissolve parameter
# ==============================================================================

test_that("dissolve parameter affects processing", {
  r_bin <- make_binary()
  r_cont <- make_continuous()

  result_dissolve <- bin2crop(r_bin, r_cont, dissolve = TRUE)
  result_no_dissolve <- bin2crop(r_bin, r_cont, dissolve = FALSE)

  # Both should produce valid results
  expect_s4_class(result_dissolve, "SpatRaster")
  expect_s4_class(result_no_dissolve, "SpatRaster")
})

# ==============================================================================
# Test 8: Return properties
# ==============================================================================

test_that("result maintains CRS from input", {
  r_bin <- make_binary()
  r_cont <- make_continuous()

  result <- bin2crop(r_bin, r_cont)

  expect_equal(crs(result), crs(r_bin))
})

test_that("result has same resolution as binary raster", {
  r_bin <- make_binary()
  r_cont <- make_continuous()

  result <- bin2crop(r_bin, r_cont)

  expect_equal(res(result), res(r_bin))
})
