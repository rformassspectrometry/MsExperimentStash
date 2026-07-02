test_that("MetaboLightsParam works", {
    expect_error(MetaboLightsParam(mtblsId = ")Qn"), "must start")
    ## Study with only one assay: MTBLS10035
    param <- MetaboLightsParam(mtblsId = "MTBLS39")
    expect_is(param, "MetaboLightsParam")
})

test_that(".clean_merged function works correctly", {
    tbc <- data.frame(
        Protocol_A = c(1, 2, 3),
        Term_B = c("ontology1", "ontology2", "ontology3"),
        Parameter_C = c(10, 20, 30),
        Term_D = c("ontology1", "ontology2", "ontology3"),
        Data_E = c(NA, NA, NA),
        Duplicate_F = c(1, 2, 3),
        stringsAsFactors = FALSE
    )
    result <- .clean_merged(tbc, keepProtocol = TRUE,
                            keepOntology = TRUE,
                            simplify = FALSE)
    expect_equal(names(result), names(tbc))

    result <- .clean_merged(tbc, keepProtocol = TRUE,
                            keepOntology = FALSE, simplify = FALSE)
    expect_equal(names(result), c("Protocol_A", "Parameter_C", "Data_E",
                                  "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = FALSE,
                            keepOntology = TRUE, simplify = FALSE)
    expect_equal(names(result), c("Term_B", "Term_D", "Data_E", "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = FALSE, keepOntology = FALSE,
                            simplify = FALSE)
    expect_equal(names(result), c("Data_E", "Duplicate_F"))

    result <- .clean_merged(tbc, keepProtocol = TRUE, keepOntology = TRUE,
                            simplify = TRUE)
    expect_equal(names(result), c("Protocol_A", "Term_B", "Parameter_C"))


    result <- .clean_merged(tbc, keepProtocol = FALSE, keepOntology = FALSE,
                            simplify = TRUE)
    expect_equal(names(result), "Duplicate_F")
})
