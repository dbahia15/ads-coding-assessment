# Create visualisations using {ggplot2)
#
#
# Required packages
# Install once in the R Console if they are not already installed:
# install.packages(c(
#   "dplyr",
#   "ggplot2",
#   "pharmaverseadam"
# ))
#
### Set Up ###


# Load packages
library(dplyr)
library(ggplot2)
library(pharmaverseadam)

#Read in the ADaM adverse events dataset
adae <- pharmaverseadam::adae

#### Create AE severity distribution by treatment (bar chart) ####

# Check AE severity categories by actual treatment group
#adae %>%
#  count(ACTARM, AESEV)

# Count adverse-event records by treatment group and severity
severity_counts <- adae %>%
  count(ACTARM, AESEV) %>%
  mutate(
    AESEV = factor(
      AESEV,
      levels = c("SEVERE", "MODERATE", "MILD")
    )
  )

# Create stacked AE-severity bar chart
ae_severity_plot <- ggplot(
  severity_counts,
  aes(x = ACTARM, y = n, fill = AESEV)
) +
  geom_col(position = position_stack(reverse = TRUE)) +
  scale_fill_manual(
    values = c(
      "MILD" = "red",
      "MODERATE" = "green",
      "SEVERE" = "blue"
    )
  ) +
  labs(
    title = "Adverse severity distribution by treatment",
    x = "Treatment Arm",
    y = "Count of AEs",
    fill = "Severity/Intensity"
  )

# Save the plot as a PNG file
ggsave(
  filename = "question_4_tlg/ae_severity_by_treatment.png",
  plot = ae_severity_plot,
  width = 9,
  height = 6,
  dpi = 300
)

cat("ae_severity_by_treatment.png saved.\n")

#### Create Forest Plot - Top 10 most frequent AEs (with 95% CI for incidence rates) ####

#Calculate total number of unique subjects
total_subjects <- n_distinct(adae$USUBJID)

# Count unique subjects with each adverse-event term and select top 10
top_10_ae <- adae %>%
  distinct(USUBJID, AETERM) %>%
  count(AETERM, sort = TRUE, name = "n")  %>%
  head(10)
  
# Calculate incidence rates and 95% Clopper-Pearson confidence intervals
top_10_ae <- top_10_ae %>%
  rowwise() %>%
  mutate(
    incidence_rate = n / total_subjects,
    ci_lower = binom.test(n, total_subjects)$conf.int[1],
    ci_upper = binom.test(n, total_subjects)$conf.int[2]
  ) %>%
  ungroup () %>%
  # Order by descending frequency for the plot
  mutate(AETERM = factor(AETERM, levels = rev(AETERM)))

# Create Forest Plot
ae_forest_plot <- ggplot(
  top_10_ae,
  aes(x = incidence_rate, y = AETERM)
) +
  geom_point(size = 3) +
  geom_errorbar(aes(xmin = ci_lower, xmax = ci_upper),
     width = 0.3, orientation = 'y') +
  labs(
    title = "Top 10 Most Frequent Adverse Events",
    subtitle = paste0("n = ", total_subjects, " subjects; 95% Clopper-Pearson CIs"),
    x = "Percentage of Patients (%)",
    y = NULL
  ) +
  scale_x_continuous(
    labels = scales::percent_format(accuracy = 1)
  )

# Save the plot as a PNG file
ggsave(
  filename = "question_4_tlg/top_10_ae_forest_plot.png",
  plot = ae_forest_plot,
  width = 9,
  height = 6,
  dpi = 300
)

cat("top_10_ae_forest_plot.png saved")



