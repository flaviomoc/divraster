test_that("function betatemp_pd works", {

  # creating data
  set.seed(100)
  ref <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
  names(ref) <- paste0("sp", 1:10)
  fut <- terra::rast(array(sample(c(rep(1, 400), rep(0, 600))), dim = c(10, 10, 10)))
  names(fut) <- names(ref)

  set.seed(100)
  tree <- ape::rtree(n = 10, tip.label = paste0("sp", 1:10))

  # applying the function
  beta.pd <- betatemp_pd(ref, fut, tree)

  # testing
  expect_equal(round(beta.pd[[1]]@ptr$range_max, 2), .86)
  expect_equal(round(beta.pd[[2]]@ptr$range_max, 2), .51)
  expect_equal(round(beta.pd[[3]]@ptr$range_max, 2), .83)
})
