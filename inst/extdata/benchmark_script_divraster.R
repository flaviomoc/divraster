# load packages
library(terra)
library(divraster)
library(BAT)
library(betapart)
library(bench)

################## low resolution rasters ##################
# create raster data
set.seed(100)
bin1 <- terra::rast(nlyr = 25,
                    r = .125,
                    ext = c(0, 1, 0, 1))
values(bin1) <- round(runif(ncell(bin1) * nlyr(bin1)))
names(bin1) <- paste0("sp", 1:25)

bin2 <- terra::rast(nlyr = 25,
                    r = .125,
                    ext = c(0, 1, 0, 1))
values(bin2) <- round(runif(ncell(bin2) * nlyr(bin2)))
names(bin2) <- names(bin1)

# transform the data to meet the requirements of other functions
bin1.raster <- raster::stack(bin1)
bin1.matrix <- as.matrix(bin1)
row.names(bin1.matrix) <- paste0("site", 1:256)

bin2.raster <- raster::stack(bin2)
bin2.matrix <- as.matrix(bin2)
row.names(bin2.matrix) <- row.names(bin1.matrix)

# create traits data
set.seed(100)
beak.size <- runif(25, .2, 5)
wing.length <- runif(25, 15, 60)
traits <- data.frame(beak.size, wing.length)
rownames(traits) <- names(bin1)

# create phylogenetic tree data
set.seed(100)
tree <- ape::rtree(n = 25, tip.label = names(bin1))

# benchmarks
# taxonomic diversity
TD <- mark(
  # spatial alpha diversity
  alpha_divraster = {
    spat.alpha(bin1)
  },
  alpha_BAT_raster = {
    raster.alpha(bin1.raster)
  },
  alpha_BAT_matrix = {
    alpha(bin1.matrix)
  },
  # spatial beta diversity
  beta_spat_divraster = {
    spat.beta(bin1)
  },
  beta_spat_BAT_raster = {
    raster.beta(bin1.raster)
  },
  beta_spat_BAT_matrix = {
    beta(bin1.matrix)
  },
  beta_spat_betapart = {
    beta.pair(bin1.matrix)
  },
  # temporal beta diversity
  beta_temp_divraster = {
    temp.beta(bin1, bin2)
  },
  beta_temp_betapart = {
    beta.temp(bin1.matrix, bin2.matrix, "jac")
  },
  check = F
)

# functional diversity
FD <- mark(
  # spatial alpha diversity
  alpha_divraster = {
    spat.alpha(bin1, traits)
  },
  alpha_BAT_raster = {
    raster.alpha(bin1.raster, traits)
  },
  alpha_BAT_matrix = {
    alpha(bin1.matrix, traits)
  },
  # spatial beta diversity
  beta_spat_divraster = {
    spat.beta(bin1, traits)
  },
  beta_spat_BAT_raster = {
    raster.beta(bin1.raster, traits)
  },
  beta_spat_BAT_matrix = {
    beta(bin1.matrix, traits)
  },
  beta_spat_betapart = {
    functional.beta.pair(bin1.matrix, traits, "jac")
  },
  # temporal beta diversity
  beta_temp_divraster = {
    temp.beta(bin1, bin2, traits)
  },
  check = F
)

# phylogenetic diversity
PD <- mark(
  # spatial alpha diversity
  alpha_divraster = {
    spat.alpha(bin1, tree)
  },
  alpha_BAT_raster = {
    raster.alpha(bin1.raster, tree)
  },
  alpha_BAT_matrix = {
    alpha(bin1.matrix, tree)
  },
  # spatial beta diversity
  beta_spat_divraster = {
    spat.beta(bin1, tree)
  },
  beta_spat_BAT_raster = {
    raster.beta(bin1.raster, tree)
  },
  beta_spat_BAT_matrix = {
    beta(bin1.matrix, tree)
  },
  beta_spat_betapart = {
    phylo.beta.pair(bin1.matrix, tree, "jac")
  },
  # temporal beta diversity
  beta_temp_divraster = {
    temp.beta(bin1, bin2, tree)
  },
  check = F
)

################## high resolution rasters ##################
# create raster data
set.seed(100)
bin1 <- terra::rast(nlyr = 25,
                    r = .04166667,
                    ext = c(0, 1, 0, 1))
values(bin1) <- round(runif(ncell(bin1) * nlyr(bin1)))
names(bin1) <- paste0("sp", 1:25)

bin2 <- terra::rast(nlyr = 25,
                    r = .04166667,
                    ext = c(0, 1, 0, 1))
values(bin2) <- round(runif(ncell(bin2) * nlyr(bin2)))
names(bin2) <- names(bin1)

# transform the data to meet the requirements of other functions
bin1.raster <- raster::stack(bin1)
bin1.matrix <- as.matrix(bin1)
row.names(bin1.matrix) <- paste0("site", 1:576)

bin2.raster <- raster::stack(bin2)
bin2.matrix <- as.matrix(bin2)
row.names(bin2.matrix) <- row.names(bin1.matrix)

# create traits data
set.seed(100)
beak.size <- runif(25, .2, 5)
wing.length <- runif(25, 15, 60)
traits <- data.frame(beak.size, wing.length)
rownames(traits) <- names(bin1)

# create phylogenetic tree data
set.seed(100)
tree <- ape::rtree(n = 25, tip.label = names(bin1))

# benchmarks
# taxonomic diversity
TD <- mark(
  # spatial alpha diversity
  alpha_divraster = {
    spat.alpha(bin1)
  },
  alpha_BAT_raster = {
    raster.alpha(bin1.raster)
  },
  alpha_BAT_matrix = {
    alpha(bin1.matrix)
  },
  # spatial beta diversity
  beta_spat_divraster = {
    spat.beta(bin1)
  },
  beta_spat_BAT_raster = {
    raster.beta(bin1.raster)
  },
  beta_spat_BAT_matrix = {
    beta(bin1.matrix)
  },
  beta_spat_betapart = {
    beta.pair(bin1.matrix)
  },
  # temporal beta diversity
  beta_temp_divraster = {
    temp.beta(bin1, bin2)
  },
  beta_temp_betapart = {
    beta.temp(bin1.matrix, bin2.matrix, "jac")
  },
  check = F
)

# functional diversity
FD <- mark(
  # spatial alpha diversity
  alpha_divraster = {
    spat.alpha(bin1, traits)
  },
  alpha_BAT_raster = {
    raster.alpha(bin1.raster, traits)
  },
  alpha_BAT_matrix = {
    alpha(bin1.matrix, traits)
  },
  # spatial beta diversity
  beta_spat_divraster = {
    spat.beta(bin1, traits)
  },
  beta_spat_BAT_raster = {
    raster.beta(bin1.raster, traits)
  },
  beta_spat_BAT_matrix = {
    beta(bin1.matrix, traits)
  },
  beta_spat_betapart = {
    functional.beta.pair(bin1.matrix, traits, "jac")
  },
  # temporal beta diversity
  beta_temp_divraster = {
    temp.beta(bin1, bin2, traits)
  },
  check = F
)

# phylogenetic diversity
PD <- mark(
  # spatial alpha diversity
  alpha_divraster = {
    spat.alpha(bin1, tree)
  },
  alpha_BAT_raster = {
    raster.alpha(bin1.raster, tree)
  },
  alpha_BAT_matrix = {
    alpha(bin1.matrix, tree)
  },
  # spatial beta diversity
  beta_spat_divraster = {
    spat.beta(bin1, tree)
  },
  beta_spat_BAT_raster = {
    raster.beta(bin1.raster, tree)
  },
  beta_spat_BAT_matrix = {
    beta(bin1.matrix, tree)
  },
  beta_spat_betapart = {
    phylo.beta.pair(bin1.matrix, tree, "jac")
  },
  # temporal beta diversity
  beta_temp_divraster = {
    temp.beta(bin1, bin2, tree)
  },
  check = F
)