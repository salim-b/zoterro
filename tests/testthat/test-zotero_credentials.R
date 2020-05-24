context("Creating url prefix")

test_that("Creating URL prefix for users", {
  u <- zotero_user_id(12345)
  expect_identical(url_prefix(u), "users/12345")
})
