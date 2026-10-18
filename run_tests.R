# Run from the repository root, locally or on GitHub Actions.
# All files in R/ should contain function definitions, not an analysis run.
if (!requireNamespace("testthat", quietly = TRUE)) {
    stop('Install testthat first: install.packages("testthat")')
}
library(testthat)

function_files <- list.files("R", pattern = "\\.R$", full.names = TRUE)
test_files <- list.files("tests", pattern = "^test.*\\.R$", full.names = TRUE)
if (length(function_files) == 0 || length(test_files) == 0) {
    stop("Run from the repository root; R/ and tests/ must contain R files.")
}

# Reload saved functions so we do not test an old RStudio definition.
test_environment <- new.env(parent = globalenv())
for (function_file in function_files) {
    sys.source(function_file, envir = test_environment)
}

testthat::test_dir(
    "tests",
    env = test_environment,
    reporter = "summary",
    stop_on_failure = TRUE,
    stop_on_warning = TRUE
)
