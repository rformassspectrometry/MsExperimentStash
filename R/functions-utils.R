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

#' Check if the file `x` already exists and throw an error if that's TRUE
#'
#' Used in:
#' - *R/MsExperimentFiles.R*: `saveMsObject()`
#'
#' @noRd
.check_overwriting <- function(x) {
    if (file.exists(x))
        stop("The provided path contains already an MS object stash. ",
             "Overwriting an existing stash is not supported. Please remove ",
             "the directory defined with parameter 'path' first.",
             call. = FALSE)
}
