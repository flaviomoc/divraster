test_that("function spat.beta works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif",
                                  package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv",
                                 package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre",
                                     package = "divraster"))

  # applying the function
  beta.td <- spat.beta(bin1)
  beta.fd <- spat.beta(bin1, traits)
  beta.pd <- spat.beta(bin1, tree)
  bin.na <- bin1
  bin.na2 <- bin1
  bin.na2[1:8, ] <- NA
  bin.crs <- bin1
  bin.na[1] <- NA
  terra::crs(bin.crs) <- "epsg:25831"

  # testing
  expect_error(spat.beta(bin.crs))
  expect_error(spat.beta(traits))
  expect_true(class(bin.na) == "SpatRaster", "TRUE")
  expect_error(spat.beta(bin1[[1]]))
  expect_equal(terra::minmax(spat.beta(bin.na2)[[1]])[2], NaN)
  expect_error(spat.beta(bin1, d = 0))
  expect_error(spat.beta(x = traits))
  expect_error(spat.beta(x = bin1, tree = bin1))
  expect_equal(round(terra::minmax(beta.td[[1]])[2], 2), .90)
  expect_equal(round(terra::minmax(beta.td[[2]])[2], 2), .72)
  expect_equal(round(terra::minmax(beta.td[[3]])[2], 2), .52)
  expect_equal(round(terra::minmax(beta.pd[[1]])[2], 2), .73)
  expect_equal(round(terra::minmax(beta.pd[[2]])[2], 2), .51)
  expect_equal(round(terra::minmax(beta.pd[[3]])[2], 2), .48)
})
