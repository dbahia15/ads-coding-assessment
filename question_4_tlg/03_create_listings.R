# Create listings
# Creates a detailed listing of all AEs with:
# Subject ID, Treatment, AE Term, Severity, Relationship to drug, Start/End dates
# Filtered for treatment-emergent events
# Sorted by subject and event date

### Set Up ###

# Load packages
library(gt)
library(pharmaverseadam)
library(dplyr)

# Import the data
adae <- pharmaverseadam::adae

### Create Listing ###

# Filter for treatment-emergent AEs
# Note any missing end dates as "NA" 
ae_listing_data <- adae %>%
  filter(
  TRTEMFL == "Y",
  ACTARM != "Screen Failure"
  ) %>%
  arrange(USUBJID, AESTDTC) %>%
  select(
    USUBJID,
    ACTARM,
    AETERM,
    AESEV,
    AEREL,
    AESTDTC,
    AEENDTC
  ) %>%
  mutate(
    AEENDTC = if_else(is.na(AEENDTC), "NA", AEENDTC)
  ) %>%
  group_by(USUBJID) %>%
  group_modify(~ tibble::add_row(.x, .after = nrow(.x))) %>%
  ungroup() %>%
  group_by(USUBJID) %>%
  mutate(
    ACTARM = if_else(row_number() == 1, ACTARM, ""),
    USUBJID = if_else(row_number() == 1, USUBJID, "")
  ) %>%
  ungroup()

# Convert listing to a gt table
ae_listing <- gtreg::tbl_listing(ae_listing_data)

# Add headings
ae_listing_html <- ae_listing %>%
  gtsummary::as_gt() %>%
  gt::tab_header(
    title = gt::html(
      "Listing of Treatment-Emergent Adverse Events by Subject<br>Excluding Screen Failure Patients"
    )
  ) %>%
  gt::opt_align_table_header(align = "left")

#Save listing at HTML
gt::gtsave(
  ae_listing_html,
  filename = "question_4_tlg/ae_listing.html"
)

cat("ae_listing.html saved")


