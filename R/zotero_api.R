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
  resp <- zotero_get(base_url = base_url, ...)
  result <- list(resp)
  while(has_next(resp)) {
    l <- zotero_response_links(resp)
    resp <- zotero_get(l["next"])
    result <- c(result, list(resp))
    if(has_next(resp)) {
      Sys.sleep(getOption("zotero.sleep", 1))
    }
  }
  parse_results(result) # List of responses
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




#' @import magrittr




# Extract the links to subsequent queries (pages) from Zotero response
#
# @param r response
#
# Returns named character vector with names from: first, prev, next, last. URL
# named alternate leads to corresponding webpage.
#
zotero_response_links <- function(r, ...) {
  if(is.null(r$headers$link)) return(FALSE)
  # Links to the the other pages of the resultset
  r$headers$link %>%
    strsplit(", ") %>%
    unlist() -> z
  structure(
    stringi::stri_extract_first_regex(z, "(?<=<).*(?=>)"),
    names = stringi::stri_extract_first_regex(z, '(?<=").*(?=")')
  )
}


has_next <- function(r) {
  "next" %in% names(zotero_response_links(r))
}


parse_results <- function(r) identity(r)
