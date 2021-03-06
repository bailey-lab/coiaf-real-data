# Download Pf6 Data

This folder houses a set of `.Rmd` files that can be used to download the Pf6
data from the MalariaGEN _Plasmodium falciparum_ Community Project.

The data generated by these files are stored outside of this project in order
to keep the project size manageable. The main outputs from these files that
will be used in the data analysis pipeline are as follows:

- 24 `wsaf_reg_*.rds` files that will contain within sample allele frequency and
  coverage data for the 24 regions we examined.
- A `rmcl_coi.rds` file that will contain the estimated COI generated by
  THE REAL McCOIL. We will compare our estimations to this data.
