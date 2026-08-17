# descriptiveStats

An R package for calculating common descriptive statistics from numeric vectors.

## Installation

From the root of this repository, run:

```r
devtools::install("question_1/descriptive_stats")
library(descriptiveStats)
```

## Functions

- `calc_mean(x)` — Calculates the mean.
- `calc_median(x)` — Calculates the median.
- `calc_mode(x)` — Calculates the mode and handles ties.
- `calc_q1(x)` — Calculates the first quartile.
- `calc_q3(x)` — Calculates the third quartile.
- `calc_iqr(x)` — Calculates the interquartile range (Q3 − Q1).

## Usage
This is an example of how to use the package:

```r
library(descriptiveStats)

data <- c(1, 2, 2, 3, 4, 5, 5, 5, 6, 10)

calc_mean(data)
# [1] 4.3

calc_median(data)
# [1] 4.5

calc_mode(data)
# [1] 5

calc_q1(data)
# [1] 2.25

calc_q3(data)
# [1] 5

calc_iqr(data)
# [1] 2.75
```

## Edge-Case Handling

- Missing values (`NA` and `NaN`) are removed before calculation.
- Empty, all-missing, single-value, and non-numeric input produces an error.
- When there is no mode, `calc_mode()` returns `NA`.
- When values are tied for the mode, all tied modes are returned.

## Development

Generate documentation:

```r
devtools::document("question_1/descriptive_stats")
```

Run tests:

```r
devtools::test("question_1/descriptive_stats")
```

## License

MIT