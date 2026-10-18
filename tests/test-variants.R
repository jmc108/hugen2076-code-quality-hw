# The supplied run_tests.R loads testthat and the functions from R/.
# Do not source original/messy_analysis.R here.

# A supplied ordinary example; keep it and add your own tests below.
test_that("MAF counts allele copies among observed diploid genotypes", {
    expect_equal(calculate_maf(c(0, 0, 1, 1)), 0.25)
})

# TODO: add small, independently justified known-answer tests for both functions.
# Cover the behavior groups listed in README.md. Do not just test data/genotypes.csv.
# Use informative test names; explain nonobvious expected answers in comments.
