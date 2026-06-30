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
#' @section *alabaster*-based format, `AlabasterParam`:
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
#' @section Text-file format, `PlainTextParam`:
#'
#' `MsExperiment` objects can also be saved to plain text files as a
#' MsExperimentStash in text file format. Note however that currently only some
#' of the object's content can be saved in that format. Content of slots
#' `@qdata`, `@metadata` and `@otherData` (if present) are **not** stored to the
#' stash. The text file-based stash directory contains the following files:
#'
#' - *ms_experiment_sample_data.txt*: tabulator delimited text file with the
#'   content of the `MsExperiment`'s `sampleData()`. This file is always saved.
#' - *ms_experiment_sample_data_links_<linked slot>.txt*: a two column
#'   tab-delimited text file with the mapping between rows in `sampleData()` and
#'   elements in other slots of the `MsExperiment`. The name of the respective
#'   slot is used as file name suffix. This file is only generated when *sample
#'   data links* are present.
#' - *ms_experiment_link_mcols.txt*: tab-delimited text file with the metadata
#'   content of the `@sampleDataLink` slot. This file is only generated when
#'   *sample data links* are present.
#' - *ms_experiment_files.txt*: the object's [MsExperiment::MsExperimentFiles].
#'   See [MsExperimentFilesStash] for information on the format. This file is
#'   only generated if `experimentFiles()` are present in the object.
#'
#' If the `MsExperiment` contained a [Spectra::Spectra] object, it is saved
#' to the main *MsExperimentStash* folder. A different set of files might be
#' stored, depending on the `MsBackend` used. This can also include raw MS data
#' files if parameter `consolidate = TRUE` is used in `saveMsObject()`.
#' See [SpectraStash::SpectraStash] for more information.
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

#' @author Philippine Louail
#'
#' @importMethodsFrom MsExperiment spectra
#'
#' @importFrom MsExperiment experimentFiles
#'
#' @rdname MsExperimentStash
setMethod("saveMsObject", signature(object = "MsExperiment",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              dir.create(path = param@path, recursive = TRUE,
                         showWarnings = FALSE)
              .check_overwriting(
                  file.path(param@path, "ms_experiment_sample_data.txt"))
              ## sample data
              sdata <- object@sampleData
              if (!length(sdata)) # initialize with empty data frame
                  sdata <- DataFrame(sample_name = character())
              write.table(as.data.frame(sdata), sep = "\t",
                          file = file.path(param@path,
                                           "ms_experiment_sample_data.txt"))
              ## sample data links
              sdl <- object@sampleDataLinks
              if (length(sdl) > 0) {
                  lapply(names(sdl), function(x){
                      fl <- file.path(
                          param@path,
                          paste0("ms_experiment_sample_data_links_", x, ".txt"))
                      write.table(sdl[[x]], file = fl, row.names = FALSE,
                                  col.names = FALSE, sep = "\t")
                  })
                  write.table(
                      sdl@elementMetadata, sep = "\t", quote = TRUE,
                      file = file.path(param@path,
                                       "ms_experiment_link_mcols.txt"))
              }
              ## call export of individual other objects (not MsExperiment data)
              if (length(spectra(object))) {
                  if (!.is_spectra_stash_installed())
                      stop("Required package 'SpectraStash' for export of ",
                           "'Spectra' objects missing. Please install and ",
                           "try again.", call. = FALSE)
                  saveMsObject(spectra(object), param, ...)
              }
              if (length(experimentFiles(object)))
                  saveMsObject(experimentFiles(object), param)
          })

#' @rdname MsExperimentStash
#'
#' @importFrom S4Vectors DataFrame
#'
#' @importFrom S4Vectors SimpleList
#'
#' @importFrom Spectra Spectra
#'
#' @author Philippine Louail
#'
#' @importMethodsFrom S4Vectors mcols<-
setMethod("readMsObject", signature(object = "MsExperiment",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              ## read sample data
              fl <- file.path(param@path, "ms_experiment_sample_data.txt")
              .check_directory_content(
                  param@path, "ms_experiment_sample_data.txt")
              sd <- read.table(fl, sep = "\t", header = TRUE)
              if (is.character(all.equal(rownames(sd),
                                         as.character(seq_len(nrow(sd))))))
                  object@sampleData <- DataFrame(sd)
              else
                  object@sampleData <- DataFrame(sd, row.names = NULL)

              ## read spectra
              if (file.exists(file.path(param@path, "spectra_slots.txt"))) {
                  if (!.is_spectra_stash_installed())
                      stop("Required package 'SpectraStash' not available. ",
                           "Please install and try again.", call. = FALSE)
                  object@spectra <- readMsObject(Spectra(), param, ...)
              }
              ## sample data links
              fl <- list.files(
                  param@path,
                  pattern = "ms_experiment_sample_data_links_.*\\.txt",
                  full.names = TRUE)
              if (length(fl) > 0) {
                  n <- gsub("ms_experiment_sample_data_links_|\\.txt", "",
                            basename(fl))
                  sdl <- lapply(fl, function(x) {
                      unname(as.matrix(read.table(x, sep = "\t")))
                  })
                  names(sdl) <- n
                  object@sampleDataLinks <- SimpleList(sdl)
                  em <- read.table(file.path(param@path,
                                             "ms_experiment_link_mcols.txt"),
                                   sep = "\t", header = TRUE)
                  mcols(object@sampleDataLinks) <- DataFrame(
                      em, row.names = NULL)
              }
              if (file.exists(file.path(param@path, "ms_experiment_files.txt")))
                  object@experimentFiles <- readMsObject(MsExperimentFiles(),
                                                         param)
              validObject(object)
              object
          })

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

################################################################################
##    utility functions
################################################################################

#' Compile and print warnings when export of content/slots of the submitted
#' `MsExperiment` are not supported.
#'
#' `MsExperiment` slots:
#'
#' - `@experimentFiles`: use `saveMsObject()` with `PlainTextParam`.
#' - `@spectra`: use `saveMsObject()` with `PlainTextParam`.
#' - `@qdata`: warning if present.
#' - `@otherData`: warning if present.
#' - `@sampleData`: write using internal functionality
#' - `@sampleDataLinkg`: write using internal functionality
#' - `@metadata`: warning if present.
#'
#' @param x `MsExperiment` object
#'
#' @noRd
.warnings_text_format <- function(x) {
    msg <- NULL
    if (length(x@qdata))
        msg <- paste0(
            "\n Skipping content of the 'qdata' slot: saving '",
            class(x@qdata)[1L], "' objects to text format is not ",
            "supported.")
    if (length(x@otherData))
        msg <- c(msg,
                 paste0("\n Skipping content of the 'otherData' slot: saving '",
                        class(x@otherData[[1L]])[1L], "' objects to text ",
                 "format is not supported."))
    if (length(x@metadata))
        msg <- c(msg,
                 paste0("\n Skipping content of the 'metadata' slot: saving '",
                        class(x@metadata[[1L]])[1L], "' objects to text ",
                 "format is not supported."))
    if (length(msg))
        warning(msg, call. = FALSE, immediate. = TRUE)
}
