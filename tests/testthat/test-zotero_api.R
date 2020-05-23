context("Basic API requests")

test_that("fetching group IDs works", {
  skip("interactive only")
  r <- zotero_api(
    path = paste("users", zotero_usr(), "groups", sep="/"),
    query = NULL
  )
})



test_that("fetching all collections", {
  skip("interactive only")
  r <- zotero_api(
    path = paste("users", zotero_usr(), "collections", sep="/"),
    query = NULL
  )
})
