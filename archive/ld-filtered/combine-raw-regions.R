library(coiaf)

# Declare file location
here::i_am("scripts/combine-raw-regions.R")

# Path to data
path <- "~/Desktop/Malaria/COI data/"

# Read in the real data and the REAL McCOIL COI predictions
rmcl_wsafs <- readRDS(paste0(path, "RMCL_wsafs_unique.rds"))
rmcl_coi_out <- readRDS(paste0(path, "RMCL_coi_out.rds")) %>%
  tibble::as_tibble() %>%
  dplyr::mutate(dplyr::across(c(file, name), as.character)) %>%
  dplyr::rename(rmcl = COI) %>%
  dplyr::rename(rmcl_025 = COI_025) %>%
  dplyr::rename(rmcl_975 = COI_975)

# Get a list of the 24 regions
regions <- names(rmcl_wsafs) %>%
  stringr::str_extract("region_[:digit:]+") %>%
  unique()

# Combine data
raw_predictions <- purrr::map(
  regions,
  ~ readRDS(here::here("raw-regions", glue::glue("{ .x }.rds")))
) %>%
  purrr::flatten()

# Set up a tibble with all the information from the runs.
# Summarize over the 10 VCFs
complete_predictions <- raw_predictions %>%
  dplyr::bind_rows() %>%
  dplyr::group_by(name, Region) %>%
  dplyr::summarise(
    dis_var_med = median(dis_var),
    dis_freq_med = median(dis_freq),
    cont_var_med = median(cont_var),
    cont_freq_med = median(cont_freq),
    rmcl_med = median(rmcl_med),
    rmcl_025_med = median(rmcl_025_med),
    rmcl_975_med = median(rmcl_975_med),
    .groups = "drop"
  ) %>%
  dplyr::relocate(Region, .after = dplyr::last_col())

# Assign a unique name to the data
data_name <- "test"

# Save data
saveRDS(
  raw_predictions,
  here::here("data-outputs", glue::glue("raw_{ data_name }.rds"))
)
saveRDS(
  complete_predictions,
  here::here("data-outputs", glue::glue("{ data_name }.rds"))
)

# Remove raw region data
system(glue::glue('rm -v { here::here("raw-regions", "*.rds")}'))
