library(pkgload)
test_that("test .onLoad", {
    ## collect options before and after loading the package
    ## use different R subprocesses based on loading context
    option_output <- {
        if (!is_dev_package("MsExperimentStash") || testthat:::in_covr()) {
            callr::r(function() {
                preOpts <- options()
                library(MsExperimentStash)
                testthat::expect_no_error(MsExperimentStash:::.onLoad())
                postOpts <- options()
                list(preOpts = preOpts, postOpts = postOpts)
            })
        } else if (is_dev_package("MsExperimentStash")) {
            callr::r(function() {
                preOpts <- options()
                load_all()
                testthat::expect_no_error(MsExperimentStash:::.onLoad())
                postOpts <- options()
                list(preOpts = preOpts, postOpts = postOpts)
            })
        }
    }
    expect_type(option_output, "list")
})
