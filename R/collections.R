#' Fetch collection hierarchy
#'
#' Fetch all collections of a Zotero user or group library with their keys and
#' keys of parent collections (if any).
#'
#' @param ... Further arguments passed on to [zotero_api()]
#'
#' @return A [tibble][tibble::tbl_df] with columns:
#'
#' - `key`: Collection key.
#' - `name`: Collection name.
#' - `parent_key`: Key of the parent collection (`NA` if no parent collection exists).
#'
#' Note that the tibble `r snippet_version_attr`
#'
#' @export
#'
#' @examples
#' collections(user = zotero_group_id(id = 197065))

collections <- function(...) {
  r <- zotero_api(
    path = "collections",
    ...
  )

  res <- tibble::tibble(
    key = purrr::map_chr(r, c("data", "key")),
    name = purrr::map_chr(r, c("data", "name")),
    parent_key = dplyr::na_if(purrr::map_chr(r, c("data", "parentCollection")), "FALSE")
  )
  attr(res, which = "version") <- attr(r, "version")
  res
}
