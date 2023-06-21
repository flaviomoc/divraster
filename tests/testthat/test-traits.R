test_that("function spat.trait works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)

  # applying the function
  res <- spat.trait(bin1, traits, filename = paste0(tempfile(), ".tif"))
  bin.crs = bin1
  terra::crs(bin.crs) <- "epsg:25831"

  # testing
  expect_error(spat.trait(bin.crs))
  expect_error(spat.trait(traits))
  expect_error(spat.trait(bin1[[1]], traits))
  expect_true(class(bin1) == "SpatRaster", "TRUE")
  expect_equal(round(res[[1]]@ptr$range_min, 2), 1.31)
  expect_equal(round(res[[2]]@ptr$range_max, 2), 45.85)
})
