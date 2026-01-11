test_that("combine.rasters works", {

  skip_if_not_installed("terra")

  # ---------------------------------------------------------------------------
  # Create 3 separate rasters with different extents (aligned grids, res = 1)
  # ---------------------------------------------------------------------------
  r1 <- terra::rast(ncol = 30, nrow = 30, xmin = 0,  xmax = 30, ymin = 0,  ymax = 30)
  terra::values(r1) <- stats::runif(terra::ncell(r1), 0, 100)
  terra::crs(r1) <- "+proj=longlat +datum=WGS84 +no_defs"

  r2 <- terra::rast(ncol = 30, nrow = 30, xmin = 10, xmax = 40, ymin = 10, ymax = 40)
  terra::values(r2) <- stats::runif(terra::ncell(r2), 0, 100)
  terra::crs(r2) <- terra::crs(r1)

  r3 <- terra::rast(ncol = 30, nrow = 30, xmin = -10, xmax = 20, ymin = -10, ymax = 20)
  terra::values(r3) <- stats::runif(terra::ncell(r3), 0, 100)
  terra::crs(r3) <- terra::crs(r1)

  # ---------------------------------------------------------------------------
  # Test 1: Named list -> names preserved
  # ---------------------------------------------------------------------------
  raster_list <- list(layer1 = r1, layer2 = r2, layer3 = r3)
  result <- combine.rasters(raster_list = raster_list)

  expect_s4_class(result, "SpatRaster")
  expect_equal(terra::nlyr(result), 3)
  expect_equal(names(result), c("layer1", "layer2", "layer3"))

  # ---------------------------------------------------------------------------
  # Test 2: Unnamed list -> check union extent
  # ---------------------------------------------------------------------------
  result2 <- combine.rasters(raster_list = list(r1, r2))

  expect_s4_class(result2, "SpatRaster")
  expect_equal(terra::nlyr(result2), 2)

  expect_true(terra::ext(result2)$xmin <= 0)
  expect_true(terra::ext(result2)$xmax >= 40)
  expect_true(terra::ext(result2)$ymin <= 0)
  expect_true(terra::ext(result2)$ymax >= 40)

  # ---------------------------------------------------------------------------
  # Test 3: Directory input (read GeoTIFFs)
  # ---------------------------------------------------------------------------
  temp_dir <- tempfile(pattern = "testcomb_")
  dir.create(temp_dir, recursive = TRUE)

  on.exit(unlink(temp_dir, recursive = TRUE, force = TRUE), add = TRUE)

  terra::writeRaster(r1, file.path(temp_dir, "zztestfile1.tif"), overwrite = TRUE)
  terra::writeRaster(r2, file.path(temp_dir, "zztestfile2.tif"), overwrite = TRUE)

  result3 <- combine.rasters(dir_path = temp_dir, pattern = "zztestfile")

  expect_s4_class(result3, "SpatRaster")
  expect_equal(terra::nlyr(result3), 2)

  # ---------------------------------------------------------------------------
  # Test 4: Input validation errors
  # ---------------------------------------------------------------------------
  expect_error(combine.rasters())
  expect_error(combine.rasters(raster_list = list()))
  expect_error(combine.rasters(raster_list = "not a list"))

  empty_dir <- tempfile(pattern = "testempty_")
  dir.create(empty_dir, recursive = TRUE)
  on.exit(unlink(empty_dir, recursive = TRUE, force = TRUE), add = TRUE)

  expect_error(
    combine.rasters(dir_path = empty_dir, pattern = "nonexistent"),
    "No .tif/.tiff files found",
    fixed = TRUE
  )
})
