test_that("function spat.alpha2 works", {
  skip_if_not_installed("terra")

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  bin1.na <- bin1
  bin1.na[, 1:7] <- NA

  # test filename writing
  out_dir <- tempfile(pattern = "temp_alpha_test")
  dir.create(out_dir, showWarnings = FALSE)
  out_file <- file.path(out_dir, "alpha.tif")

  alpha.td <- suppressWarnings(
    spat.alpha2(bin1, filename = out_file)
  )

  expect_true(file.exists(out_file))
  unlink(out_dir, recursive = TRUE, force = TRUE)

  # other tests
  expect_true(terra::hasValues(spat.alpha2(bin1.na)))
  expect_s4_class(bin1, "SpatRaster")
  expect_equal(terra::minmax(alpha.td)[1], 2)
})
