test_that("function betatemp_td works", {

  # creating data
  set.seed(100)
  ref <- terra::rast(array(sample(c(rep(1, 800), rep(0, 200))), dim = c(10, 10, 10)))
  names(ref) <- paste0("sp", 1:10)
  fut <- terra::rast(array(sample(c(rep(1, 400), rep(0, 600))), dim = c(10, 10, 10)))
  names(fut) <- names(ref)

  # applying the function
  beta.td <- betatemp_td(ref, fut)

  # testing
  expect_equal(round(beta.td[[1]]@ptr$range_min, 2), .25)
  expect_equal(round(beta.td[[2]]@ptr$range_max, 2), .67)
  expect_equal(round(beta.td[[3]]@ptr$range_max, 2), .88)
})
