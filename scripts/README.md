# Real Data Scripts

## Running With Jobs

The scripts in this folder have been designed to facilitate the process of
running real data. In our data, we have defined 24 unique regions of samples.
The scripts have been developed such that a single region is analyzed. In doing
so, users may separate each individual region into its own "job." Users may then
run multiple "jobs" at the same time and analyze multiple regions at once.

Locally, users may leverage [RStudio
jobs](https://www.rstudio.com/blog/rstudio-1-2-jobs/) to run a script in the
background. Users may also use a remote server to run the scripts.

Users may run a job using RStudio using the following code snippet:

```r
rstudioapi::jobRunScript(
  path = here::here("scripts", "<script-name>.R"),
  name = "<region-name>"
)
```

In some instances, it may be easier to run multiple jobs at once by leveraging
global variables. For instance, instead of running each region manually and
changing the `region` variable, we can define a global variable `region`. We can
then iterate over a sequence of regions using the `{purrr}` package.

```r
# Remove all global objects
rm(list = ls())

# Run each of the 24 regions as seperate jobs
purrr::walk(seq(24), function(i) {
  region <<- i
  rstudioapi::jobRunScript(
    path = here::here("scripts", "<script-name>.R"),
    name = paste("Region", i),
    importEnv = TRUE
  )
})
```

## Running with slurm

If researchers are able to access a high performance computing cluster, they may
also run the real data estimations by submitting jobs to slurm, a cluster
management and job scheduling system.

## File Descriptions

A brief description of each script can be found below:

- `coi-region`: computes the COI of each sample in each region.
- `slurm-region`: can be used to estimate the COI of each sample by submitting
  jobs to slurm.
- `combine-raw-regions.R`: takes the estimated COI for each region and combines
  the estimations into data objects. These data objects are saved in the
  [data-outputs
  folder](https://github.com/bailey-lab/coiaf-real-data/tree/main/data-outputs).
- `rmcl-estimation.R`: extracts THE REAL McCOIL estimations and saves the `.rds`
  file in the [data-outputs
  folder](https://github.com/bailey-lab/coiaf-real-data/tree/main/data-outputs).
- `data-dimensions.R`: determines the number of samples and loci in each region.
