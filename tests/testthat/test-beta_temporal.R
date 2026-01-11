test_that("function temp.beta works", {
  skip_if_not_installed("terra")
  skip_if_not_installed("ape")
  skip_if_not_installed("BAT")

  # loading data
  bin1 <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  bin2 <- terra::rast(system.file("extdata", "fut.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "divraster"))
  bin.na <- bin1
  bin.na[1] <- NA

  # applying the function (test filename without emitting warnings)
  out_file <- paste0(tempfile(), ".tif")
  beta.td <- suppressWarnings(temp.beta(bin1, bin2, filename = out_file))
  expect_true(file.exists(out_file))
  unlink(out_file)

  beta.fd <- temp.beta(bin1, bin2, traits)
  beta.pd <- temp.beta(bin1, bin2, tree)

  bin.name <- bin1
  names(bin.name) <- paste0("x", 1:10)
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
  expect_error(temp.beta(bin1[[1]], bin2))
  expect_equal(round(terra::minmax(beta.td[[1]])[1], 2), .2)
  expect_equal(round(terra::minmax(beta.td[[2]])[2], 2), .89)
  expect_equal(round(terra::minmax(beta.td[[3]])[2], 2), .71)
  expect_equal(round(terra::minmax(beta.fd[[1]])[1], 2), .15)
  expect_equal(round(terra::minmax(beta.pd[[1]])[2], 2), .82)
  expect_equal(round(terra::minmax(beta.pd[[2]])[2], 2), .71)
  expect_equal(round(terra::minmax(beta.pd[[3]])[2], 2), .5)
})
