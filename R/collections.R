#' Fetch data on collections
#'
#' Fetch all collections.
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
    path = paste("users", zotero_usr(), "collections", sep="/"),
    ...
  )

  data.frame(
    key = purrr::map_chr(r, c("data", "key")),
    name = purrr::map_chr(r, c("data", "name")),
    parent = dplyr::na_if(purrr::map_chr(r, c("data", "parentCollection")), "FALSE"),
    stringsAsFactors = FALSE
  )
}
