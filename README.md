
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Real Data Analysis With coiaf

<!-- badges: start -->

[![Requirement](https://img.shields.io/badge/requirement-coiaf-blue)](https://github.com/bailey-lab/coiaf)
[![License:
MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<!-- badges: end -->

This repository stores the real data analysis conducted to test the
software package [{coiaf}](https://github.com/bailey-lab/coiaf).

## Data Source

We analysed samples from the MalariaGEN *Plasmodium falciparum*
Community Project \[1\]. The MalariaGEN *Plasmodium falciparum*
Community Project provides genomic data from over 7,000 *P. falciparum*
samples from 28 malaria-endemic countries in Africa, Asia, South
America, and Oceania from 2002-2015. Detailed information about the data
release including brief descriptions of contributing partner studies and
study locations is available in the supplementary of MalariaGEN *et
al.*.

## Project Structure

    .
    ├── analysis
    │   ├── estimation-comparison.Rmd
    │   └── pf6_analysis.Rmd
    ├── data-outputs
    │   ├── base_pf6.rds
    │   ├── intersecting_wsafs.rds
    │   ├── raw_base_pf6.rds
    │   ├── regional_wsafs.rds
    │   └── rmcl_estimation.rds
    ├── download
    │   ├── 00_Pf6_vcf_filtering.Rmd
    │   ├── 01_create_coiaf_inputs.Rmd
    │   ├── 02_Pf6_rmcl_vcf_filtering.Rmd
    │   └── 03_rmcl_results.Rmd
    ├── metadata
    │   ├── pf6_meta.Rmd
    │   └── pf6_meta.rds
    ├── raw-regions
    └── scripts
        ├── alternate-filtering
        │   ├── coi-region.R
        │   ├── combine-raw-regions.R
        │   ├── data-dimensions.R
        │   └── split-file.R
        ├── coi-region.R
        ├── combine-raw-regions.R
        └── rmcl-estimation.R

## References

<div id="refs" class="references csl-bib-body">

<div id="ref-malariagen_open_2021" class="csl-entry">

<span class="csl-left-margin">1. </span><span
class="csl-right-inline">MalariaGEN, Ahouidi A, Ali M, Almagro-Garcia J,
Amambua-Ngwa A, Amaratunga C, et al. An open dataset of Plasmodium
falciparum genome variation in 7,000 worldwide samples. Wellcome Open
Research. 2021;6: 42.
doi:[10.12688/wellcomeopenres.16168.1](https://doi.org/10.12688/wellcomeopenres.16168.1)</span>

</div>

</div>
