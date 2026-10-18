# HW: Code Quality, Unit Testing, and Continuous Integration

## Purpose

Refactor a small, messy analysis into readable, reusable functions; write tests
that check its specified behavior; and configure GitHub Actions to run those tests
automatically when you push. This combines the code-quality and testing topics.

The starting script WORKS on the supplied valid data. It is intentionally poorly
organized, not intentionally numerically incorrect. Improve its structure without
changing the specified calculations. Input-error handling described below is an
explicit additional requirement, not behavior inferred from the messy script.

Use base R for the analysis and `testthat` for testing. Do not build an R package,
use Nextflow or Slurm, or install containers. Do not use generative AI for this
assignment. Use the lecture notes and permitted official documentation.

## Provided materials

- `original/messy_analysis.R`: runnable starting analysis; retain unchanged.
- `data/genotypes.csv`: small, entirely synthetic dataset.
- `expected/summary.csv`: expected full report for the supplied dataset/settings.
- `R/variant_functions.R`: required function interfaces, with TODO bodies.
- `run_analysis.R`: location for the refactored driver script.
- `tests/test-variants.R`: one starter test; add your own tests.
- `run_tests.R`: supplied runner; retain unchanged.
- `setup/run-r-tests.yml`: complete YAML to copy into the workflow location.
- `REPORT.md`: short explanation and execution-evidence template.

There are four hypothetical individuals (rows) and five variants (columns). The
values 0, 1, and 2 are copies of one consistently counted allele at each biallelic,
diploid variant. `NA` is missing. These are invented numbers, not research data.
The example thresholds of 0.25 are teaching settings, NOT QC recommendations.

## 1. Create your repository and establish the starting behavior

Create your own repository from the instructor's homework template. Use the name
`code-quality-testing-YOURUSERNAME` and the instructor's specified visibility.
Clone YOUR copy and open the supplied `.Rproj`. Files must be at repository root,
not inside an extra `code_quality_testing_hw/` directory. Give the instructor
access if the repository is private.

From an R console at the project root:

```r
install.packages("testthat")  # Once, if needed.
source("original/messy_analysis.R")
```

Inspect `results/messy_summary.csv` and compare it with `expected/summary.csv`.
The expected table is:

| variant_id | n_called | missing_rate | maf | keep |
|---|---:|---:|---:|---|
| v1 | 4 | 0 | 0.25 | TRUE |
| v2 | 3 | 0.25 | 0.5 | TRUE |
| v3 | 4 | 0 | 0.125 | FALSE |
| v4 | 4 | 0 | 0 | FALSE |
| v5 | 0 | 1 | NA | FALSE |

## 2. Refactor the code

### Required function A

```r
calculate_maf(genotypes, na_rm = TRUE)
```

`genotypes` is a numeric vector (not a matrix/data frame) containing only 0, 1, 2,
and missing values. Repeated values represent different people and must remain
in the calculation. For observed genotypes:

```text
p = sum of genotype values / (2 * number of observed individuals)
MAF = min(p, 1 - p)
```

Return one numeric value, not a table. For example, `c(1, 2, 2, 2)` gives `p = 7/8`
and MAF `1/8`, not `7/8`.

- `na_rm = TRUE` (default): exclude missing values from numerator AND denominator.
- `na_rm = FALSE`: if any genotype is missing, return `NA`.
- Empty or entirely missing input: return numeric `NA`, not 0, NaN, or Inf.
- All 0 or all 2: return 0. A single heterozygote has MAF 0.5.
- Reject nonnumeric input and any observed value other than 0, 1, or 2.
- `na_rm` must be exactly one nonmissing logical value; reject invalid settings.
- Validate genotype values even if `na_rm = FALSE` and missing values are present.

For entirely missing test input, use `c(NA_real_, NA_real_)`; this is explicitly
numeric. Ordinary `NA` is logical in R. `NaN` may be treated as missing via `is.na()`.
Tests do not need to exercise names, unusual attributes, or other data types.

### Required function B

```r
summarize_variant(genotypes, min_maf = 0.25, max_missing = 0.25)
```

Return a ONE-ROW data frame with exactly these columns in this order:

| Column | Required meaning |
|---|---|
| `n_called` | Number of nonmissing genotypes. |
| `missing_rate` | Number missing divided by total length, INCLUDING missing entries. |
| `maf` | Result of `calculate_maf(genotypes, na_rm = TRUE)`. |
| `keep` | Logical TRUE exactly when there is at least one called genotype, MAF is at least `min_maf`, and missing rate is at most `max_missing`. Otherwise FALSE. |

Both thresholds are INCLUSIVE. They are arguments, not hard-coded rules. For empty
input, return `n_called = 0`, `missing_rate = NA`, `maf = NA`, `keep = FALSE`. For a
nonempty entirely missing input, the missing rate is 1 and `keep` is FALSE.

`min_maf` must be one finite numeric value between 0 and 0.5 inclusive.
`max_missing` must be one finite numeric value between 0 and 1 inclusive.
Reject invalid inputs/settings with informative errors. Exact error wording is not
prescribed. Call `calculate_maf()` here; do not duplicate its calculation.

### Analysis driver and code-quality requirements

Complete `run_analysis.R` so it reads `data/genotypes.csv`, summarizes each column
using the default thresholds above, and writes `results/summary.csv`. Retain input
column order, prepend `variant_id`, omit row names, and create `results/` if needed.
Write the combined file ONCE, after computing the summaries. The result must agree
with `expected/summary.csv`.

When reading this known numeric genotype file, use:

```r
genotypes <- read.csv("data/genotypes.csv", colClasses = "numeric")
```

This ensures an entirely missing column is still numeric. This import detail is
supplied so it does not distract from refactoring and testing.

The two functions belong in `R/variant_functions.R` and must work independently of
this CSV, your working directory, or objects in the global environment. Sourcing
that file must only define functions, not run an analysis. Functions should return
their results, not read/write files. Keep reading/writing in `run_analysis.R`.

Use informative names, consistent spacing/indentation, named arguments where they
clarify a call, and short comments documenting inputs, outputs, assumptions, or
nonobvious choices. Remove unnecessary aliases, repeated calculations, and avoidable
nesting. Put settings in named variables and pass them explicitly. Do not narrate
every obvious line or create extra functions merely to increase the function count.

There is more than one good organization; correctness and clear responsibilities
matter more than matching one particular solution's style.

## 3. Write tests before and during refactoring

Keep the supplied test and add your own named `test_that()` blocks in files named
`test-*.R` under `tests/`. The runner loads your saved functions and `testthat`; do
not source the old analysis, load private files, or install packages inside tests.

Use tiny inputs and independently calculated expected results. The provided CSV
alone is not adequate test coverage. Cover the following behaviors:

1. Ordinary MAF calculations, including a case where the COUNTED allele is common.
2. Missing values: the correct denominator, both values of `na_rm`, and the default.
3. Empty, entirely missing, monomorphic, and single-observation inputs.
4. Each of the summary's output columns, not merely whether the function returns.
5. Both threshold boundaries, cases on either side, and NONDEFAULT thresholds.
6. Invalid genotype values and invalid argument settings produce errors; valid
   calls still return correct results.

Use comments to explain at least two nonobvious expected answers. Do not compute
an expected answer by calling the same function being tested. Do not replace useful
checks with `expect_true(TRUE)`, delete tests to obtain a passing run, or suppress
failures. More tests are not automatically better; choose cases that reveal errors.

From the project root, run:

```r
source("run_tests.R")
```

or:

```bash
Rscript --vanilla run_tests.R
```

Save files before rerunning. Initially the starter test FAILS because the function
bodies are not implemented. This is expected. Retain the supplied runner so a
failed test produces a failing process exit status.

## 4. Set up GitHub Actions using the class pattern

The workflow file is provided at `setup/run-r-tests.yml`, but that is NOT the
location GitHub uses to discover workflows. Copy it into the correct location:

```bash
mkdir -p .github/workflows
cp setup/run-r-tests.yml .github/workflows/run-r-tests.yml
```

Or on GitHub use **Add file > Create new file**, name it
`.github/workflows/run-r-tests.yml`, and paste the YAML supplied in `setup/`.
Use spaces, not tabs. Commit the new file and push, using RStudio's Git interface
or the terminal:

```bash
git add .github/workflows/run-r-tests.yml R/ tests/ run_tests.R run_analysis.R
git commit -m "Add refactored functions, tests, and automated checks"
git push
```

The workflow runs on pushes to ANY branch. It checks out your committed code, sets
up R, installs testthat, and runs `Rscript --vanilla run_tests.R`. It uses a
GitHub-hosted Ubuntu runner, not your laptop or a Pitt cluster. No Slurm settings,
container, personal access token, or credentials are needed in the YAML.

On GitHub open **Actions > R tests > your run > Run unit tests > Run tests**. Read
the log and record the commit and run URLs in `REPORT.md`. If Actions is disabled
or blocked by organization policy, contact the instructor rather than broadening
permissions or buying runner time. The workflow requests read-only repository
access. The template uses a fixed R version but does not lock every R package.

## 5. Demonstrate that the automation really detects a regression

After your tests and code pass, intentionally introduce ONE small implementation
bug that an EXISTING test should detect (for example, change one inclusive threshold
to exclusive). Predict the failure, commit and push the change, and inspect the
failed **Run tests** step. This controlled bad push is for the exercise only.

Then fix the implementation, rerun locally, commit, and push again. Keep the tests
unchanged across this deliberate bug/repair pair. Record the failed and repaired
run URLs. Setup or installation errors do not count as the required test failure.
Do not leave the final code broken or disable the action. If setup cannot run for
account/policy reasons, report it promptly and retain local test output for review.

## 6. Submit

Submit the repository URL, final commit identifier, and completed `REPORT.md`
through the course's normal submission route. The repository must include your
functions, driver, tests, YAML, supplied data, and the unchanged original script.
Do not upload `.RData`, secrets, participant data, large genotype files, or local
package libraries. `results/` is ignored by Git; the instructor will rerun the code.

## Satisfactory criteria

| Component | Requirement |
|---|---|
| Correct behavior | Both functions follow the written specification; the driver reproduces the expected report. |
| Code quality | Explicit parameters/returns, calculations separated from file I/O, reused MAF helper, readable names/comments/layout, no needless repetition. |
| Tests | Meaningful independently justified tests of all required behavior groups; valid behavior passes and relevant errors/bugs are exposed. |
| Automation | Correct workflow location, tests run on push, a genuine failed-test run followed by a repaired passing run, final revision passes. |
| Explanation | The report explains design changes, two tests, the regression/repair, and what the automation does and does not establish. |

A green Actions check alone is not a satisfactory grade. The instructor will review
test quality and code structure and may use additional inputs drawn from this written
specification. There are no hidden requirements for undocumented biological behavior.
