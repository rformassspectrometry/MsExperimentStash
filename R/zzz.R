#' @importFrom alabaster.base registerValidateObjectFunction
#'
#' @importFrom alabaster.base registerReadObjectFunction
.onLoad <- function(libname, pkgname) {
    ## MsExperimentFiles
    registerValidateObjectFunction("ms_experiment_files",
                                   validateAlabasterMsExperimentFiles)
    registerReadObjectFunction("ms_experiment_files",
                               readAlabasterMsExperimentFiles)
}
