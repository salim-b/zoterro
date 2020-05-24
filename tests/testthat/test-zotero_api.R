context("Simple requests")

test_that("Request using user id", {
  skip("interactive only")
  r <- zotero_get(
    path = "collections/top"
  )
})

test_that("Request using group id", {
  skip("interactive only")
  r <- zotero_get(
    path = "collections/top",
    user = zotero_group_id(2389504)
  )
})


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
