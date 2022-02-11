library(coiaf)

# Declare file location
here::i_am("scripts/alternate-filtering/coi-region.R")

# Path to data
path <- "~/Desktop/Malaria/COI data/new-wsafs/"

# Declare a variable region, which will dictate what region we are looking at
cli::cli_inform("Running region {region}")

# Read in the real data
data_file <- glue::glue("wsaf_reg_{ region }.rds")
wsaf_matrix <- readRDS(paste0(path, data_file))$wsaf_cleaned
plaf <- colMeans(wsaf_matrix, na.rm = T)

# Function for running methods
run_method <- function(sample_name, input, fn, coi_method) {
  coi <- tryCatch(
    rlang::exec(
      fn,
      data = input,
      data_type = "real",
      coi_method = coi_method
    ),
    error = function(e) {
      rlang::inform(glue::glue("Error for sample { sample_name }"))
      if (fn == "compute_coi") list(coi = NA) else NA
    }
  )

  if (fn == "compute_coi") coi$coi else coi
}

# For each sample run the estimation functions
coi <- lapply(
  cli::cli_progress_along(seq_len(nrow(wsaf_matrix)), "Computing predictions"),
  function(i) {
    sample_name <- rownames(wsaf_matrix)[i]
    wsaf <- wsaf_matrix[i, ]
    input <- tibble::tibble(wsmaf = wsaf, plmaf = plaf) %>% tidyr::drop_na()

    dis_var <- run_method(sample_name, input, "compute_coi", "variant")
    dis_freq <- run_method(sample_name, input, "compute_coi", "frequency")
    cont_var <- run_method(sample_name, input, "optimize_coi", "variant")
    cont_freq <- run_method(sample_name, input, "optimize_coi", "frequency")

    list(
      dis_var = dis_var,
      dis_freq = dis_freq,
      cont_var = cont_var,
      cont_freq = cont_freq
    )
  }
)

coi_parsed <- coi %>%
  unlist() %>%
  split(., names(.))

# Prediction tibble
pred <- tibble::tibble(
  name = rownames(wsaf_matrix),
  dis_var = coi_parsed$dis_var,
  dis_freq = coi_parsed$dis_freq,
  cont_var = coi_parsed$cont_var,
  cont_freq = coi_parsed$cont_freq,
  data_file = data_file
)

# Save data
saveRDS(
  pred,
  here::here("raw-regions", glue::glue("region_{ region }.rds"))
)
