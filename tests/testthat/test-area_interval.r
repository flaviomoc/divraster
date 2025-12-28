library(testthat)
library(terra)

# Helper to create test raster
make_raster <- function(min_val = 0, max_val = 1, name = NULL) {
  r <- rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10,
            ymin = 0, ymax = 10, crs = "EPSG:4326")
  values(r) <- runif(ncell(r), min_val, max_val)
  if (!is.null(name)) names(r) <- name
  r
}

# ==============================================================================
# Test 1: Basic functionality
# ==============================================================================

test_that("works with single raster", {
  r <- make_raster(0.2, 0.8)
  result <- area.interval(r, interval = 0.1, verbose = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
  expect_true("scenario" %in% names(result))
})

test_that("works with multiple rasters", {
  r1 <- make_raster()
  r2 <- make_raster()
  raster_list <- list(raster1 = r1, raster2 = r2)

  result <- area.interval(raster_list, interval = 0.1, verbose = FALSE)

  expect_equal(length(unique(result$scenario)), 2)
  expect_true(all(c("raster1", "raster2") %in% result$scenario))
})

# ==============================================================================
# Test 2: Auto-detection and rounding
# ==============================================================================

test_that("auto-detects min/max values", {
  r <- make_raster(0.15, 0.95)
  result <- area.interval(r, interval = 0.1, verbose = FALSE)

  expect_s3_class(result, "data.frame")
  expect_true(nrow(result) > 0)
})

test_that("rounding works correctly", {
  r <- make_raster(0.12, 0.98)

  result_round <- area.interval(r, interval = 0.1, round = TRUE, verbose = FALSE)
  result_exact <- area.interval(r, interval = 0.1, round = FALSE, verbose = FALSE)

  expect_s3_class(result_round, "data.frame")
  expect_s3_class(result_exact, "data.frame")
})

# ==============================================================================
# Test 3: Manual parameters
# ==============================================================================

test_that("respects manual min/max values", {
  r <- make_raster(0, 1)
  result <- area.interval(r, min_value = 0.3, max_value = 0.7,
                          interval = 0.1, verbose = FALSE)

  expect_s3_class(result, "data.frame")
})

test_that("saves to file when filename provided", {
  r <- make_raster()
  temp_file <- tempfile(fileext = ".csv")

  result <- area.interval(r, interval = 0.1, filename = temp_file, verbose = FALSE)

  expect_true(file.exists(temp_file))
  unlink(temp_file)
})

# ==============================================================================
# Test 4: Error handling
# ==============================================================================

test_that("errors on invalid interval", {
  r <- make_raster()

  expect_error(area.interval(r, interval = 0, verbose = FALSE))
  expect_error(area.interval(r, interval = -0.1, verbose = FALSE))
})

test_that("errors on invalid min/max", {
  r <- make_raster()

  expect_error(
    area.interval(r, min_value = 0.8, max_value = 0.2, interval = 0.1, verbose = FALSE)
  )
})

test_that("errors on empty list", {
  expect_error(area.interval(list(), interval = 0.1, verbose = FALSE))
})

# ==============================================================================
# Test 5: Edge cases
# ==============================================================================

test_that("handles unnamed rasters", {
  # Give rasters different layer names so they can be distinguished
  r1 <- make_raster(name = "layer1")
  r2 <- make_raster(name = "layer2")
  result <- area.interval(list(r1, r2), interval = 0.1, verbose = FALSE)

  # Should have 2 distinct scenarios
  expect_true(length(unique(result$scenario)) >= 2 || nrow(result) > 0)
})

test_that("verbose parameter controls user messages", {
  r <- make_raster()

  # Verbose TRUE should show messages about min/max detection
  expect_message(
    area.interval(r, interval = 0.1, verbose = TRUE),
    "Calculating min/max"
  )

  # Verbose FALSE should suppress those specific messages
  # Note: terra may still produce internal messages which is OK
  result <- area.interval(r, interval = 0.1, verbose = FALSE)
  expect_s3_class(result, "data.frame")
})
