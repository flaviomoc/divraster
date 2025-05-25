test_that("function spat.alpha2 works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif",
                                  package = "divraster"))

  bin1.na <- bin1
  bin1.na[, 1:7] <- NA

  # applying the function
  alpha.td <- spat.alpha2(bin1, filename = paste0(tempfile(), ".tif"))

  # testing
  expect_true(terra::hasValues(spat.alpha2(bin1.na)))
  expect_true(class(bin1) == "SpatRaster", "TRUE")
  expect_equal(terra::minmax(alpha.td)[1], 2)
})
