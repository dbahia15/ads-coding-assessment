# Question 2: SDTM DS Domain Creation using {sdtm.oak}
#
# Creates the Disposition (DS) domain from pharmaverseraw::ds_raw using the {sdtm.oak} package
#
# Required packages
# Install once in the R Console if they are not already installed:
# install.packages(c(
#   "dplyr",
#   "sdtm.oak",
#   "pharmaverseraw",
#   "pharmaversesdtm"
# ))
#
# The installation code is commented out so it does not run whenever
# this script is sourced.
#
#
#
### Set Up ###

# Load packages
library(sdtm.oak)
library(dplyr)
library(pharmaverseraw)
library(pharmaversesdtm)

# Read in the raw data and DM domain
ds_raw <- pharmaverseraw::ds_raw 
dm <- pharmaversesdtm::dm

# Generate oak_id_vars
ds_raw <- ds_raw %>%
  generate_oak_id_vars(
    pat_var = "PATNUM",
    raw_src = "ds_raw"
  )

### Read in CT ###

ct_paths <- c(
  "metadata/sdtm_ct.csv",
  "question_2_sdtm/metadata/sdtm_ct.csv"
)
ct_path <- ct_paths[file.exists(ct_paths)][1]
if (is.na(ct_path)) {
  stop("Could not find sdtm_ct.csv in the metadata folder.")
}
study_ct <- read.csv(ct_path, stringsAsFactors = FALSE)

### Map Topic Variable  ###

# Map IT.DSTERM when OTHERSP is missing
ds <- assign_no_ct(
  raw_dat = condition_add(ds_raw, is.na(OTHERSP)),
  raw_var = "IT.DSTERM",
  tgt_var = "DSTERM",
  )
# Map OTHERSP to DSTERM when it has been recorded
ds <- ds %>%
  assign_no_ct(
    raw_dat = condition_add(ds_raw, is.na(IT.DSTERM) & !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSTERM",
    id_vars = oak_id_vars()
  )

### Map DSDECOD ### 

# Map IT.DSDECOD when OTHERSP is missing
ds <- ds %>%
  assign_ct(
    raw_dat = condition_add(ds_raw, is.na(OTHERSP)),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSDECOD",
    ct_spec = study_ct,
    ct_clst = "C66727",
    id_vars = oak_id_vars()
  )

# Map OTHERSP to DSDECOD when it has been recorded
ds <- ds %>%
  assign_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSDECOD",
    id_vars = oak_id_vars()
  )

### Map DSCAT ###

# Randomized records are protocol milestones
ds <- ds %>%
  hardcode_no_ct(
    raw_dat = condition_add(
      ds_raw,
      is.na(OTHERSP) & IT.DSDECOD == "Randomized"
    ),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "PROTOCOL MILESTONE",
    id_vars = oak_id_vars()
  )

# Normal non-randomized records are disposition events
ds <- ds %>%
  hardcode_no_ct(
    raw_dat = condition_add(
      ds_raw,
      is.na(OTHERSP) & !is.na(IT.DSDECOD) & IT.DSDECOD != "Randomized"
    ),
    raw_var = "IT.DSDECOD",
    tgt_var = "DSCAT",
    tgt_val = "DISPOSITION EVENT",
    id_vars = oak_id_vars()
  )

# Records with an "Other, specify" value are Other Events
ds <- ds %>%
  hardcode_no_ct(
    raw_dat = condition_add(ds_raw, !is.na(OTHERSP)),
    raw_var = "OTHERSP",
    tgt_var = "DSCAT",
    tgt_val = "OTHER EVENT",
    id_vars = oak_id_vars()
  )

### Map Timing Variables ###

# Combine disposition date and time into ISO 8601 format
ds <- ds %>%
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = c("DSDTCOL", "DSTMCOL"),
    tgt_var = "DSDTC",
    raw_fmt = c("m-d-y", "H:M"),
    id_vars = oak_id_vars()
  )

# Map DSSTDTC
# Convert the disposition event start date to ISO 8601 format
ds <- ds %>%
  assign_datetime(
    raw_dat = ds_raw,
    raw_var = "IT.DSSTDAT",
    tgt_var = "DSSTDTC",
    raw_fmt = "m-d-y",
    id_vars = oak_id_vars()
  )

###  Map visit variables ### 

ds <- ds %>%
  # Create VISIT
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISIT",
    ct_spec = study_ct,
    ct_clst = "VISIT",
    id_vars = oak_id_vars()
  ) %>%
  # Create VISITNUM
  assign_ct(
    raw_dat = ds_raw,
    raw_var = "INSTANCE",
    tgt_var = "VISITNUM",
    ct_spec = study_ct,
    ct_clst = "VISITNUM",
    id_vars = oak_id_vars()
  )
# Derive numeric visit numbers for special visits
# Some special visit labels are not available in the CT file.
# Derive their numeric VISITNUM values from the study visit labels
ds <- ds %>%
  dplyr::mutate(
    VISITNUM = dplyr::case_when(
      VISIT == "AMBUL ECG REMOVAL" ~ 6,
      grepl("^UNSCHEDULED ", VISIT) ~
        suppressWarnings(as.numeric(sub("^UNSCHEDULED ", "", VISIT))),
      TRUE ~ suppressWarnings(as.numeric(VISITNUM))
    )
  )

### Create SDTM derived variables###

# Derive STUDYID, DOMAIN and USUBJID
ds <- ds %>%
  dplyr::mutate(
    STUDYID = ds_raw$STUDY,
    DOMAIN = "DS",
    USUBJID = paste0("01-", ds_raw$PATNUM)
  ) %>%
  # Derive DSSEQ using DTERM 
  # Derive DSSTDY using Date/Time of Study Start Date from DM domain
  derive_seq(tgt_var = "DSSEQ",
             rec_vars = c("USUBJID","DSDTC", "DSTERM")) %>%
  derive_study_day(
    sdtm_in = .,
    dm_domain = dm,
    tgdt = "DSSTDTC",
    refdt = "RFSTDTC",
    study_day_var = "DSSTDY"  
  ) 

### Reorder columns ###
ds_final <- ds %>%
  dplyr::select(
    STUDYID, DOMAIN, USUBJID, DSSEQ, DSTERM, DSDECOD, DSCAT,
    VISITNUM, VISIT, DSDTC, DSSTDTC, DSSTDY
  )
