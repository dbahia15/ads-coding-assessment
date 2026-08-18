# Create listings
#
#
# Required packages:
# Install once in the R Console if they are not already installed:
# install.packages(c(
#   "dplyr", "gt", "gtsummary", "gtreg", "pharmaverseadam"
# ))
#
#
# Creates a detailed listing of all AEs with:
# Subject ID, Treatment, AE Term, Severity, Relationship to drug, Start/End dates
# Filtered for treatment-emergent events
# Sorted by subject and adverse event start date

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
  # Keep only the variables required for the detailed AE listing
  select(
    USUBJID,
    ACTARM,
    AETERM,
    AESEV,
    AEREL,
    AESTDTC,
    AEENDTC
  ) %>%
  # Replace missing AE end dates with "NA" listing for a clear display
  mutate(
    AEENDTC = if_else(is.na(AEENDTC), "NA", AEENDTC)
  ) %>%
  # For each participant, display the subject ID and treatment only
  # on their first row
  # If the same participant has the same AE term more than once,
  # display the term once
  group_by(USUBJID) %>%
  mutate(
    ACTARM = if_else(row_number() == 1, ACTARM, ""),
    USUBJID = if_else(row_number() == 1, USUBJID, ""),
    AETERM = if_else(duplicated(AETERM), "", AETERM)
  ) %>%
  ungroup()

# Convert prepared data to a detailed listing table
ae_listing <- gtreg::tbl_listing(ae_listing_data)

# Add headings
ae_listing <- ae_listing %>%
  gtsummary::modify_header(
    USUBJID = "Unique Subject Identifier",
    ACTARM = "Description of Actual Arm",
    AETERM = "Reported Term for the Adverse Event",
    AESEV = "Severity/Intensity",
    AEREL = "Causality",
    AESTDTC = "Start Date/Time of Adverse Event",
    AEENDTC = "End Date/Time of Adverse Event"
  ) 

# Convert the gtsummary listing into a gt table for further formatting
# Add the listing title and subtitle and align to the left
# Remove  lines between data rows while keeping lines between headings
ae_listing_html <- ae_listing %>%
  gtsummary::as_gt() %>%  
  gt::tab_header(
    title = gt::html(
      "Listing of Treatment-Emergent Adverse Events by Subject<br>Excluding Screen Failure Patients"
    )
  ) %>%
  gt::opt_align_table_header(align = "left") %>%
  gt::tab_options(
    table_body.hlines.style = "none",
    column_labels.border.top.style = "solid",
    column_labels.border.bottom.style = "solid"
  )

#Save listing at HTML
gt::gtsave(
  ae_listing_html,
  filename = "question_4_tlg/ae_listing.html"
)

cat("ae_listing.html saved")


