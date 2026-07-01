## Utility functions used across implementations.

#' Check for presence of files `expected` in `path`
#'
#' Used in:
#' - *R/MsExperimentFiles.R*: `validateAlabasterMsExperimentFiles()`
#' - *R/MsExperiment.R*: `validateAlabasterMsExperiment()`
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
#' - *R/MsExperimentFiles.R*: `saveMsObject()` for `AlabasterParam` and
#'   `PlainTextParam`.
#'
#' @noRd
.check_overwriting <- function(x) {
    if (file.exists(x))
        stop("The provided path contains already an MS object stash. ",
             "Overwriting an existing stash is not supported. Please remove ",
             "the directory defined with parameter 'path' first.",
             call. = FALSE)
}

#' Used in:
#' - *R/MsExperiment.R*: `saveObject,MsExperiment`
#'
#' @noRd
.is_alabaster_matrix_installed <- function() {
    requireNamespace("alabaster.matrix", quietly = TRUE)
}

#' Used in:
#' - *R/MsExperiment.R*: `saveObject,MsExperiment`
#'
#' @noRd
.is_spectra_stash_installed <- function() {
    requireNamespace("SpectraStash", quietly = TRUE)
}

#' Used in
#' - *R/MsExperiment.R*: `saveObject,MsExperiment`
#'
#' @noRd
.is_alabaster_se_installed <- function() {
    requireNamespace("alabaster.se", quietly = TRUE)
}

#' Used in
#' - *R/MsExperiment.R*: `readMsObject,MsExperiment,MetaboLightsParam`
#'
#' @noRd
.is_ms_backend_metabo_lights_installed <- function() {
    requireNamespace("MsBackendMetaboLights", quietly = TRUE)
}
