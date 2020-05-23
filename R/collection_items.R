#' Fetch all items of a collection
#'
#' @param key collection key, see [collections()]
#' @param format output format
#'
#' @export

collection_items <- function(key, format="bibtex", ...) {
  r <- zotero_api(
    path = paste("users", zotero_usr(), "collections", key, "items", sep = "/"),
    query = list(
      format = format
    )
  )
  rawToChar(r)
}

#' @rdname collection_items
#'
#' @description - `save_collection()` - Write BibTeX file with all items in a collection
#'
#' @param path path to bibtex file
#'
#' @export
save_collection <- function(key, path, ...) {
  cat(collection_items(key, ...), file=path)
}
