test_that("function betatempdv works", {

  # loading data
  ref <- terra::rast(system.file("extdata", "ref_Mota.tif", package = "DMSD"))
  fut <- terra::rast(system.file("extdata", "fut_Mota.tif", package = "DMSD"))

  # applying the function
  beta <- betatempdv(ref, fut, "beta")
  turn <- betatempdv(ref, fut, "turn")
  nest <- betatempdv(ref, fut, "nest")
  ratio <- betatempdv(ref, fut, "ratio")
  all <- betatempdv(ref, fut)

  # testing
  expect_equal(round(beta@ptr$range_min, 3), .033)
  expect_equal(round(turn@ptr$range_max, 3), .667)
  expect_equal(round(nest@ptr$range_max, 3), .489)
  expect_equal(round(ratio@ptr$range_min, 3), .123)
  expect_equal(length(all), 4)
})
