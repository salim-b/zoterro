#' Make Zotero API request
#'
#' Make Zotero APIv3 request.
#'
#' @param query,path Request parameters
#' @param base_url API URL
#' @param ... For [zotero_api()] passed to [httr::GET()].
#'
#' @details
#'
#' @return List of class `zotero_api` with elements `content` and `response`.
#'
#' @import httr
#' @export
zotero_api <- function(path, query = NULL, base_url = "https://api.zotero.org", ...) {
  u <- modify_url(
    base_url,
    path = path,
    query = query
  )
  resp <- GET(
    url = u,
    add_headers(
      "Zotero-API-Key" = zotero_key(),
      "Zotero-API-Version" = 3
    ),
    ...
  )
  if(http_error(resp)) {
    stop(
      sprintf("Zotero request failed with HTTP error [%s]", status_code(resp))
    )
  }
  structure(
    list(
      content = content(resp),
      response = resp
    ),
    class = "zotero_api"
  )
}







#' @rdname zotero_api
#' @export
print.zotero_api <- function(x, ...) {
  cat("<Zotero API request>\n")
  print(x$response)
}









# Extract the links to subsequent queries (pages) from Zotero response
#
# @param r response
#
# Returns tibble with
#
# - id number
# - url the link
# - rel value in the rel field, one of: next, last, alternate
#
zotero_response_links <- function(r, ...) {
  # Links to the the other pages of the resultset
  strsplit(r$response$headers$link, ", ") %>%
    unlist() %>%
    tibble::enframe(name = "id", value = "link") %>%
    tidyr::extract(
      link,
      into = c("url", "rel"),
      '<(.*)>; rel="([a-z]+)"'
    )

}
