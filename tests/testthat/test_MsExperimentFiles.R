test_that("saveObject,readObject,MsExperimentFiles works", {
    d <- file.path(tempdir(), "test")

    a <- MsExperimentFiles()

    expect_no_error(saveObject(a, path = d))
    expect_true(all(c("OBJECT", "x") %in% dir(d)))
    expect_silent(validateAlabasterMsExperimentFiles(d))
    res <- readAlabasterMsExperimentFiles(d)
    expect_s4_class(res, "MsExperimentFiles")
    expect_equal(a, res)

    expect_error(saveObject(a, d), "at existing path")
    unlink(d, recursive = TRUE)

    a <- MsExperimentFiles(list(some_file = "a.txt",
                                some_other_file = c("b.txt", "c.txt")))
    saveObject(a, d)
    expect_silent(validateAlabasterMsExperimentFiles(d))
    res <- readObject(d)
    expect_s4_class(res, "MsExperimentFiles")
    expect_equal(a, res)

    unlink(d, recursive = TRUE)
})

test_that("saveMsObject/readMsObject,MsExperimentFiles,AlabasterParam works", {
    d <- file.path(tempdir(), "test")

    a <- MsExperimentFiles(list(library = c("gnps.mgf", "hmdb.mgf"),
                                input = c("test.mgf")))
    expect_no_error(saveMsObject(a, AlabasterParam(d)))
    res <- readMsObject(a, AlabasterParam(d))
    expect_equal(a, res)

    unlink(d, recursive = TRUE)
})

test_that("saveMsObject/readMsObject,MsExperimentFiles,PlainTextParam works", {
    d <- file.path(tempdir(), "test")

    p <- PlainTextParam(d)
    expect_error(readMsObject(MsExperimentFiles(), p), "not found in")

    a <- MsExperimentFiles()
    expect_no_error(saveMsObject(a, p))
    expect_true("ms_experiment_files.txt" %in% dir(d))
    res <- readMsObject(MsExperimentFiles(), p)
    expect_equal(a, res)

    a <- MsExperimentFiles(list(library = c("gnps.mgf", "hmdb.mgf"),
                                input = c("test.mgf")))
    expect_error(saveMsObject(a, p), "provided path contains")

    unlink(d, recursive = TRUE)
    expect_no_error(saveMsObject(a, p))
    expect_no_error(res <- readMsObject(a, p))
    expect_equal(a, res)

    unlink(d, recursive = TRUE)
})
