# Question 4: TLG Adverse Events Reporting
#
# Creates a treatment-emergent adverse-event summary table using {gtsummary}.
#
#
# Required packages
# Install once in the R Console if they are not already installed:
# install.packages(c(
#   "dplyr",
#   "gtsummary",
#   "gt",
#   "pharmaverseadam"
# ))
#
#
### Set Up ###

# Load packages
library(dplyr)
library(tidyr)
library(gtsummary)
library(pharmaverseadam)

# Read ADaM input datasets
adae <- pharmaverseadam::adae
adsl <- pharmaverseadam::adsl

# Filter to treatment-emergent AEs
adae_teae <- adae %>%
  filter(TRTEMFL == "Y")

### Create treatment-emergent AE summary table ###
tbl_ae <- adae_teae |>
  tbl_hierarchical(
    variables = c(AESOC, AETERM),
    by = ACTARM,
    denominator = adsl,
    id = USUBJID,
    overall_row = TRUE,
    label = list(..ard_hierarchical_overall.. = "Treatment-Emergent Adverse Events"
    )
  ) |>
  sort_hierarchical()

### Save the table as an HTML file ###

tbl_ae |>
  as_gt() |>
  gt::gtsave(filename = "question_4_tlg/ae_summary_table.html")

cat("ae_summary_table.html saved")
