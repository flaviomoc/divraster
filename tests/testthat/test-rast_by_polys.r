test_that("rast.by.polys works", {

  skip_if_not_installed("terra")

  # ---------------------------------------------------------------------------
  # Create raster geometry ONCE, then reuse by changing values
  # ---------------------------------------------------------------------------
  r0 <- terra::rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10, ymin = 0, ymax = 10)

  # ---------------------------------------------------------------------------
  # Create polygons ONCE (can be reused across sub-tests)
  # ---------------------------------------------------------------------------
  p1 <- terra::vect("POLYGON ((0 0, 5 0, 5 5, 0 5, 0 0))")
  p2 <- terra::vect("POLYGON ((5 5, 10 5, 10 10, 5 10, 5 5))")
  polys <- rbind(p1, p2)
  polys$id <- 1:2

  p_all <- terra::vect("POLYGON ((0 0, 10 0, 10 10, 0 10, 0 0))")
  p_all$poly_id <- "A"

  # =============================================================================
  # Test 1: Basic functionality
  # =============================================================================
  r_seq <- r0
  terra::values(r_seq) <- 1:terra::ncell(r_seq)

  res1 <- rast.by.polys(r_seq, polys)

  expect_s3_class(res1, "data.frame")
  expect_equal(nrow(res1), 2)
  expect_true(ncol(res1) >= 1)

  # =============================================================================
  # Test 2: Uses ID column when specified
  # =============================================================================
  r_rand <- r0
  terra::values(r_rand) <- stats::runif(terra::ncell(r_rand), 0, 100)

  polys2 <- polys
  polys2$poly_id <- c("A", "B")
  polys2$extra_col <- c(1, 2)

  res2 <- rast.by.polys(r_rand, polys2, id_col = "poly_id")

  expect_s3_class(res2, "data.frame")
  expect_true("poly_id" %in% names(res2))
  expect_equal(res2$poly_id, c("A", "B"))
  # (Don’t assert extra_col is dropped unless that is guaranteed behavior.)

  # =============================================================================
  # Test 3: Custom summary function works
  # =============================================================================
  custom_fun <- function(v, ...) max(v, ...)

  res3 <- rast.by.polys(r_seq, p_all, fun = custom_fun, na.rm = TRUE)

  expect_s3_class(res3, "data.frame")
  expect_equal(nrow(res3), 1)
  expect_true("poly_id" %in% names(res3))
  expect_true(ncol(res3) >= 2)  # poly_id + at least one summary column

  # =============================================================================
  # Test 4: Error handling
  # =============================================================================
  expect_error(rast.by.polys("not a raster", polys))
  expect_error(rast.by.polys(r_seq, "not a vector"))
  expect_error(rast.by.polys(r_seq, polys, id_col = "nonexistent"))
})
