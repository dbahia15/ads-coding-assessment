# descriptiveStats

A small R package for calculating descriptive statistics.

## Functions

- `calc_mean(x)` — Calculates the arithmetic mean.
- `calc_median(x)` — Calculates the median.
- `calc_mode(x)` — Calculates the mode and handles ties.
- `calc_q1(x)` — Calculates the first quartile.
- `calc_q3(x)` — Calculates the third quartile.
- `calc_iqr(x)` — Calculates the interquartile range (Q3 − Q1).

## Installation

From the root of this assessment repository, run:

```r
devtools::install("question_1/descriptive_stats")
library(descriptiveStats)

Examples

calc_mean(c(1, 2, 3))
# [1] 2


calc_median(c(1, 2, 3, 4))
# [1] 2.5


calc_mode(c(1, 2, 2, 3))
# [1] 2


calc_q1(c(1, 2, 3, 4, 5))
# [1] 2


calc_q3(c(1, 2, 3, 4, 5))
# [1] 4


calc_iqr(c(1, 2, 3, 4, 5))
# [1] 2
Input handling

All functions require a numeric vector with at least two non-missing values.

Missing values (NA and NaN) are removed before calculation.
Empty, all-missing, single-value, and non-numeric input produces an informative error.
When there is no mode, calc_mode() returns NA.
When values are tied for the mode, all tied modes are returned.
Testing

Run the tests with:

devtools::test("question_1/descriptive_stats")
License

MIT