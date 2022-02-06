library(coiaf)

# Declare file location
here::i_am("scripts/alternate-filtering/split-file.R")

# Path to data
path <- "~/Desktop/Malaria/COI data/new-wsafs/"

# Read in the real data
wsaf_all_regions <- readRDS(paste0(path, "wsaf_intersecting.rds"))$wsaf_cleaned

# Read base pf6 predictions
base_pf6_predictions <- readRDS(here::here("data-outputs", "base_pf6.rds"))
sample_region <- dplyr::select(base_pf6_predictions, name, Region)

# Determine number of regions
regions <- sample_region %>%
  dplyr::pull(Region) %>%
  unique()

# Filter real data file to sample in each region and save
purrr::walk(regions, function(i) {
  samples <- sample_region %>%
    dplyr::filter(Region == regions[i]) %>%
    dplyr::pull(name)

  wsaf_region <- wsaf_all_regions[rownames(wsaf_all_regions) %in% samples, ]

  saveRDS(
    wsaf_region,
    paste0(path, "intersecting-regions/region_", regions[i], ".rds")
  )
})
