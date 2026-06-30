library(SummarizedExperiment)
library(Spectra)
library(mzR)
fls <- c(MsDataHub::X20171016_POOL_POS_1_105.134.mzML(),
         MsDataHub::X20171016_POOL_POS_3_105.134.mzML())

test_that("MsExperiment alabaster stash works", {
    d <- file.path(tempdir(), "test_stash")

    ## Empty object
    a <- MsExperiment()

    expect_no_error(saveObject(a, d))
    expect_true(all(c("OBJECT", "experiment_files", "metadata", "other_data",
                      "sample_data", "sample_data_links",
                      "sample_data_links_mcols") %in% dir(d)))
    res <- readObject(d)
    expect_equal(a, res)
    expect_error(saveObject(a, d), "existing path")
    unlink(d, recursive = TRUE)

    ## With SummarizedExperiment, but no Spectra
    se <- SummarizedExperiment(
        matrix(rnorm(12), nrow = 3, ncol = 4),
        rowData = data.frame(ri = 1:3, rn = c("a", "b", "c")),
        colData = data.frame(ci = 1:4, cn = c("A", "B", "C", "D")))
    rownames(se) <- c("a", "b", "c")
    colnames(se) <- c("A", "B", "C", "D")
    assayNames(se) <- "raw"
    qdata(a) <- se
    expect_no_error(saveObject(a, d))
    expect_true("qdata" %in% dir(d))
    res <- readObject(d)
    res_se <- qdata(res)
    expect_equal(colData(se), colData(res_se))
    expect_equal(rowData(se), rowData(res_se))
    expect_equal(assay(se), as.matrix(assay(res_se)))
    unlink(d, recursive = TRUE)

    ## With Spectra but no other data
    s <- Spectra(fls)
    a <- MsExperiment(spectra = s)
    expect_no_error(saveObject(a, d))
    expect_true("spectra" %in% dir(d))
    res <- readObject(d)
    expect_equal(mz(spectra(res)), mz(spectra(a)))
    expect_equal(rtime(spectra(res)), rtime(spectra(a)))
    expect_equal(msLevel(spectra(res)), msLevel(spectra(a)))
    unlink(d, recursive = TRUE)

    expect_no_error(saveObject(a, d, consolidate = TRUE))
    res <- readObject(d)
    expect_equal(normalizePath(file.path(d, "spectra", "backend")),
                 dataStorageBasePath(spectra(res)))
    unlink(d, recursive = TRUE)

    ## Spectra and SummarizedExperiment
    qdata(a) <- se
    expect_no_error(saveObject(a, d))
    res <- readObject(d)
    expect_equal(rowData(qdata(a)), rowData(qdata(res)))
    expect_equal(rtime(spectra(a)), rtime(spectra(res)))
    unlink(d, recursive = TRUE)

    ## SampleData
    a <- MsExperiment()
    sampleData(a) <- as(data.frame(name = c("a", "b"), idx = 1:2), "DataFrame")
    expect_no_error(saveObject(a, d))
    res <- readObject(d)
    expect_equal(sampleData(a), sampleData(res))
    unlink(d, recursive = TRUE)

    ## SampleData with links
    a <- readMsExperiment(
        fls, sampleData = data.frame(name = c("a", "b"), idx = 1:2))
    expect_no_error(saveObject(a, d))
    res <- readObject(d)
    expect_equal(sampleData(a), sampleData(res))
    expect_equal(spectraSampleIndex(a), spectraSampleIndex(res))
    expect_equal(a@sampleDataLinks, res@sampleDataLinks)

    unlink(d, recursive = TRUE)

    ############################################################################
    ## Errors
    ## save errors
    library(QFeatures)
    a <- MsExperiment()
    qdata(a) <- QFeatures()
    expect_error(saveObject(a, d), "currently not supported")
    a <- MsExperiment()
    a@otherData[[1L]] <- lm(y ~ x, data.frame(y = 1:3, x = 1:3))
    expect_error(saveObject(a, d), "otherData")
    unlink(d, recursive = TRUE)

    qdata(a) <- se
    with_mocked_bindings(
        ".is_alabaster_se_installed" = function() FALSE,
        code = expect_error(saveObject(a, d),
                            "'SummarizedExperiment' objects")
    )

    a <- readMsExperiment(
        fls, sampleData = data.frame(name = c("a", "b"), idx = 1:2))
    if (dir.exists(d)) unlink(d, recursive = TRUE)
    with_mocked_bindings(
        ".is_alabaster_matrix_installed" = function() FALSE,
        code = expect_error(saveObject(a, d),
                            "'alabaster.matrix' missing")
    )
    if (dir.exists(d)) unlink(d, recursive = TRUE)
    with_mocked_bindings(
        ".is_spectra_stash_installed" = function() FALSE,
        code = expect_error(saveObject(a, d),
                            "'SpectraStash' missing")
    )
    if (dir.exists(d)) unlink(d, recursive = TRUE)
    ## read errors
    qdata(a) <- se
    expect_no_error(saveObject(a, d))
    with_mocked_bindings(
        ".is_alabaster_matrix_installed" = function() FALSE,
        code = expect_error(readObject(d),
                            "'alabaster.matrix' not available")
    )
    with_mocked_bindings(
        ".is_spectra_stash_installed" = function() FALSE,
        code = expect_error(readObject(d),
                            "'SpectraStash' not available")
    )
    with_mocked_bindings(
        ".is_alabaster_se_installed" = function() FALSE,
        code = expect_error(readObject(d),
                            "'alabaster.se' not available")
    )
    readObjectFile(file.path(d, "qdata"))
    saveObjectFile(file.path(d, "qdata"), "some_other")
    expect_error(readObject(d), "can currently not")

    unlink(d, recursive = TRUE)
})

test_that("readMsObject,saveMsObject,MsExperiment,AlabasterParam works", {
    d <- file.path(tempdir(), "test_stash")

    p <- AlabasterParam(d)
    a <- readMsExperiment(fls, data.frame(name = c("A", "B"), index = 1:2))
    expect_no_error(saveMsObject(a, p, consolidate = TRUE))
    res <- readMsObject(MsExperiment(), p)
    expect_s4_class(res, "MsExperiment")
    expect_equal(rtime(spectra(a)), rtime(spectra(res)))
    expect_equal(normalizePath(dataStorageBasePath(spectra(res))),
                 normalizePath(file.path(d, "spectra", "backend")))

    unlink(d, recursive = TRUE)
})
