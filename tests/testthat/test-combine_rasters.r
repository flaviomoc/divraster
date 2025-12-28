library(testthat)
library(terra)

# Helper to create test rasters
make_raster <- function(xmin = 0, xmax = 10, ymin = 0, ymax = 10) {
  r <- rast(ncol = 20, nrow = 20, xmin = xmin, xmax = xmax,
            ymin = ymin, ymax = ymax, crs = "EPSG:4326")
  values(r) <- runif(ncell(r), 0, 100)
  r
}

# ==============================================================================
# Test 1: Basic list functionality
# ==============================================================================

test_that("combines list of rasters into multilayer", {
  r1 <- make_raster()
  r2 <- make_raster()
  r3 <- make_raster()

  raster_list <- list(layer1 = r1, layer2 = r2, layer3 = r3)
  result <- combine.rasters(raster_list = raster_list)

  expect_s4_class(result, "SpatRaster")
  expect_equal(nlyr(result), 3)
  expect_equal(names(result), c("layer1", "layer2", "layer3"))
})

# ==============================================================================
# Test 2: Union extent
# ==============================================================================

test_that("creates union extent from different extents", {
  r1 <- make_raster(xmin = 0, xmax = 10)
  r2 <- make_raster(xmin = 5, xmax = 15)

  result <- combine.rasters(raster_list = list(r1, r2))

  # Result should cover both extents
  expect_true(ext(result)$xmin <= 0)
  expect_true(ext(result)$xmax >= 15)
})

# ==============================================================================
# Test 3: File-based input
# ==============================================================================

test_that("combines rasters from directory", {
  temp_dir <- file.path(tempdir(), paste0("testcomb_", as.numeric(Sys.time())))
  dir.create(temp_dir, recursive = TRUE)

  r1 <- make_raster()
  r2 <- make_raster()

  writeRaster(r1, file.path(temp_dir, "zztestfile1.tif"), overwrite = TRUE)
  writeRaster(r2, file.path(temp_dir, "zztestfile2.tif"), overwrite = TRUE)

  result <- combine.rasters(dir_path = temp_dir, pattern = "zztestfile")

  expect_s4_class(result, "SpatRaster")
  expect_equal(nlyr(result), 2)

  unlink(temp_dir, recursive = TRUE)
})

# ==============================================================================
# Test 4: Essential error handling
# ==============================================================================

test_that("errors on invalid input", {
  expect_error(combine.rasters())
  expect_error(combine.rasters(raster_list = list()))
  expect_error(combine.rasters(raster_list = "not a list"))
})

test_that("errors when no files found", {
  temp_dir <- file.path(tempdir(), paste0("testempty_", as.numeric(Sys.time())))
  dir.create(temp_dir, recursive = TRUE)

  expect_error(
    combine.rasters(dir_path = temp_dir, pattern = "nonexistent"),
    "No .tif/.tiff files found"
  )

  unlink(temp_dir, recursive = TRUE)
})
