# Intersecting Data Workflow

When we generate the data used for estimating the COI worldwide, we generate
data where we examine minor allele frequencies both globally and locally. We
refer to Data for which the minor allele frequency is greater than a threshold
_both_ globally and locally as intersecting data because it is the intersection
of both global and local thresholds. The main difference between intersecting
data and data where the minor allele frequency is above a threshold only
regionally is the number of loci in the data sets. Since coiaf can run very fast
and can handle a large number of loci, we choose to analyze the data with the
most loci, i.e. the regional data.

The files stored in this folder were used when we were using intersecting data.

## File Descriptions

- `split-file.R`: a script used to split intersecting data into per region
  files.
- `intersecting_wsafs.rds`: the estimates generated for all samples.
- `combine-raw-regions.R`: a folder containing estimates for different sequence
  error values.
