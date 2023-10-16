#' Make Zotero API request
#'
#' Fetch data from Zotero using API ver. 3. If the result is broken into
#' multiple parts, multiple requests are made to fetch everything.
#'
#' @param base_url Base URL of the [Zotero Web
#'   API](https://www.zotero.org/support/dev/web_api/v3/basics#base_url).
#' @param path [Zotero Web API resource
#'   path](https://www.zotero.org/support/dev/web_api/v3/basics#resources)
#'   without the `<userOrGroupPrefix>/`. e.g. `items/top`.
#' @param query A named list of [Zotero Web API URL
#'   parameters](https://www.zotero.org/support/dev/web_api/v3/basics#general_parameters),
#'   passed on to [httr::modify_url()].
#'
#'   Note that the maximum `limit` is `100` results. Set
#'   `fetch_subsequent = TRUE` (default) to retrieve all results.
#' @param fetch_subsequent Whether or not to also retrieve results beyond
#'   `query$start + query$limit`.
#' @param user Object returned by [zotero_user_id()] or [zotero_group_id()].
#' @param api_key Personal [Zotero Web API
#'   key](https://www.zotero.org/support/dev/web_api/v3/basics#authentication).
#'   See [zotero_key()]. If `NULL`, authentication is omitted, resulting in
#'   limited access to public Zotero libraries only.
#' @param modified_since Optional [Zotero library version
#'   number](https://www.zotero.org/support/dev/web_api/v3/syncing). If the
#'   Zotero library's content hasn't changed since the specified version
#'   number, a zero-length [raw vector][raw()] will be returned instead of the
#'   actual library content (and the performed API request will be
#'   significantly faster). See section *Caching* below for further details.
#' @param verbose Whether or not to print called API URLs to the console.
#' @param ... Further arguments passed on to [httr::RETRY()].
#'
#' @details
#' The `user` argument expects a Zotero user or group ID. Use [zotero_user_id()]
#' or [zotero_group_id()] to pass it. By default [zotero_usr()] is called which
#' fetches the ID from the \R option `zoterro.user` or the environment variable
#' `ZOTERO_USER`.
#'
#' The URL of the request will contain the appropriate user/group ID prefix
#' which will be combined with `path` or `query` when supplied.
#'
#' By default, `zotero_api()` respects the following \R options:
#'
#' - **`zoterro.user`** (defaults to [zotero_usr()]): Zotero user ID.
#' - **`zoterro.key`** (defaults to [zotero_key()]): Personal [Zotero Web API
#'   key](https://www.zotero.org/support/dev/web_api/v3/basics#authentication).
#' - **`zoterro.verbose`** (defaults to `FALSE`): Whether or not to print
#'   called API URLs to the console.
#'
#' ## Caching
#'
#' As the [official API documentation
#' states](https://www.zotero.org/support/dev/web_api/v3/basics#caching),
#' "every Zotero library and object (collection, item, etc.) on the server has
#' an associated version number. The version number can be used to determine
#' whether a client has up-to-date data for a library or object, allowing for
#' efficient and safe syncing."
#'
#' `zotero_api()` supports this caching mechanism via the `modified_since`
#' parameter. If the Zotero library's content hasn't changed since the version
#' number specified in `modified_since`, a zero-length [raw vector][raw()] will
#' be returned instead of the actual library content. In this case, the
#' performed API request will be significantly faster since the body is omitted
#' in the corresponding HTTP response.
#'
#' Otherwise, the object returned by `zotero_api()` has a `version`
#' [attribute][attr] set to the [Zotero library version
#' number](https://www.zotero.org/support/dev/web_api/v3/syncing) returned by
#' the API (corresponding to the current version number of the library (for
#' multi-object requests) or object (for single-object requests)). You could
#' provide this number as the `modified_since` argument to subsequent
#' `zotero_api()` calls in order to use the API more efficiently (and thereby
#' implement some form of caching).
#'
#' @return
#' If `modified_since = NULL` or the Zotero library's content has changed since
#' the specified `modified_since` version, a list of
#' [`response`][httr::response] objects. Otherwise, a zero-length [raw
#' vector][raw()].
#'
#' In both cases, the returned object has a `version` [attribute][attr] set to
#' the [Zotero library version
#' number](https://www.zotero.org/support/dev/web_api/v3/syncing) returned by
#' the API.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Fetch groups for the default user
#' zotero_api(path = "groups")
#'
#' # Fetch top-level collections for the group with ID=12345
#' zotero_api(path = "collections/top", user = zotero_group_id(12345))
#' }

zotero_api <- function(
  base_url = "https://api.zotero.org",
  query = NULL,
  fetch_subsequent = TRUE,
  path = NULL,
  user = zotero_usr(),
  api_key = zotero_key(),
  modified_since = NULL,
  verbose = getOption("zoterro.verbose", FALSE),
  ...
  ) {

  u <- modify_url(
    base_url,
    path = paste(url_prefix(user), path, sep = "/"),
    query = as.list(query) %>%
      purrr::list_modify(
        start = ifelse(length(.$start), .$start, 0),
        limit = ifelse(length(.$limit), .$limit, 100)
      )
  )

  resp <- zotero_get(
    url = u,
    user = user,
    api_key = api_key,
    modified_since = modified_since,
    ...
    )
  result <- list(resp)

  version <- as.integer(headers(resp)$`last-modified-version`)
  if (!length(version)) version <- NULL

  while (fetch_subsequent && has_next(resp)) {
    l <- zotero_response_links(resp)
    if (verbose) {
      pretty_links(l)
    }
    resp <- zotero_get(
      url = l["next"],
      user = user,
      api_key = api_key,
      modified_since = modified_since,
      ...
    )
    result <- c(result, list(resp))
  }

  result <- parse_results(result)
  attr(result, which = "version") <- version
  result
}


#' Make a single request
#'
#' @keywords internal
zotero_get <- function(
    url,
    user,
    api_key = NULL,
    modified_since = NULL,
    ...
) {

  resp <- RETRY(
    verb = "GET",
    url = url,
    config = add_headers(
      "Zotero-API-Key" = api_key,
      "Zotero-API-Version" = 3,
      "If-Modified-Since-Version" = modified_since
    ),
    ...,
    times = 3,
    quiet = TRUE,
    terminate_on = c(403)
  )

  if (http_error(resp)) {
    if (status_code(resp) == 403) {
      msg <- paste0(
        "No permission to access the Zotero library with ",
        ifelse(inherits(user, "zotero_user_id"), "user", "group"), " ID ",
        stringi::stri_extract(url, regex = "(?<=/(user|group)s/).+?(?=/)"),
        ".\n"
      )
      msg <- dplyr::case_when(
        is.null(api_key) ~
          paste0("Missing API key. Either provide `api_key` directly or see ",
                 "`?zoterro::zotero_credentials` for other ways to provide ",
                 "it."),
        !is_api_key_valid(api_key = api_key, url = url) ~
          paste0(msg, "Provided API key `", api_key, "` is invalid."),
        TRUE ~
          paste0(msg, "You need to provide a different API key.")
      )
    } else {
      msg <- sprintf(
        "Request repeatedly failed with '%s'\n<%s>",
        http_status(resp)$message,
        resp$request$url
      )
    }
    stop(msg)
  }

  resp
}

# API key validation
is_api_key_valid <- function(api_key,
                             url) {

  if (is.null(api_key)) return(FALSE)

  resp <- RETRY(
    verb = "GET",
    url = modify_url(url, path = paste0("keys/", api_key)),
    config = add_headers("Zotero-API-Version" = 3),
    times = 2,
    quiet = TRUE
  )

  if (http_error(resp)) return(FALSE)

  TRUE
}




#' Extract the links to subsequent queries (pages) from Zotero response
#'
#' @param r Response.
#'
#' Returns named character vector with names from: first, prev, next, last. URL
#' named alternate leads to corresponding webpage.
#'
#' @keywords internal
zotero_response_links <- function(r, ...) {
  if (is.null(r$headers$link)) return(FALSE)
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

# Print API URLs to console
pretty_links <- function(x) {
  cat(
    paste(names(x), x, sep = ": "),
    sep = "\n"
  )
}




#' Given a list of GET responses return a useful object
#'
#' @param x A list of GET responses.
#'
#' @keywords internal
parse_results <- function(x, ...) UseMethod("parse_results")

# By default extract content
parse_results.default <- function(x, ...) {
  do.call("c", lapply(x, content))
}



# re-usable documentation content
snippet_version_attr <- "is of length `0` if the Zotero library's content
hasn't changed since the version number specified in `modified_since`.
Otherwise it has a `version` [attribute][attr] set to the [Zotero library
version number](https://www.zotero.org/support/dev/web_api/v3/syncing) returned
by the API.

See section *Caching* in [zotero_api()] for further details."
