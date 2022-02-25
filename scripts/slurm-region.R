library(coiaf)
base_path <- "/gpfs/data/jbailey5/apascha1/"
path <- paste0(base_path, "snp_selections")
job_name <- "example_job_name"

# Define functions -------------------------------------------------------------
# Helper function for running methods
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

# Define function for running each region
coiaf_region <- function(file, job_name) {
  # Read in the real data
  region_matrix <- readRDS(file)
  wsaf_matrix <- region_matrix$wsaf
  coverage_matrix <- region_matrix$coverage
  plaf <- colMeans(wsaf_matrix, na.rm = T)

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

      list(
        dis_var = dis_var_coi,
        dis_freq = dis_freq_coi,
        dis_freq_estimate = dis_freq_estimate,
        cont_var = cont_var,
        cont_freq = cont_freq,
        cont_freq_estimate = cont_freq_estimate
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
    data_file = file
  )

  # Save data
  saveRDS(pred, gsub("wsaf_reg", job_name, file))
}

# Estimate the COI for each region ---------------------------------------------
# Find files
files <- grep(
  "wsaf_reg",
  list.files(path, full.names = TRUE),
  value = TRUE
)

# Submit job to slurm
sopt <- list(time = "4:00:00", mem = "16Gb")
setwd(paste0(base_path, "slurm_outs"))
sjob <- rslurm::slurm_apply(
  coiaf_region,
  params = data.frame(file = files, job_name = job_name),
  global_objects = c("coiaf_region", "run_method"),
  jobname = paste0("coiaf_", job_name),
  nodes = length(files),
  cpus_per_node = 1,
  slurm_options = sopt,
  submit = TRUE
)

rslurm::get_job_status(sjob)
res <- rslurm::get_slurm_out(sjob)

# Merge estimations ------------------------------------------------------------
# Find files
files <- grep(
  job_name,
  list.files(path, full.names = TRUE),
  value = TRUE
)

# Combine data
predictions <- purrr::map(files, ~ readRDS(.x)) %>%
  dplyr::bind_rows() %>%
  dplyr::mutate(
    Region = stringr::str_extract(data_file, "(?<=wsaf_reg_)\\d+(?=.rds)")
  )

# Assign a unique name to the data
data_name <- "example_name"

# Save data
saveRDS(
  predictions,
  glue::glue("{ base_path }/coiaf-results/{ data_name }.rds")
)

# Remove raw region data
system(glue::glue("rm -v { path }/{ job_name }*.rds"))
