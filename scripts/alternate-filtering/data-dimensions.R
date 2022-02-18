# Path to data
path <- "~/Desktop/Malaria/COI data/new-wsafs/"

# Read in the real data and determine number of samples and loci per region
data_dims <- purrr::map_dfr(
  cli::cli_progress_along(1:24, "Counting number of samples and loci"),
  function(i) {
    data_file <- glue::glue("wsaf_reg_{ i }.rds")
    wsaf_matrix <- readRDS(paste0(path, data_file))$wsaf_cleaned
    dims <- dim(wsaf_matrix)
    names(dims) <- c("samples", "loci")
    dims
  }
)

print(data_dims)
