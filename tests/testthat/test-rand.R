test_that("function spat.rand works", {
  skip_if_not_installed("terra")
  skip_if_not_installed("ape")

  # loading data
  x <- terra::rast(system.file("extdata", "ref.tif", package = "divraster"))
  traits <- read.csv(system.file("extdata", "traits.csv", package = "divraster"), row.names = 1)
  tree <- ape::read.tree(system.file("extdata", "tree.tre", package = "divraster"))

  # applying the function (test filename without emitting PROJ warnings)
  out_dir <- tempfile(pattern = "spat_rand_test_")
  dir.create(out_dir, showWarnings = FALSE)
  out_file <- file.path(out_dir, "ses_fd.tif")

  ses.fd <- suppressWarnings(
    spat.rand(x, traits, 3, "spat", filename = out_file)
  )
  expect_true(file.exists(out_file))
  unlink(out_dir, recursive = TRUE, force = TRUE)

  ses.pd  <- spat.rand(x, tree, 3, "spat")
  ses.pd2 <- spat.rand(x, tree, 3, "site")

  # create CRS-mismatch raster, but don't warn if PROJ is broken
  bin.crs <- x
  suppressWarnings(terra::crs(bin.crs) <- "+proj=longlat +datum=WGS84 +no_defs")

  # testing: input validation
  expect_error(spat.rand(x, traits, aleats = 3))
  expect_error(spat.rand(x, traits, random = "spat"))
  expect_error(spat.rand(x, x, 3, "spat"))
  expect_error(spat.rand(traits, traits, 3, "spat"))
  expect_error(spat.rand(x, traits, 3, "x"))
  expect_error(spat.rand(x[[1]], traits, 3, "spat"))

  # output has values
  expect_true(terra::hasValues(ses.fd[[4]]))
  expect_true(terra::hasValues(ses.pd[[4]]))
  expect_true(terra::hasValues(ses.pd2[[4]]))
})
