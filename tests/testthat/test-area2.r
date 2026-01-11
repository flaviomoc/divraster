# tests/testthat/test-area_calc_flex-coverage.R
skip_if_not_installed("terra")

test_that("area.calc.flex works", {

  # ---------------------------------------------------------------------------
  # Create base raster ONCE (geometry + CRS)
  # CRS is important for stable area from terra::cellSize() [esp. km/ha]. [web:146]
  # ---------------------------------------------------------------------------
  r0 <- terra::rast(ncol = 10, nrow = 10, xmin = 0, xmax = 10, ymin = 0, ymax = 10)
  suppressWarnings(terra::crs(r0) <- "+proj=longlat +datum=WGS84 +no_defs")
  names(r0) <- "baseline"

  # Two-layer version to exercise the nlyr loop
  r1 <- c(r0, r0)
  names(r1) <- c("L1", "L2")

  # ---------------------------------------------------------------------------
  # Vectors ONCE
  # ---------------------------------------------------------------------------
  zones <- rbind(
    terra::vect("POLYGON ((0 0, 5 0, 5 10, 0 10, 0 0))"),
    terra::vect("POLYGON ((5 0, 10 0, 10 10, 5 10, 5 0))")
  )
  suppressWarnings(terra::crs(zones) <- terra::crs(r0))
  zones$region_id <- c("A", "B")

  v_overlay <- terra::vect("POLYGON ((0 0, 5 0, 5 10, 0 10, 0 0))")
  suppressWarnings(terra::crs(v_overlay) <- terra::crs(r0))

  # ---------------------------------------------------------------------------
  # Shared rasters derived from r0/r1
  # ---------------------------------------------------------------------------
  r_cat <- r1
  terra::values(r_cat[[1]]) <- sample(1:3, terra::ncell(r_cat[[1]]), replace = TRUE)
  terra::values(r_cat[[2]]) <- sample(1:3, terra::ncell(r_cat[[2]]), replace = TRUE)

  r_with_zero <- r0
  terra::values(r_with_zero) <- c(rep(0, 10), rep(1, terra::ncell(r_with_zero) - 10))

  overlay_bin <- terra::rast(r0)
  terra::values(overlay_bin) <- sample(0:1, terra::ncell(overlay_bin), replace = TRUE)
  suppressWarnings(terra::crs(overlay_bin) <- terra::crs(r0))

  overlay_all0 <- terra::rast(r0)
  terra::values(overlay_all0) <- 0
  suppressWarnings(terra::crs(overlay_all0) <- terra::crs(r0))

  overlay_cont <- terra::rast(r0)
  terra::values(overlay_cont) <- stats::runif(terra::ncell(overlay_cont), 0, 1)
  suppressWarnings(terra::crs(overlay_cont) <- terra::crs(r0))

  # A mismatched-geometry overlay to force compareGeom() == FALSE and hit project()
  overlay_misgeom <- terra::rast(ncol = 20, nrow = 20, xmin = 0, xmax = 10, ymin = 0, ymax = 10)
  terra::values(overlay_misgeom) <- sample(0:1, terra::ncell(overlay_misgeom), replace = TRUE)
  suppressWarnings(terra::crs(overlay_misgeom) <- terra::crs(r0))

  # =======================================================================
  # 1) Input validation branches
  # =======================================================================
  expect_error(area.calc.flex(r_cat, zonal_polys = zones), "id_col", fixed = TRUE)
  expect_error(
    area.calc.flex(r_cat, r2_raster = overlay_bin, r2_vector = v_overlay),
    "Only one of",
    fixed = TRUE
  )
  expect_error(area.calc.flex(r_cat, unit = "acres"), "must be one of", fixed = TRUE)

  # =======================================================================
  # 2) Non-zonal basic + unit column names
  # =======================================================================
  out_km <- area.calc.flex(r_cat, unit = "km")
  expect_true(all(c("layer", "area_id", "category", "area_km") %in% names(out_km)))

  out_m <- area.calc.flex(r_cat, unit = "m")
  expect_true("area_m" %in% names(out_m))

  out_ha <- area.calc.flex(r_cat, unit = "ha")
  expect_true("area_ha" %in% names(out_ha))

  # =======================================================================
  # 3) omit_zero TRUE/FALSE
  # =======================================================================
  out_drop <- area.calc.flex(r_with_zero, omit_zero = TRUE, unit = "m")
  expect_false(any(out_drop$category == 0))

  out_keep <- area.calc.flex(r_with_zero, omit_zero = FALSE, unit = "m")
  expect_true(any(out_keep$category == 0))

  # =======================================================================
  # 4) Overlay (binary) branch via minmax() %in% c(0,1)
  # =======================================================================
  out_bin <- area.calc.flex(r_cat, r2_raster = overlay_bin, unit = "m")
  expect_true(any(out_bin$area_id == "Total Area"))
  expect_true(any(out_bin$area_id == "Overlay Area"))

  # Cover the "df_filtered empty" branch (no overlay_value == 1 anywhere)
  out_all0 <- area.calc.flex(r_cat, r2_raster = overlay_all0, unit = "m")
  expect_true(any(out_all0$area_id == "Total Area"))
  expect_false(any(out_all0$area_id == "Overlay Area"))

  # =======================================================================
  # 5) Continuous overlay requires threshold + succeeds with threshold
  # =======================================================================
  expect_error(
    area.calc.flex(r_cat, r2_raster = overlay_cont, unit = "m"),
    "threshold",
    fixed = TRUE
  )
  out_cont <- area.calc.flex(r_cat, r2_raster = overlay_cont, threshold = 0.5, unit = "m")
  expect_true(any(out_cont$area_id == "Overlay Area"))

  # =======================================================================
  # 6) r2_vector overlay path (rasterize)
  # =======================================================================
  out_vec <- area.calc.flex(r_cat, r2_vector = v_overlay, unit = "m")
  expect_true(any(out_vec$area_id == "Overlay Area"))

  # =======================================================================
  # 7) Zonal path WITHOUT overlay
  # =======================================================================
  out_zonal <- area.calc.flex(r_cat, zonal_polys = zones, id_col = "region_id", unit = "m")
  expect_true(all(c("layer", "region_id", "area_id", "category", "area_m") %in% names(out_zonal)))

  # =======================================================================
  # 8) Zonal path WITH overlay (nested overlay branch)
  # =======================================================================
  out_zonal_overlay <- area.calc.flex(
    r_cat, r2_raster = overlay_bin, zonal_polys = zones, id_col = "region_id", unit = "m"
  )
  expect_true(any(out_zonal_overlay$area_id == "Overlay Area"))

  # =======================================================================
  # 9) compareGeom() FALSE -> project() branch
  # =======================================================================
  out_proj <- area.calc.flex(r_cat, r2_raster = overlay_misgeom, unit = "m")
  expect_true(any(out_proj$area_id == "Overlay Area"))
})
