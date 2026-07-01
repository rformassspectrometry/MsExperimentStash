test_that(".check_directory_content works", {
    expect_error(.check_directory_content(tempdir(), "my_file"), "not found")
    file.create(file.path(tempdir(), "my_file"))
    expect_no_error(.check_directory_content(tempdir(), "my_file"))
    unlink(file.path(tempdir(), "my_file"))
})

test_that(".check_overwriting works", {
    expect_error(.check_overwriting(tempdir()), "contains already")
    expect_no_error(.check_overwriting(file.path(tempdir(), "a")))
})

test_that(".is_alabaster_matrix_installed works", {
    expect_true(.is_alabaster_matrix_installed())
})

test_that(".is_spectra_stash_installed works", {
    expect_true(.is_spectra_stash_installed())
})

test_that(".is_alabaster_se_installed works", {
    expect_true(.is_alabaster_se_installed())
})
