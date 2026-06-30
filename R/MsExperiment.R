#' @title `MsExperiment` Stash
#'
#' @name MsExperimentStash
#'
#' @description
#'
#' `MsExperiment` objects can be stored to (or read from) *MsExperimentStash*es
#' using the `saveMsObject()` and `readMsObject()` functions which take a
#' second argument `parameter` to select and configure the format of the stash.
#'
#' The supported stash formats are listed in the sections below.
#'
#' @section *abalbaster*-based format, `AlabasterParam`:
#'
#' This stash format is the most complete and reliable way for long-term
#' (and portable) storage of an `MsExperiment`. Objects can be saved or read
#' from this stash format either using the `saveMsObject()` and `readMsObject()`
#' functions or also using the [alabaster.base::saveObject()] and
#' [alabaster.base::readObject()] functions.
#' Data from the object's slots are stored to their respective folders (using
#' alabaster functionality). These folders are:
#'
#' - *experiment_files*: the content of the `@experimentFiles` slot, stored
#'   as a [MsExperimentFilesStash].
#' - *metadata*: the content of the object's `@metadata` slot.
#' - *other_data*: the content of the object's `@otherData` slot. Note that
#'   export fails if object types are stored in this slot without available
#'   *alabaster* export functionality.
#' - *qdata*: the content of the object's `@qdata` slot (if present). Currently
#'   only [SummarizedExperiment] objects are supported.
#' - *sample_data*: the object's `sampleData` data frame.
#' - *sample_data_links*: the content of the object's `@sampleDataLinks` slot
#'   defining the mapping between rows in `sampleData` and other entities in
#'   the object, such as e.g. spectra.
#' - *sample_data_links_mcols*: the metadata content of the `@sampleDataLinks`.
#' - *spectra*: the [Spectra::Spectra] object with the MS data (if present).
#'   The respective [SpectraStash::SpectraStash] functionality is used to
#'   export this data.
#'   Note that not all `MsBackend` types might be supported. In that case,
#'   the backend should be switched to one of the `MsBackend`s from the
#'   *Spectra* package using the [Spectra::setBackend()] function.
#'
#' @note
#'
#' Overwriting an existing *MsExperimentStash* is not allowed.
#'
#' Serializing `MsExperiment` objects containing a `QFeatures` object is
#' currently not supported.
#'
#' The *plain text file-based* stash is currently not supported.
#'
#' @param object A `MsExperiment` object.
#'
#' @param param The parameter object to select and configure the stash format.
#'     Either [MsStash::AlabasterParam] or [MsStash::PlainTextParam].
#'
#' @param path For `saveObject()`:
#'
#' @param x A `MsExperiment` object.
#'
#' @param ... For `saveMsObject()`: optional arguments passed down to the
#'     `saveMsObject()` function to stash the `Spectra` object (if present),
#'     such as `consolidate`. For `readMsObject()`: optional arguments for the
#'     `readMsObject()` call to restore the `Spectra` object (such as
#'     `spectraPath`). See [SpectraStash::SpectraStash] for more information.
#'
#' @author Philippine Louail, Johannes Rainer
#'
#' @examples
#'
#' ## Example MS data files
#' library(Spectra)
#' library(MsExperiment)
#' library(MsDataHub)
#' fls <- c(X20171016_POOL_POS_1_105.134.mzML(),
#'     X20171016_POOL_POS_3_105.134.mzML())
#'
#' ## Create a MsExperiment for the two example files
#' mse <- readMsExperiment(fls, data.frame(name = c("A", "B"), index = 1:2))
#'
#' ## Define the path where to create the MsExperimentStash
#' d <- file.path(tempdir(), "ms_experiment_stash")
#'
#' ## Save the MsExperiment to a stash in alabaster format; Note: with
#' ## `consolidate = TRUE` the MS data files are also copied into the
#' ## stash
#' saveMsObject(mse, AlabasterParam(d), consolidate = TRUE)
#'
#' ## Show the content of the stash folder
#' library(fs)
#' dir_tree(d)
#'
#' ## Restore the object from the stash
#' res <- readMsObject(MsExperiment(), AlabasterParam(d))
#' res
#'
#' sampleData(res)
#'
#' spectra(res)
NULL

################################################################################
##    PlainTextParam
################################################################################

## Can not yet export everything... just the barebones part.

################################################################################
##    AlabasterParam
################################################################################

#' @rdname MsExperimentStash
#'
#' @author Philippine Louail, Johannes Rainer
setMethod("saveObject", "MsExperiment", function(x, path, ...) {
    if (inherits(x@qdata, "QFeatures"))
        stop("Saving of an 'MsExperiment' with an object of type 'QFeatures'",
             " in the qdata slot is currently not supported.", call. = FALSE)
    if (inherits(x@qdata, "SummarizedExperiment") &&
        !.is_alabaster_se_installed())
        stop("Required package 'alabaster.se' for export of ",
             "'SummarizedExperiment' objects missing. Please install and ",
             "try again.", call. = FALSE)
    if (length(x@sampleDataLinks) > 0 && !.is_alabaster_matrix_installed())
        stop("Required package 'alabaster.matrix' missing. Please install and ",
             "try again.", call. = FALSE)
    dir.create(path = path, recursive = TRUE, showWarnings = FALSE)
    saveObjectFile(path, "ms_experiment")
    if (length(x@spectra)) {
        if (!.is_spectra_stash_installed())
            stop("Required package 'SpectraStash' missing. Please install and ",
                 "try again.", call. = FALSE)
        altSaveObject(x@spectra, path = file.path(path, "spectra"), ...)
    }
    altSaveObject(x@sampleData, path = file.path(path, "sample_data"))
    altSaveObject(x@sampleDataLinks,path = file.path(path, "sample_data_links"))
    altSaveObject(x@sampleDataLinks@elementMetadata,
                  path = file.path(path, "sample_data_links_mcols"))
    altSaveObject(x@metadata, path = file.path(path, "metadata"))
    if (length(x@qdata))
        altSaveObject(x@qdata, path = file.path(path, "qdata"))
    altSaveObject(x@experimentFiles, path = file.path(path, "experiment_files"))
    ## - otherData: call saveObject and hope for the best.
    tryCatch({
        do.call(altSaveObject,
                list(x = x@otherData, path = file.path(path, "other_data")))
    }, error = function(e) {
        stop("failed to save '@otherData' of ", class(x)[1L], "\n - ",
             e$message, call. = FALSE)
    })
})

validateAlabasterMsExperiment <- function(path = character(),
                                          metadata = list()) {
    .check_directory_content(path, c("sample_data", "sample_data_links",
                                     "sample_data_links_mcols", "metadata",
                                     "experiment_files", "other_data"))
}

#' @importFrom alabaster.base readObjectFile
#'
#' @importFrom MsExperiment MsExperiment
#'
#' @importClassesFrom S4Vectors SimpleList
#'
#' @importFrom methods validObject
#'
#' @noRd
readAlabasterMsExperiment <- function(path = character(), metadata = list(),
                                      ...) {
    validateAlabasterMsExperiment(path, metadata)
    res <- MsExperiment()
    if (!.is_alabaster_matrix_installed())
        stop("Required package 'alabaster.matrix' not available. Please ",
             "install and try again.", call. = FALSE)
    if (file.exists(file.path(path, "spectra"))) {
        if (!.is_spectra_stash_installed())
            stop("Required package 'SpectraStash' not available. Please ",
                 "install and try again.", call. = FALSE)
        res@spectra <- altReadObject(file.path(path, "spectra"), ...)
    } else res@spectra <- NULL
    i <- altReadObject(file.path(path, "sample_data"))
    res@sampleData <- i
    i <- as(lapply(altReadObject(file.path(path, "sample_data_links")),
                   as.matrix), "SimpleList")
    i@elementMetadata <- altReadObject(
        file.path(path, "sample_data_links_mcols"))
    res@sampleDataLinks <- i
    i <- altReadObject(file.path(path, "metadata"))
    res@metadata <- i
    if (file.exists(file.path(path, "qdata"))) {
        qdata_obj <- readObjectFile(file.path(path, "qdata"))
        if (qdata_obj$type[1L] == "summarized_experiment") {
            if (!.is_alabaster_se_installed())
                stop("Required package 'alabaster.se' not available. Please ",
                     "install and try again.", call. = FALSE)
            i <- altReadObject(file.path(path, "qdata"))
        } else stop("Data of type \"", qdata_obj$type, "\" can currently not ",
                    "be imported.")
        res@qdata <- i
    } else res@qdata <- NULL
    i <- altReadObject(file.path(path, "experiment_files"))
    res@experimentFiles <- i
    i <- as(altReadObject(file.path(path, "other_data")), "SimpleList")
    res@otherData <- i
    validObject(res)
    res
}

#' @rdname MsExperimentStash
setMethod("saveMsObject", signature(object = "MsExperiment",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              saveObject(object, param@path, ...)
          })

#' @rdname MsExperimentStash
setMethod("readMsObject", signature(object = "MsExperiment",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readAlabasterMsExperiment(path = param@path, ...)
          })
