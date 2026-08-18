# Question 3: ADaM ADSL Dataset Creation
#
# Creates an ADSL subject-level dataset from SDTM source data using {admiral}.
#
### Set Up ###

# Load packages
library(admiral)
library(dplyr)
library(lubridate)
library(stringr)
library(pharmaversesdtm)

#Read input SDTM data
dm <- pharmaversesdtm::dm
ds <- pharmaversesdtm::ds
ex <- pharmaversesdtm::ex
ae <- pharmaversesdtm::ae
vs <- pharmaversesdtm::vs

# Convert blank strings to NA
dm <- convert_blanks_to_na(dm)
ds <- convert_blanks_to_na(ds)
ex <- convert_blanks_to_na(ex)
ae <- convert_blanks_to_na(ae)
vs <- convert_blanks_to_na(vs)

### Assign dm to ASDL objexct ###
adsl <- dm %>%
  dplyr::select(-DOMAIN)

### Derive Age Groups ###
# Categories are "<18", "18 - 50", ">50"
# Numeric groupings are 1, 2, 3.


# Create lookup tables 
agegr9_lookup <- admiral::exprs(
  ~condition,           ~AGEGR9, ~AGEGR9N,
  AGE < 18,               "<18",        1,
  between(AGE, 18, 50), "18 - 50",      2,
  AGE > 50,               ">50",        3
)

# Create age variables 
adsl <- adsl %>%
  admiral::derive_vars_cat(
    definition = agegr9_lookup
  )

### Derive treatment start date-time ###
# Set to the datetime of the patient's first exposure observation where:
#   Valid dose: EXDOSE > 0 OR (EXDOSE == 0 AND EXTRT contains "PLACEBO")
#   Date part of EXSTDTC is complete


# Derive datetime from EX start date, imputing missing time parts
# If only seconds are missing, do NOT populate imputation flag
ex_ext <- ex %>%
  admiral::derive_vars_dtm(
    dtc = EXSTDTC,
    new_vars_prefix = "EXST",
    highest_imputation = "h",
    time_imputation = "first",
    flag_imputation = "time",
    ignore_seconds_flag = TRUE
  )

### Derive date time for each exposure end record ###
# Merge first valid exposure start datetime to ADSL
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 |
                    (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) &
      !is.na(EXSTDTM),
    new_vars = exprs(TRTSDTM = EXSTDTM, TRTSTMF = EXSTTMF),
    order = exprs(EXSTDTM, EXSEQ),
    mode = "first",
    by_vars = exprs(STUDYID, USUBJID)
  )

# Derive EXENDTM (date time for each exposure end record)
# This will be used to derive TRTEDTM for LSTALVDT later 
ex_ext <- ex_ext %>%
  derive_vars_dtm(
    dtc = EXENDTC,
    new_vars_prefix = "EXEN",
    highest_imputation = "h",
    time_imputation = "last"
  )
# Derive TRTEDTM (last valid exposure end) for LSTALVDT later
adsl <- adsl %>%
  derive_vars_merged(
    dataset_add = ex_ext,
    filter_add = (EXDOSE > 0 |
      (EXDOSE == 0 & str_detect(EXTRT, "PLACEBO"))) & !is.na(EXENDTM),
    new_vars = exprs(TRTEDTM = EXENDTM),
    order = exprs(EXENDTM, EXSEQ),
    mode = "last",
    by_vars = exprs(STUDYID, USUBJID)
  )

### Derive treatment arm ###
# Create ITTFL for randomised participants
# These are participants with an ARM value in DM
adsl <- adsl %>%
  mutate(ITTFL = if_else(!is.na(ARM), "Y", "N"))

### Derive ABNSBPFL: abnormal supine systolic blood-pressure flag ###
# Set to "Y" if patient has  observation where [VS.VSTESTCD] = "SYSBP"
# and [VS.VSSTRESU] is "mmHg" and [VS.VSSTRESN] is greater than or equal to 140 
# or less than 100. Else set to "N"
adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = vs,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = ABNSBPFL,
    condition = (
      VSTESTCD == "SYSBP" &
        VSSTRESU == "mmHg" &
        VSPOS == "SUPINE" &
        (VSSTRESN >= 140 | VSSTRESN < 100)
    ),
    true_value = "Y",
    false_value = "N",
    missing_value = "N"
  )
### Derive LSTALVDT: Last Known Alive Date ###
# Derive from the latest valid VS, AE, DS, or treatment-end date:

adsl <- adsl %>%
  derive_vars_extreme_event(
    by_vars = exprs(STUDYID, USUBJID),
    events = list(
      
      # Vital-signs assessment date
      event(
        dataset_name = "vs",
        order = exprs(VSDTC, VSSEQ),
        condition = !is.na(VSDTC) &
          grepl("^\\d{4}-\\d{2}-\\d{2}", VSDTC) &
          !(is.na(VSSTRESN) & is.na(VSSTRESC)),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(VSDTC, highest_imputation = "n")
        )
      ),
      
      # Adverse-event onset date
      event(
        dataset_name = "ae",
        order = exprs(AESTDTC, AESEQ),
        condition = !is.na(AESTDTC) &
          grepl("^\\d{4}-\\d{2}-\\d{2}", AESTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(AESTDTC, highest_imputation = "n")
        )
      ),
      
      # Disposition date
      event(
        dataset_name = "ds",
        order = exprs(DSSTDTC, DSSEQ),
        condition = !is.na(DSSTDTC) &
          grepl("^\\d{4}-\\d{2}-\\d{2}", DSSTDTC),
        set_values_to = exprs(
          LSTALVDT = convert_dtc_to_dt(DSSTDTC, highest_imputation = "n")
        )
      ),
      
      # Final valid treatment end date-time (already in ADSL)
      event(
        dataset_name = "adsl",
        condition = !is.na(TRTEDTM),
        set_values_to = exprs(
          LSTALVDT = as.Date(TRTEDTM),
        )
      )
    ),
    source_datasets = list(vs = vs, ae = ae, ds = ds, adsl = adsl),
    order = exprs(LSTALVDT),
    mode = "last",
    new_vars = exprs(LSTALVDT),
    check_type = "none"
  )

### Derive CARPOPFL: Cardiac Adverse Event Population Flag ###
# Set to "Y" if patient has an observation where uppercase of [AE.AESOC] =
#"CARDIAC DISORDERS". Else set to missing.
adsl <- adsl %>%
  derive_var_merged_exist_flag(
    dataset_add = ae,
    by_vars = exprs(STUDYID, USUBJID),
    new_var = CARPOPFL,
    condition = toupper(AESOC) == "CARDIAC DISORDERS",
    true_value = "Y",
    false_value = NA_character_,
    missing_value = NA_character_
  )

