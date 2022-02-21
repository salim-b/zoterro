test_that("items list to tibble conversion is idempotent", {
  r <- collection_items(
    key = "MSNU4A4F",
    user = zotero_group_id(id = 197065),
    as_tibble = FALSE
  )

  expect_equal(r %>% as_item_tibble(),
               r %>% as_item_tibble() %>% as_item_tibble())
})
