library(coiaf)

# Declare file location
here::i_am("scripts/coi-region.R")

# Path to data
path <- "~/Desktop/Malaria/COI data/wsafs-coverage/"

# Declare a variable region, which will dictate what region we are looking at
cli::cli_inform("Running region {region}")

# Read in the real data
data_file <- glue::glue("wsaf_reg_{ region }.rds")
wsaf_matrix <- readRDS(paste0(path, data_file))$wsaf
coverage_matrix <- readRDS(paste0(path, data_file))$coverage
plaf <- colMeans(wsaf_matrix, na.rm = T)

# Function for running methods
run_method <- function(sample_name, input, fn, coi_method) {
  tryCatch(
    rlang::exec(
      fn,
      data = input,
      data_type = "real",
      seq_error = 0,
      use_bins = FALSE,
      coi_method = coi_method
    ),
    error = function(e) {
      rlang::inform(glue::glue("Error for sample { sample_name }"))
      if (fn == "compute_coi") list(coi = NA) else NA
    }
  )
}

# For each sample run the estimation functions
coi <- lapply(
  cli::cli_progress_along(seq_len(nrow(wsaf_matrix)), "Computing predictions"),
  function(i) {
    sample_name <- rownames(wsaf_matrix)[i]
    wsaf <- wsaf_matrix[i, ]
    coverage <- coverage_matrix[i, ]
    input <- tibble::tibble(wsmaf = wsaf, plmaf = plaf, coverage = coverage) %>%
      tidyr::drop_na()

    dis_var <- run_method(sample_name, input, "compute_coi", "variant")
    dis_freq <- run_method(sample_name, input, "compute_coi", "frequency")
    cont_var <- run_method(sample_name, input, "optimize_coi", "variant")
    cont_freq <- run_method(sample_name, input, "optimize_coi", "frequency")

    # Extract coi from discrete estimation
    dis_var_coi <- dis_var$coi
    dis_freq_coi <- dis_freq$coi

    # Extract estimate when freq method has too few loci
    dis_freq_estimate <- ifelse(
      rlang::has_name(dis_freq, "estimated_coi"),
      dis_freq$estimated_coi,
      NaN
    )
    cont_freq_attr <- attributes(cont_freq)
    cont_freq_estimate <- ifelse(
      is.null(cont_freq_attr),
      NaN,
      cont_freq_attr$estimated_coi
    )

    # Extract num variant loci and expected num variant
    num_variant_loci <- ifelse(
      rlang::has_name(dis_freq, "estimated_coi"),
      dis_freq$num_variant_loci,
      NaN
    )
    expected_num_loci <- ifelse(
      rlang::has_name(dis_freq, "estimated_coi"),
      dis_freq$expected_num_loci,
      NaN
    )

    list(
      dis_var = dis_var_coi,
      dis_freq = dis_freq_coi,
      dis_freq_estimate = dis_freq_estimate,
      cont_var = cont_var,
      cont_freq = cont_freq,
      cont_freq_estimate = cont_freq_estimate,
      num_variant_loci = num_variant_loci,
      expected_num_loci = expected_num_loci
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
  dis_freq_estimate = coi_parsed$dis_freq_estimate,
  cont_var = coi_parsed$cont_var,
  cont_freq = coi_parsed$cont_freq,
  cont_freq_estimate = coi_parsed$cont_freq_estimate,
  num_variant_loci = coi_parsed$num_variant_loci,
  expected_num_loci = coi_parsed$expected_num_loci,
  data_file = data_file
)

# Save data
saveRDS(
  pred,
  here::here("raw-regions", glue::glue("region_{ region }.rds"))
)
