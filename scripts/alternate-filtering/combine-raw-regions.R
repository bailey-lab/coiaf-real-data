library(coiaf)

# Declare file location
here::i_am("scripts/alternate-filtering/combine-raw-regions.R")

# Path to data
path <- "~/Desktop/Malaria/COI data/new-wsafs/intersecting-regions/"

# Combine data
predictions <- purrr::map(
  seq(24),
  ~ readRDS(here::here("raw-regions", glue::glue("region_{ .x }.rds")))
) %>%
  dplyr::bind_rows() %>%
  dplyr::mutate(Region = stringr::str_extract(data_file, "\\d+"))

# Assign a unique name to the data
data_name <- "regional_wsafs"

# Save data
saveRDS(
  predictions,
  here::here("data-outputs", glue::glue("{ data_name }.rds"))
)

# Remove raw region data
system(glue::glue('rm -v { here::here("raw-regions", "*.rds")}'))
