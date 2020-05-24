#' Fetch collection hierarchy
#'
#' Fetch all collections of a Zotero user with their keys and keys of parent
#' collections (if any).
#'
#' @param ... passed to [zotero_api()]
#'
#' @return Data frame with columns:
#'
#' - `key` - collection key
#' - `name` - collection name
#' - `parent` - key of the parent collection or `NA`
#'
#' @export
#'

collections <- function(...) {
  r <- zotero_api(
    path = "collections",
    ...
  )

  data.frame(
    key = purrr::map_chr(r, c("data", "key")),
    name = purrr::map_chr(r, c("data", "name")),
    parent = dplyr::na_if(purrr::map_chr(r, c("data", "parentCollection")), "FALSE"),
    stringsAsFactors = FALSE
  )
}
