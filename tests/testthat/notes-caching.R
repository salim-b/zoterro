# Fetch my publications
u <- "https://api.zotero.org/users/311682/publications/items"

r <- GET(
  url = u,
  config = add_headers(
    "Zotero-API-Key" = zotero_key(),
    "Zotero-API-Version" = 3
  )
)

(libver <- r$headers$`last-modified-version`)

# With version header
r2 <- GET(
  url = u,
  config = add_headers(
    "Zotero-API-Key" = zotero_key(),
    "Zotero-API-Version" = 3,
    "If-Modified-Since-Version" = libver
  )
)

identical(http_status(r2), http_status(304))
