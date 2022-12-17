test_that("function alphadv works", {

  # loading data
  ref <- terra::rast(system.file("extdata", "ref_Mota.tif", package = "DMSD"))
  fut <- terra::rast(system.file("extdata", "fut_Mota.tif", package = "DMSD"))

  # applying the function
  r.rich <- alphadv(ref)
  f.rich <- alphadv(fut)

  # testing
  expect_equal(r.rich@ptr$range_min, 12)
  expect_equal(f.rich@ptr$range_min, 5)
})
