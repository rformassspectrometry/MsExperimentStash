#' @title Stash for `MsExperimentFiles`
#'
#' @name MsExperimentFilesStash
#'
#' @description
#'
#' The [MsExperiment::MsExperimentFiles] class stores files (or rather file
#' names) that are part of a mass spectrometry experiment.
#'
#' The supported stash formats for `MsExperimentFiles` objects are listed in
#' the sections below.
#'
#' @section Text-file format, `PlainTextParam`:
#'
#' The text-file format stash folder for `MsExperimentFile` objects contains
#' a file *ms_experiment_files.txt* with two tabulator separated columns *name*
#' and *files*. Each row (except the first) is one element of the
#' `MsExperimentFile`, the first defining the object's names and the second
#' its content, which represents a characted vector with the file name(s),
#' separated by a `"|"` (if more than one).
#'
#' @section *alabaster*-based format, `AlabasterParam`:
#'
#' The `MsExperimentFiles` stash folder contains the alabaster-specific
#' *OBJECT* file and a sub-folder *x* with the `MsExperimentFiles`
#' content serialized by *alabaster.base*.
#'
#' @param object An `MsExperimentFiles` object.
#'
#' @param param An [MsStash::AlabasterParam] or [MsStash::PlainTextParam].
#'
#' @param path For `saveObject()`: `character(1)` with the path where the
#'     object should be stored into.
#'
#' @param x An `MsExperimentFiles` object.
#'
#' @param ... Currently ignored.
#'
#' @return `readMsObject()` returns a [MsExperiment::MsExperimentFiles] object.
#'
#' @author Johannes Rainer
#'
#' @examples
#'
#' library(MsExperiment)
#'
#' fls <- MsExperimentFiles(list(input = c("file.mzML", "file2.mgf")))
#'
#' ## Define the path to the stash
#' d <- file.path(tempdir(), "ms_file_stash")
#'
#' ## Stash the object in alabaster format
#' saveMsObject(fls, AlabasterParam(d))
#'
#' ## The content of the stash: subfolder x contains the *character list*
#' ## saved through the *alabaster.base* package.
#' library(fs)
#' dir_tree(d)
#'
#' ## Restore the object from stash
#' res <- readMsObject(MsExperimentFiles(), AlabasterParam(d))
#' res
#'
#' ## In addition, it is possible to read the object also with the
#' ## *alabaster.base* functionality
#' library(alabaster.base)
#' res <- readObject(d)
NULL

################################################################################
##    PlainTextParam
################################################################################

#' @importClassesFrom MsStash PlainTextParam
#'
#' @importFrom utils write.table
#'
#' @rdname MsExperimentFilesStash
setMethod("saveMsObject", signature(object = "MsExperimentFiles",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              dir.create(path = param@path, recursive = TRUE,
                         showWarnings = FALSE)
              .check_overwriting(
                  file.path(param@path, "ms_experiment_files.txt"))
              if (length(object))
                  d <- data.frame(
                      name = names(object),
                      files = vapply(object, paste0, "", collapse = "|",
                                     USE.NAMES = FALSE))
              else d <- data.frame(name = character(), files = character())
              write.table(
                  d, file = file.path(param@path, "ms_experiment_files.txt"),
                  sep = "\t", row.names = FALSE)
          })

#' @importFrom MsExperiment MsExperimentFiles
#'
#' @importFrom utils read.table
#'
#' @rdname MsExperimentFilesStash
setMethod("readMsObject", signature(object = "MsExperimentFiles",
                                    param = "PlainTextParam"),
          function(object, param, ...) {
              .check_directory_content(param@path, c("ms_experiment_files.txt"))
              d <- read.table(file.path(param@path, "ms_experiment_files.txt"),
                              sep = "\t", header = TRUE)
              if (nrow(d)) {
                  l <- strsplit(d[, 2L], "|", fixed = TRUE)
                  names(l) <- d[, 1L]
                  MsExperimentFiles(l)
              } else MsExperimentFiles()
          })

################################################################################
##    AlabasterParam
################################################################################

#' @importMethodsFrom alabaster.base saveObject
#'
#' @importFrom alabaster.base altSaveObject
#'
#' @importFrom alabaster.base saveObjectFile
#'
#' @importClassesFrom MsExperiment MsExperimentFiles
#'
#' @rdname MsExperimentFilesStash
#'
#' @exportMethod saveObject
setMethod("saveObject", "MsExperimentFiles", function(x, path, ...) {
    dir.create(path = path, recursive = TRUE, showWarnings = FALSE)
    saveObjectFile(path, "ms_experiment_files")
    altSaveObject(as(x, "SimpleCharacterList"), file.path(path, "x"))
})

validateAlabasterMsExperimentFiles <- function(path = character(),
                                               metadata = list()) {
    .check_directory_content(path, c("x"))
}

#' @importFrom alabaster.base altReadObject
#'
#' @importFrom methods as
#'
#' @noRd
readAlabasterMsExperimentFiles <- function(path = character(),
                                           metadata = list(), ...) {
    validateAlabasterMsExperimentFiles(path, metadata)
    res <- as(altReadObject(file.path(path, "x")), "SimpleCharacterList")
    as(res, "MsExperimentFiles")
}

#' @rdname MsExperimentFilesStash
#'
#' @importMethodsFrom MsStash saveMsObject
#'
#' @importClassesFrom MsStash AlabasterParam
setMethod("saveMsObject", signature(object = "MsExperimentFiles",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              saveObject(object, path = param@path)
          })

#' @rdname MsExperimentFilesStash
#'
#' @importMethodsFrom MsStash readMsObject
setMethod("readMsObject", signature(object = "MsExperimentFiles",
                                    param = "AlabasterParam"),
          function(object, param, ...) {
              readAlabasterMsExperimentFiles(path = param@path)
          })

################################################################################
##    Utility functions
################################################################################
