## Utility functions used across implementations.

#' Check for presence of files `expected` in `path`
#'
#' Used in:
#' - *R/MsExperimentFiles.R*: `validateAlabasterMsExperimentFiles()`
#'
#' @noRd
.check_directory_content <- function(path, expected = character()) {
    if (any(miss <- !file.exists(file.path(path, expected))))
        stop("file(s) ", paste0("\"", expected[miss], "\"", collapse = ", "),
             " not found in ", path, call. = FALSE)
}
