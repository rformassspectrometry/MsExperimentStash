library(SummarizedExperiment)
library(Spectra)
library(mzR)
library(QFeatures) # for errors if a QFeatures is stored in the object
fls <- c(MsDataHub::X20171016_POOL_POS_1_105.134.mzML(),
         MsDataHub::X20171016_POOL_POS_3_105.134.mzML())

test_that("readMsObject,saveMsObject,MsExperiment,PlainTextParam works", {
    d <- file.path(tempdir(), "test_text")

    a <- MsExperiment()
    p <- PlainTextParam(d)
    expect_no_error(saveMsObject(a, p))
    expect_error(saveMsObject(a, p), "object stash")
    expect_true("ms_experiment_sample_data.txt" %in% dir(d))
    res <- readMsObject(MsExperiment(), p)
    expect_s4_class(res, "MsExperiment")
    unlink(d, recursive = TRUE)

    a <- readMsExperiment(fls, data.frame(name = c("A", "B"), index = 1:2))
    expect_no_error(saveMsObject(a, p, consolidate = TRUE))
    res <- readMsObject(a, p)
    expect_s4_class(res, "MsExperiment")
    expect_equal(sampleData(a), sampleData(res))
    expect_equal(a@sampleDataLinks, res@sampleDataLinks)
    expect_equal(rtime(spectra(a)), rtime(spectra(res)))
    expect_equal(normalizePath(d), dataStorageBasePath(spectra(res)))
    unlink(d, recursive = TRUE)

    expect_error(readMsObject(MsExperiment(), PlainTextParam(tempdir())),
                 "not found")
})

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

test_that(".warnings_text_format works", {
    a <- MsExperiment()
    expect_no_warning(.warnings_text_format(a))

    a@qdata <- SummarizedExperiment(matrix(rnorm(8), nrow = 2))
    expect_warning(.warnings_text_format(a), "SummarizedExperiment")

    a <- MsExperiment()
    a@otherData[[1L]] <- 1:3
    expect_warning(.warnings_text_format(a), "integer")

    a <- MsExperiment()
    a@metadata[[1L]] <- "a"
    expect_warning(.warnings_text_format(a), "character")

    a <- MsExperiment()
    a@otherData[[1L]] <- 1:3
    a@metadata[[1L]] <- "a"
    a@qdata <- SummarizedExperiment(matrix(rnorm(8), nrow = 2))
    .warnings_text_format(a)
})

test_that("readMsObject,MsExperiment,MetaboLightsParam works", {
    param <- MetaboLightsParam(mtblsId = "MTBLS39")
    res <- readMsObject(MsExperiment(), param)
    expect_is(res, "MsExperiment")
    expect_is(res@sampleData, "DataFrame")

    ## Test keepOntology and keepProtocol
    res_filtered <- readMsObject(MsExperiment(), param,
                                 keepOntology = FALSE,
                                 keepProtocol = FALSE)
    expect_lt(ncol(res_filtered@sampleData), ncol(res@sampleData))

    ## Test simplify flag removes columns with NAs and duplicated columns
    expect_true(all(colSums(is.na(res@sampleData)) != nrow(res@sampleData)))
    expect_true(any(duplicated(as.list(res@sampleData))) == FALSE)
})

test_that("MetaboLightsParam interactive session works", {
    ## Testing interactive sesh
    mock_param <- MetaboLightsParam(mtblsId = "MTBLS575")
    menu <- NULL
    with_mocked_bindings(
        menu = function(choices, title = NULL) { 3 },
        {
            result <- readMsObject(MsExperiment(), mock_param)
        }
    )
    expect_true(nrow(result@sampleData) == 6)
    expect_true(ncol(result@sampleData) == 30)
})
