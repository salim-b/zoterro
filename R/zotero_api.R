#' Make Zotero API request
#'
#' Make Zotero APIv3 request.
#'
#' @param base_url API URL
#' @param ... For [zotero_api()] passed to [httr::GET()].
#'
#' @return List of class `zotero_api` with elements `content` and `response`.
#'
#' @import httr
#' @export

zotero_api <- function(base_url = "https://api.zotero.org", ...) {
  need_fetch <- TRUE
  result <- NULL
  while(need_fetch) {
    r <- zotero_get(base_url = base_url, ...)
    c(result, list(r))
    if(has_next(r)) {
      needs_fetch <- TRUE
      Sys.sleep(getOption("zotero.sleep", 1))
    } else {
      needs_fetch <- FALSE
    }
    parse_results(result)
  }
}


# Make a single request
zotero_get <- function(base_url = "https://api.zotero.org", ...) {
  resp <- GET(
    url = base_url,
    config = add_headers(
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

  resp
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
# Returns named character vector with names from: first, prev, next, last. URL
# named alternate leads to corresponding webpage.
#
zotero_response_links <- function(r, ...) {
  # Links to the the other pages of the resultset
  r$response$headers$link %>%
    strsplit(", ") %>%
    unlist() -> z
  structure(
    stringi::stri_extract_first_regex(z, "(?<=<).*(?=>)"),
    names = stringi::stri_extract_first_regex(z, '(?<=").*(?=")')
  )
}
