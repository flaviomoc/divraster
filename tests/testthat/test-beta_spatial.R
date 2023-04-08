test_that("function spat.beta works", {

  # creating data
  library(terra)
  set.seed(100)
  bin1 <- terra::rast(ncol = 5, nrow = 5, nlyr = 10)
  values(bin1) <- round(runif(ncell(bin1) * nlyr(bin1)))
  names(bin1) <- paste0("sp", 1:10)

  set.seed(100)
  mass <- runif(10, 10, 800)
  beak.size <- runif(10, .2, 5)
  tail.length <- runif(10, 2, 10)
  wing.length <- runif(10, 15, 60)
  range.size <- runif(10, 10000, 100000)
  traits <- data.frame(mass, beak.size, tail.length, wing.length, range.size)
  rownames(traits) <- names(bin1)

  set.seed(100)
  tree <- ape::rtree(n = 10, tip.label = names(bin1))

  # applying the function
  beta.td <- spat.beta(bin1)
  beta.fd <- spat.beta(bin1, traits)
  beta.pd <- spat.beta(bin1, tree)

  # testing
  expect_equal(round(beta.td[[1]]@ptr$range_max, 2), .83)
  expect_equal(round(beta.td[[2]]@ptr$range_max, 2), .72)
  expect_equal(round(beta.td[[3]]@ptr$range_max, 2), .37)
  expect_equal(round(beta.fd[[1]]@ptr$range_max, 2), .74)
  expect_equal(round(beta.fd[[2]]@ptr$range_max, 2), .65)
  expect_equal(round(beta.fd[[3]]@ptr$range_max, 2), .26)
  expect_equal(round(beta.pd[[1]]@ptr$range_max, 2), .68)
  expect_equal(round(beta.pd[[2]]@ptr$range_max, 2), .54)
  expect_equal(round(beta.pd[[3]]@ptr$range_max, 2), .31)
})
