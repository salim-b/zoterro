# define Zotero group IDs for testing
public_group_id <- zotero_group_id(197065)
private_group_id <- zotero_group_id(2124500)

skip_if_no_defaults <- function() {
  skip_if(try(zotero_usr(), silent = TRUE) %>% inherits(what = "try-error"))
  skip_if_not(is_api_key_valid(api_key = zotero_key(),
                               url = "https://api.zotero.org"))
}

# Simple requests ----

test_that("Request using default user ID and API key", {
  skip_if_no_defaults()
  expect_s3_class(
    zotero_get(url = paste0("https://api.zotero.org/users/", zotero_usr(), "/collections/top"),
               user = zotero_usr(),
               api_key = zotero_key()),
    "response"
  )
})

test_that("Request using public group ID", {
  expect_s3_class(
    zotero_get(
      url = paste0("https://api.zotero.org/groups/", public_group_id, "/collections/top"),
      user = public_group_id
    ),
    "response"
  )
})


# Basic API requests ----

test_that("Fetching group IDs with default user ID and API key works", {
  skip_if_no_defaults()
  r <- zotero_api(
    path = "groups",
    query = NULL
  )
  expect_type(r, "list")
  expect_gte(length(r), 1)
})

test_that("Fetching all collections from public group works", {
  r <- zotero_api(
    path = "collections",
    user = public_group_id,
    query = NULL
  )
  expect_type(r, "list")
  expect_gte(length(r), 1)
})

test_that("Fetching exact number of results works", {
  r <- zotero_api(
    path = "items",
    user = public_group_id,
    query = list(limit = 2),
    fetch_subsequent = FALSE
  )
  expect_type(r, "list")
  expect_length(r, 2)
})


# API error handling ----

test_that("Error: Different API key required", {
  skip_if_no_defaults()
  expect_error(
    zotero_api(
      path = "/collections",
      user = private_group_id
    ),
    regexp = "(?i)You need to provide a different API key"
  )
})

test_that("Error: 404", {
  skip_if_no_defaults()
  expect_error(
    zotero_api(
      path = "/collections",
      user = zotero_group_id(9999999999)
    ),
    regexp = "(?i)Request repeatedly failed.*Not Found"
  )
})

test_that("Error: Invalid API key", {
  skip_if_no_defaults()
  expect_error(
    zotero_api(
      path = "/collections",
      user = zotero_group_id(private_group_id),
      api_key = "nope"
    ),
    regexp = "(?i)Provided API key .*is invalid"
  )
})

test_that("Error: Missing API key", {
  skip_if_no_defaults()
  expect_error(
    zotero_api(
      path = "/collections",
      user = private_group_id,
      api_key = NULL
    ),
    regexp = "(?i)Missing API key"
  )
})
