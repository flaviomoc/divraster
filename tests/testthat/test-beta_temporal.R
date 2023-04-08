test_that("function temp.beta works", {

  # creating data
  library(terra)
  set.seed(100)
  bin1 <- terra::rast(ncol = 5, nrow = 5, nlyr = 10)
  values(bin1) <- round(runif(ncell(bin1) * nlyr(bin1)))
  names(bin1) <- paste0("sp", 1:10)
  bin2 <- terra::rast(ncol = 5, nrow = 5, nlyr = 10)
  values(bin2) <- round(runif(ncell(bin2) * nlyr(bin2)))
  names(bin2) <- names(bin1)

  set.seed(100)
  mass <- runif(10, 10, 800)
  beak.size <- runif(10, .2, 5)
  tail.length <- runif(10, 2, 10)
  wing.length <- runif(10, 15, 60)
  range.size <- runif(10, 10000, 100000)
  traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
  rownames(traits) <- names(bin1)

  set.seed(100)
  tree <- ape::rtree(n = 10, tip.label = paste0("sp", 1:10))

  # applying the function
  beta.td <- temp.beta(bin1, bin2)
  beta.fd <- temp.beta(bin1, bin2, traits)
  beta.pd <- temp.beta(bin1, bin2, tree)

  # testing
  expect_equal(round(beta.td[[1]]@ptr$range_max, 2), .88)
  expect_equal(round(beta.td[[2]]@ptr$range_max, 2), .86)
  expect_equal(round(beta.td[[3]]@ptr$range_max, 2), .62)
  expect_equal(round(beta.fd[[1]]@ptr$range_max, 2), .75)
  expect_equal(round(beta.fd[[2]]@ptr$range_max, 2), .72)
  expect_equal(round(beta.fd[[3]]@ptr$range_max, 2), .52)
  expect_equal(round(beta.pd[[1]]@ptr$range_max, 2), .72)
  expect_equal(round(beta.pd[[2]]@ptr$range_max, 2), .58)
  expect_equal(round(beta.pd[[3]]@ptr$range_max, 2), .49)
})
