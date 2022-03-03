library(coiaf)

# Declare file location
here::i_am("scripts/combine-raw-regions.R")

# Combine data
predictions <- purrr::map(
  seq(24),
  ~ readRDS(here::here("raw-regions", glue::glue("region_{ .x }.rds")))
) %>%
  dplyr::bind_rows() %>%
  dplyr::mutate(Region = stringr::str_extract(data_file, "\\d+"))

# Assign a unique name to the data
data_name <- "example_name"

# Save data
saveRDS(
  predictions,
  here::here("data-outputs", glue::glue("{ data_name }.rds"))
)

# Remove raw region data
system(glue::glue('rm -v { here::here("raw-regions", "*.rds")}'))
