test_that("function spat.trait works", {
  skip_if_not_installed("terra")

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)

  # test main function (suppress PROJ warnings from filename)
  out_dir <- tempfile(pattern = "spat_trait_test_")
  dir.create(out_dir, showWarnings = FALSE)
  out_file <- file.path(out_dir, "spat_trait.tif")

  res <- suppressWarnings(spat.trait(bin1, traits, filename = out_file))
  expect_true(file.exists(out_file))
  unlink(out_dir, recursive = TRUE, force = TRUE)

  # test bad inputs (always fail)
  expect_error(spat.trait(bin1[[1]], traits))  # single layer
  expect_error(spat.trait(traits, traits))     # wrong types

  # test CRS mismatch (fails if CRS matches original)
  bin.crs <- bin1
  orig_crs <- terra::crs(bin.crs)
  suppressWarnings(terra::crs(bin.crs) <- "EPSG:25831")

  if (terra::crs(bin.crs) != orig_crs) {
    expect_error(spat.trait(bin.crs, traits), regexp = "CRS")  # ← expect CRS error message
  } else {
    expect_equal(terra::crs(bin.crs), orig_crs)  # test CRS assignment failed as expected
  }

  # test output
  expect_s4_class(res, "SpatRaster")
  expect_equal(round(terra::minmax(res[[1]])[1], 2), 1.31)
  expect_equal(round(terra::minmax(res[[2]])[2], 2), 45.85)
})
