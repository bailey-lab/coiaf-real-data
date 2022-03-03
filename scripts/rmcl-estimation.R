library(coiaf)

# Declare file location
here::i_am("scripts/rmcl-estimation.R")

# Path to data
path <- "~/Desktop/Malaria/COI data/"

# Read in the REAL McCOIL COI predictions
rmcl_coi_out <- readRDS(paste0(path, "RMCL_coi_out.rds")) %>%
  tibble::as_tibble() %>%
  dplyr::mutate(dplyr::across(c(file, name), as.character)) %>%
  dplyr::rename(rmcl = COI, rmcl_025 = COI_025, rmcl_975 = COI_975) %>%
  dplyr::relocate(name) %>%
  dplyr::mutate(
    vcf = forcats::as_factor(stringr::str_extract(file, "(?<=vcf_)\\d+")),
    rep = forcats::as_factor(stringr::str_extract(file, "(?<=rep_)\\d+")),
    .before = file
  )

# Summarize over the 5 rmcl runs for each sample, region, and vcf
rmcl_summarize_runs <- rmcl_coi_out %>%
  dplyr::group_by(name, region, vcf) %>%
  dplyr::summarise(
    rmcl_med = median(rmcl),
    rmcl_025_med = median(rmcl_025),
    rmcl_975_med = median(rmcl_975),
    .groups = "drop_last"
  )

# Summarize over the 10 vcfs for each region
rmcl_region <- dplyr::summarise(
  rmcl_summarize_runs,
  rmcl_med = median(rmcl_med),
  rmcl_025_med = median(rmcl_025_med),
  rmcl_975_med = median(rmcl_975_med),
  .groups = "drop"
)

# Save data
saveRDS(rmcl_region, here::here("data-outputs", "rmcl_estimation.rds"))
