# Vary Sequence Error Workflow

In earlier versions of `{coiaf}`, we would occasionally predict the maximum COI
allowable by our algorithms. In many cases, this was actually the effect of
suspected noisy data, which makes it difficult for our algorithms to infer the
correct sequencing error. In order to combat this high estimation, we would run
our algorithms with differing levels of sequencing errors and determine a list
of COI estimations. We would then examine these estimated COIs and determine the
final COI by looking for a series of values grouped together. This folder
contains a collection of scripts, analysis files, and data files used to conduct
this analysis workflow.

We later found that the prediction of very large COIs was due to using the
population level allele frequency and within sample allele frequency to generate
our estimates instead of the population level _minor_ allele frequency and
within sample _minor_ allele frequency.

## File Descriptions

- `varying_seq_error.Rmd`: the analysis file used to motivate the workflow.
- `vary-seq-error.R`: the script used to generate estimates.
- `freq_variation.rds`: the cleaned estimates generated for all samples.
- `raw_freq_variation.rds`: the raw estimates generated for all samples.
- `high_coi.rds`: the cleaned estimates generated for samples with a high COI.
- `raw_high_coi.rds`: the raw estimates generated for samples with a high COI.
- `low_coi_names.rds`: samples for which a low COI was detected.
- `high_coi_names.rds`: samples for which a high COI was detected.
