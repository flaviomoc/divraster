test_that("function spat.beta works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif",
                                  package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv",
                                 package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre",
                                     package = "divraster"))

  # applying the function
  beta.td <- spat.beta(bin1, filename = paste0(tempfile(), ".tif"))
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
  expect_equal(spat.beta(bin.na2)[[1]]@ptr$range_max, NaN)
  expect_error(spat.beta(bin1, d = 0))
  expect_error(spat.beta(x = traits))
  expect_error(spat.beta(x = bin1, tree = bin1))
  expect_equal(round(beta.td[[1]]@ptr$range_max, 2), .87)
  expect_equal(round(beta.td[[2]]@ptr$range_max, 2), .72)
  expect_equal(round(beta.td[[3]]@ptr$range_max, 2), .51)
  expect_equal(round(beta.fd[[1]]@ptr$range_max, 2), .81)
  expect_equal(round(beta.fd[[2]]@ptr$range_max, 2), .42)
  expect_equal(round(beta.fd[[3]]@ptr$range_max, 2), .64)
  expect_equal(round(beta.pd[[1]]@ptr$range_max, 2), .71)
  expect_equal(round(beta.pd[[2]]@ptr$range_max, 2), .53)
  expect_equal(round(beta.pd[[3]]@ptr$range_max, 2), .46)
})
