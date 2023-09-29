test_that("function temp.beta works", {

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif",
                                  package = "divraster"))
  bin2 <- terra::rast(system.file("extdata", "fut.tif",
                                  package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv",
                                 package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre",
                                     package = "divraster"))
  bin.na <- bin1
  bin.na[1] <- NA

  # applying the function
  beta.td <- temp.beta(bin1, bin2, filename = paste0(tempfile(), ".tif"))
  beta.fd <- temp.beta(bin1, bin2, traits)
  beta.pd <- temp.beta(bin1, bin2, tree)
  bin.name <- bin1
  names(bin.name) <- paste0("x", 1:10)
  bin.crs <- bin1
  terra::crs(bin.crs) <- "epsg:25831"
  bin.lyr <- bin1[[1:5]]
  bin2.na <- bin2
  bin1.na <- bin1
  bin2.na[1:7, ] <- NA
  bin1.na[1:7, ] <- NA

  # testing
  expect_true(terra::hasValues(temp.beta(bin.na, bin2)[[2]]))
  expect_true(terra::hasValues(temp.beta(bin1.na, bin2.na)[[2]]))
  expect_error(temp.beta(bin.lyr, bin2))
  expect_error(temp.beta(bin1, bin2, traits = bin1))
  expect_error(temp.beta(bin1 = bin1, bin2 = traits))
  expect_error(temp.beta(bin1 = traits, bin2 =  bin2))
  expect_error(temp.beta(bin.name, bin2))
  expect_error(temp.beta(bin.crs, bin2))
  expect_error(temp.beta(bin1[[1]], bin2))
  expect_equal(round(terra::minmax(beta.td[[1]])[1], 2), .2)
  expect_equal(round(terra::minmax(beta.td[[2]])[2], 2), .89)
  expect_equal(round(terra::minmax(beta.td[[3]])[2], 2), .71)
  expect_equal(round(terra::minmax(beta.fd[[1]])[1], 2), .15)
  expect_equal(round(terra::minmax(beta.fd[[2]])[2], 2), .59)
  expect_equal(round(terra::minmax(beta.fd[[3]])[2], 2), .83)
  expect_equal(round(terra::minmax(beta.pd[[1]])[2], 2), .82)
  expect_equal(round(terra::minmax(beta.pd[[2]])[2], 2), .71)
  expect_equal(round(terra::minmax(beta.pd[[3]])[2], 2), .5)
})
