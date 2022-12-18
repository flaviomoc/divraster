test_that("function ecogen works", {

  # loading data
  ref <- terra::rast(system.file("extdata", "ref_Mota.tif", package = "DMSD"))
  fut <- terra::rast(system.file("extdata", "fut_Mota.tif", package = "DMSD"))
  traits <- utils::read.csv(system.file("extdata", "traits_Mota.csv", package = "DMSD"), sep = ";")

  # applying the function
  wing.ref <- ecogen(ref, traits$Wing.Length)
  wing.fut <- ecogen(fut, traits$Wing.Length)

  # testing
  expect_equal(round(wing.ref@ptr$range_max, 2), 154.78)
  expect_equal(round(wing.fut@ptr$range_max, 2), 200.70)
})
