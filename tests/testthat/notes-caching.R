id <- zotero_group_id(269768)

# Fetch my publications
u <- "https://api.zotero.org/users/311682/publications/items"

r <- GET(
  url = u,
  config = add_headers(
    "Zotero-API-Key" = zotero_key(),
    "Zotero-API-Version" = 3
  )
)

# With version header
r2 <- GET(
  url = u,
  config = add_headers(
    "Zotero-API-Key" = zotero_key(),
    "Zotero-API-Version" = 3,
    # "If-Modified-Since-Version" = 2469
    "If-Modified-Since" = "2020-06-01T17:50:00Z"
  )
)
