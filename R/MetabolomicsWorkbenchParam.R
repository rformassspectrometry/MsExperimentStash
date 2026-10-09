#' @title Load Content from a Metabolomics Workbench Study
#'
#' @name MwbParam
#'
#' @description
#'
#' The `MwbParam` class and the associated `readMsObject()` method
#' allow users to load an [MsExperiment::MsExperiment] object from a study in
#' the Metabolomics Workbench database (https://metabolomicsworkbench.org/) by
#' providing its unique study identifier (parameter `mwbId`). This function
#' is particularly useful for directly importing metabolomics data (MS data and
#' experimental metadata) into an `MsExperiment` object for further analysis
#' in the R environment.
#'
#' It is important to note that at present it is only possible to *read*
#' (import) data from Metabolomics Workbench, but not to *save* data to
#' Metabolomics Workbench.
#'
#' If the study contains multiple analyses, the user will be prompted to select
#' which analysis to load. The resulting `MsExperiment` object will include a
#' `sampleData` slot populated with data extracted from the selected analysis.
#'
#' The resulting `MsExperiment` object will include a `sampleData` slot
#' populated with data extracted from the Metabolomics Workbench metadata.
#'
#' Further filtering can be performed using the `filePattern` parameter of the
#' `MwbParam` object. The default for this parameter is
#' `"mzML$|CDF$|cdf$|mzXML$"`, which corresponds to the supported raw data file
#' types.
#'
#' @param object For `readMsObject()`: a `MsExperiment` instance.
#'
#' @param param For `readMsObject()`: a `MwbParam` object.
#'
#' @param mwbId `character(1)` The Metabolomics Workbench study ID, which should
#'     start with "ST". This identifier uniquely specifies the study within
#'     the Metabolomics Workbench database.
#'
#' @param analysisId `character(1)` The Metabolomics Workbench analysis ID,
#'     which should start with "AN". This identifier uniquely specifies the
#'     analysis within the Metabolomics Workbench database.
#'
#' @param filePattern `character(1)` A regular expression pattern to filter the
#'     raw data files associated with the selected assay. The default value is
#'     `"mzML$|CDF$|cdf$|mzXML$"`, corresponding to the supported raw data file
#'     types.
#'
#' @param ... Currently ignored.
#'
#' @return `readMsObject()` returns an `MsExperiment` object with the
#'     `sampleData()` populated with Metabolomics Workbench sample information
#'     and the experiment's MS data loaded as a [Spectra::Spectra] object.
#'
#' @author Gabriele Tomè
#'
#' @importFrom methods new
#'
#' @importClassesFrom ProtGenerics Param
#'
#' @seealso
#' - [MsExperiment::MsExperiment] object.
#'
#' - [MsBackendMetabolomicsWorkbench::MsBackendMetabolomicsWorkbench] for
#'   retrieving MS data files from Metabolomics Workbench
#'
#' - [Metabolomics Workbench](https://metabolomicsworkbench.org/) for accessing
#'   the Metabolomics Workbench database.
#'
#' @examples
#'
#' library(MsExperiment)
#' ## Load a study with the mwbId "ST002115" and selecting specific file
#' ## pattern as well as removing ontology and protocol information in the
#' ## metadata.
#' param <- MwbParam(mwbId = "ST002115", analysisId = "AN003513",
#'                   filePattern = "01_RP.mzXML")
#' ms_experiment <- readMsObject(MsExperiment(), param)
#' ms_experiment
#'
#' ## The object's sampleData contains information loaded from Metabolomics
#' ## Workbench
#' sampleData(ms_experiment)
#'
#' ## The MS data files were downloaded and cached; the data is available
#' ## through the object's `Spectra`
#' spectra(ms_experiment)
NULL

#' @noRd
setClass("MwbParam",
         slots = c(mwbId = "character",
                   analysisId = "character",
                   filePattern = "character"),
         contains = "Param",
         prototype = list(
             mwbId = character(1),
             analysisId = character(1),
             filePattern = character(1)
         ),
         validity = function(object) {
             msg <- NULL
             if (!grepl("^ST", object@mwbId))
                 msg <- c("'mwbId' must start with 'ST'")
             if (length(object@analysisId) && !grepl("^AN", object@analysisId))
                 msg <- c(msg, "'analysisId' must start with 'AN'")
             msg
         })

#' @rdname MwbParam
#'
#' @export
MwbParam <- function(mwbId = character(),
                        analysisId = character(),
                        filePattern = "mzML$|CDF$|cdf$|mzXML$") {
    new("MwbParam", mwbId = mwbId, analysisId = analysisId,
        filePattern = filePattern)
}

#' Function that takes the extra parameters and clean the metadata if asked by
#' the user.
#'
#' @author Gabriele Tomè
#'
#' @noRd
.clean_merged <- function(x, keepProtocol, keepOntology, simplify) {
    ## remove ontology
    if (!keepOntology)
        x <- x[, -which(grepl("Term", names(x))), drop = FALSE]
    ## remove protocol
    if (!keepProtocol)
        x <- x[, -which(grepl("Protocol|Parameter", names(x))),  drop = FALSE]
    ## remove duplicated columns contents and NAs
    if (simplify) {
        x <- x[, !duplicated(as.list(x)), drop = FALSE]
        x <- x[, colSums(is.na(x)) != nrow(x), drop = FALSE]
    }
    x
}
