library(coiaf)

# Declare file location
here::i_am("scripts/high_coi_script.R")

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

# Load list of sample names
high_coi_names <- readRDS(here::here("metadata", "high_coi_names.rds"))

# Function for running methods
run_method <- function(sample_name, input, fn, coi_method) {
  # Only compute for patients with a high COI
  if (!sample_name %in% high_coi_names) return(NA)

  if (coi_method == "frequency") {
    purrr::map_dbl(
      seq(0, 0.2, 0.01),
      function(seq_error) {
        coi <- tryCatch(
          rlang::exec(
            fn,
            data = input,
            data_type = "real",
            coi_method = coi_method,
            seq_error = seq_error,
            bin_size = 50
          ),
          error = function(e) {
            rlang::inform(glue::glue("Error for sample { sample_name }"))
            if (fn == "compute_coi") list(coi = NA) else NA
          }
        )

        if (fn == "compute_coi") coi$coi else coi
      }
    )
  } else if (coi_method == "variant") {
    coi <- tryCatch(
      rlang::exec(
        fn,
        data = input,
        data_type = "real",
        coi_method = coi_method,
        bin_size = 50
      ),
      error = function(e) {
        rlang::inform(glue::glue("Error for sample { sample_name }"))
        if (fn == "compute_coi") list(coi = NA) else NA
      }
    )

    if (fn == "compute_coi") coi$coi else coi
  }
}

# Analyze the real data. In order to split up our operation in to smaller
# chunks, we will compute the predictions on each of the 24 regions and then
# manually combine them.
# Get a list of the 24 regions
regions <- names(rmcl_wsafs) %>%
  stringr::str_extract("region_[:digit:]+") %>%
  unique()

curr_region <- regions[1]

# Find all wsafs for each region
rmcl_region <- names(rmcl_wsafs) %>%
  stringr::str_detect(stringr::str_c("cat_", curr_region,  "_")) %>%
  purrr::keep(rmcl_wsafs, .)

# Check region
print_regions <- paste0("{.file ", names(rmcl_region), "}")

cli::cli({
  cli::cli_text("List of VCFs:")
  cli::cli_ol(print_regions)
})

raw_predictions <- lapply(
  cli::cli_progress_along(seq_along(rmcl_region), "Computing predictions"),
  function(x) {
    sample <- rmcl_region[[x]]
    plaf <- colMeans(sample, na.rm = T)

    # For each sample run the estimation functions
    coi_region <- lapply(seq_len(nrow(sample)), function(i) {
      sample_name <- rownames(sample)[i]
      wsaf <- sample[i, ]
      input <- tibble::tibble(wsaf = wsaf, plaf = plaf) %>% tidyr::drop_na()

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
    })

    coi_region <- coi_region %>%
      purrr::flatten() %>%
      split(., names(.))

    # Prediction tibble
    pred <- tibble::tibble(
      name = rownames(sample),
      dis_var = coi_region$dis_var,
      dis_freq = coi_region$dis_freq,
      cont_var = coi_region$cont_var,
      cont_freq = coi_region$cont_freq,
      file = names(rmcl_region)[x]
    )

    # Summarize over the 5 rmcl runs
    rmcl_outputs <- rmcl_coi_out %>%
      dplyr::filter(stringr::str_detect(file, names(rmcl_region)[x])) %>%
      dplyr::group_by(name) %>%
      dplyr::summarise(
        rmcl_med = median(rmcl),
        rmcl_025_med = median(rmcl_025),
        rmcl_975_med = median(rmcl_975),
        .groups = "drop"
      )

    # Join the tibbles
    dplyr::full_join(pred, rmcl_outputs, by = "name") %>%
      dplyr::mutate(
        Region = as.numeric(stringr::str_extract(file, "(?<=region_)[:digit:]*")),
        VCF = as.numeric(stringr::str_extract(file, "(?<=vcf_)[:digit:]*"))
      ) %>%
      dplyr::relocate(file, .after = dplyr::last_col())
  }
)
names(raw_predictions) <- names(rmcl_region)

# Save data
saveRDS(
  raw_predictions,
  here::here("raw-regions", glue::glue("{ curr_region }.rds"))
)
