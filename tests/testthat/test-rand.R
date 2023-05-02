test_that("function spat.rand works", {

  # loading data
  x <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "divraster"))

  # applying the function
  ses.fd <- spat.rand(x, traits, 10, "spat")
  ses.pd <- spat.rand(x, tree, 10, "spat")

  # testing
  expect_true(ses.fd[[4]]@ptr$hasValues)
  expect_true(ses.pd[[4]]@ptr$hasValues)
  })
