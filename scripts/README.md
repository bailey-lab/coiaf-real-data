# Real Data Scripts

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
