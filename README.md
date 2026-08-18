# ADS Coding Assessment

This repository contains my solutions for Questions 1–5 of the ADS Programmer technical assessment using R and Python. Each question is organised in a separate folder.

## Repository Structure

```text
ads-coding-assessment/
├── question_1/
│   └── descriptive_stats/
├── question_2_sdtm/
├── question_3_adam/
├── question_4_tlg/
├── question_5_api/
└── README.md
```

## Question 1: Descriptive Statistics R Package

The `descriptiveStats` R package calculates common descriptive statistics for numeric vectors.

The package includes the following functions:

* `calc_mean()`
* `calc_median()`
* `calc_mode()`
* `calc_q1()`
* `calc_q3()`
* `calc_iqr()`

It includes Roxygen2 documentation, input validation, examples, and automated tests.

### Package Structure

```text
question_1/descriptive_stats/
├── R/
│   ├── central_tendency.R
│   ├── quartiles.R
│   └── utils.R
├── man/
│   ├── calc_mean.Rd
│   ├── calc_median.Rd
│   ├── calc_mode.Rd
│   ├── calc_q1.Rd
│   ├── calc_q3.Rd
│   ├── calc_iqr.Rd
│   └── validate_input.Rd
├── tests/
│   ├── testthat/
│   │   └── test-descriptive-stats.R
│   └── testthat.R
├── DESCRIPTION
├── LICENSE
├── NAMESPACE
└── README.md
```

### Installation

From the root of the repository, run:

```r
devtools::install("question_1/descriptive_stats")
library(descriptiveStats)
```

See the [Question 1 README](question_1/descriptive_stats/README.md) for further information.

## Question 2: SDTM DS Domain Creation

This question creates an SDTM Disposition (`DS`) domain using `pharmaverseraw::ds_raw`, `pharmaversesdtm::dm`, `{sdtm.oak}`, and study controlled terminology.

The final dataset includes:

```text
STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT,
VISITNUM, VISIT, DSDTC, DSSTDTC, DSSTDY
```

The creation script is:

```text
question_2_sdtm/02_create_ds_domain.R
```

### Reference

The associated Subject Disposition aCRF, including the programming notes used for the DS mappings, is available here:

[Subject Disposition aCRF](https://github.com/pharmaverse/pharmaverseraw/blob/main/vignettes/articles/aCRFs/Subject_Disposition_aCRF.pdf)

## Question 3: ADaM ADSL Dataset Creation

This question creates an ADSL subject-level analysis dataset using SDTM input data, `{admiral}`, and tidyverse tools.

The script derives:

* `AGEGR9` and `AGEGR9N`
* `TRTSDTM` and `TRTSTMF`
* `TRTEDTM`
* `ITTFL`
* `ABNSBPFL`
* `LSTALVDT`
* `CARPOPFL`

The creation script is:

```text
question_3_adam/create_adsl.R
```

## Question 4: Adverse-Event Reporting

This question creates adverse-event Tables, Listings, and Graphs using `pharmaverseadam::adae`, `pharmaverseadam::adsl`, `{gtsummary}`, `{gt}`, and `{ggplot2}`.

### Scripts

* `01_create_ae_summary.R` — Creates an HTML summary table of treatment-emergent adverse events by treatment group.

* `02_create_visualizations.R` — Creates an AE severity bar chart and a top-10 AE forest plot, saved as PNG files.

* `03_create_listings.R` — Creates an HTML listing of treatment-emergent adverse events, sorted by subject and event date.

## Question 5: Clinical Data API

This question creates a FastAPI application that reads `adae.csv` and provides:

* A welcome endpoint
* Dynamic adverse-event cohort filtering
* Subject-level safety risk scoring
* A `404` response for unknown subject IDs

The API code is:

```text
question_5_api/main.py
```

See the [Question 5 README](question_5_api/README.md) for installation, running, and endpoint-testing instructions.
