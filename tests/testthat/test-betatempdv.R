test_that("function betatempdv works", {

  # loading data
  ref <- terra::rast(system.file("extdata", "ref_Mota.tif", package = "DMSD"))
  fut <- terra::rast(system.file("extdata", "fut_Mota.tif", package = "DMSD"))

  # applying the function
  beta <- betatempdv(ref, fut)

  # testing
  expect_equal(round(beta@ptr$range_max[1], 3), .818)
  expect_equal(round(beta@ptr$range_max[2], 3), .632)
  expect_equal(round(beta@ptr$range_max[3], 3), .714)
  expect_equal(names(beta[[4]]), "Beta ratio")
  expect_equal(length(beta[1]), 4)
})
