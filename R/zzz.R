#' @importFrom alabaster.base registerValidateObjectFunction
#'
#' @importFrom alabaster.base registerReadObjectFunction
.onLoad <- function(libname, pkgname) {
    ## MsExperimentFiles
    registerValidateObjectFunction("ms_experiment_files",
                                   validateAlabasterMsExperimentFiles)
    registerReadObjectFunction("ms_experiment_files",
                               readAlabasterMsExperimentFiles)
    ## MsExperiment
    registerValidateObjectFunction("ms_experiment",
                                   validateAlabasterMsExperiment)
    registerReadObjectFunction("ms_experiment",
                               readAlabasterMsExperiment)

}
