#' Fetch all items in a collection
#'
#' @param key collection key, see [collections()]
#' @param ... other arguments passed to [zotero_api()]
#'
#' @export

collection_items <- function(key, ...) {
  zotero_api(
    path = paste("collections", key, "items", sep="/"),
    ...
  )
}

#' @rdname collection_items
#'
#' @description - `save_collection()` - Write BibTeX file `path` with all items in a collection
#'
#' @param path path to file
#'
#' @export
save_collection <- function(key, path, ...) {
  cat(
    rawToChar(collection_items(key, query = list(format = "bibtex"), ...)),
    file = path
  )
}
