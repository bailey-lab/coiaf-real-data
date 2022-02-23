# Linkage Disequilibrium Filtered Data Workflow

In order to run THE REAL McCOIL on data, the data must be filtered so that there
is no linkage disequilibrium (LD) between sites. As such, the download file used
to generate the data for running THE REAL McCOIL has an LD filtering step. In
initial anlyses of the Pf6 data, we examined data after having filtered for LD,
however, we later realized that without filtering for LD we will be able to
examine many more loci. Furthermore, as LD filtering is not needed for coiaf, we
choose to generate new data where we had not done LD filtering. 

The files stored in this folder were used when we were using LD filtered data.

## File Descriptions

- `coi-region.R`: the script used to generate estimates.
- `combine-raw-regions.R`: the script used to combine raw estimates.
- `base_pf6.rds`: the cleaned estimates generated for all samples.
- `raw_base_pf6.rds`: the raw estimates generated for all samples.
