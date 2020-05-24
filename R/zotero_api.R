#' Make Zotero API request
#'
#' Make Zotero APIv3 request.
#'
#' @param base_url API URL
#' @param ... For [zotero_api()] passed to [httr::GET()].
#'
#' @details Functions are responsive to the following options:
#'
#' - `zoterro.verbose` - (default `FALSE`) give more feedback when running
#' - `zoterro.sleep` - (default 1) sleep time between requests, see [Sys.sleep()]
#'
#' @return List of `response` objects (c.f. [httr::GET()]).
#'
#' @export

zotero_api <- function(base_url = "https://api.zotero.org", ...) {
  resp <- zotero_get(base_url = base_url, ...)
  result <- list(resp)
  while(has_next(resp)) {
    l <- zotero_response_links(resp)
    if(getOption("zoterro.verbose", FALSE)) {
      pretty_links(l)
    }
    resp <- zotero_get(l["next"])
    result <- c(result, list(resp))
    if(has_next(resp)) {
      Sys.sleep(getOption("zoterro.sleep", 1))
    }
  }
  parse_results(result) # List of responses
}


# Make a single request
#
#' @import httr
zotero_get <- function(
  base_url = "https://api.zotero.org",
  user = zotero_usr(),
  path = NULL,
  query = NULL,
  ...
) {
  u <- modify_url(
    base_url,
    path = paste(url_prefix(user), path, sep="/"),
    query = query
  )
  resp <- GET(
    url = u,
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








# Extract the links to subsequent queries (pages) from Zotero response
#
# @param r response
#
# Returns named character vector with names from: first, prev, next, last. URL
# named alternate leads to corresponding webpage.
#
#' @import magrittr
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

# Is there a "next" link in the header?
has_next <- function(r) {
  "next" %in% names(zotero_response_links(r))
}


# Content type of the response
response_content_type <- function(r) {
  r$headers[["content-type"]]
}


pretty_links <- function(x) {
  cat(
    paste(names(x), x, sep=": "),
    sep="\n"
  )
}




# Given a list of GET responses return a useful object
#
# @param r
#
parse_results <- function(x, ...) UseMethod("parse_results")

# By default extract content
parse_results.default <- function(x, ...) {
  do.call("c", lapply(x, content))
}
