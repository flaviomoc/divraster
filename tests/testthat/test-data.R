test_that("function load.data works", {

  # applying the function
  data <- DMSD::load.data()

  # testing
  expect_equal(length(data), 4)
  expect_s4_class(data$ref, "SpatRaster")
  expect_s4_class(data$fut, "SpatRaster")
  expect_s3_class(data$traits, "data.frame")
  expect_s3_class(data$tree, "phylo")
})
