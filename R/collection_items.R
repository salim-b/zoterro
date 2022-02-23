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

#' Export all items in a collection to file
#'
#' Writes a file of the chosen `format` to `path` with all items in a collection.
#'
#' @inheritParams collection_items
#' @param path Path to file.
#' @param format Bibliographic data format used for export. One of:
#'   - `"bibtex"`,
#'   - `"biblatex"`,
#'   - `"csljson"`,
#'   - `"mods"`,
#'   - `"refer"`,
#'   - `"rdf_bibliontology"`,
#'   - `"rdf_dc"`,
#'   - `"rdf_zotero"`,
#'   - `"ris"`,
#'   - `"wikipedia"`
#'
#'   For details, see the [relevant Zotero
#'   documentation](https://www.zotero.org/support/dev/web_api/v3/basics#export_formats).
#'
#' @export
save_collection <- function(key, path, format = "bibtex", ...) {

  format <- match.arg(
    arg = format,
    choices = c("bibtex",
                "biblatex",
                # "bookmarks", # only returns a list of `<pointers>`...
                # "coins",     # only returns a list of `<pointers>`...
                "csljson",
                "mods",
                "refer",
                "rdf_bibliontology",
                "rdf_dc",
                "rdf_zotero",
                "ris",
                # "tei",       # returns internal server error (500)
                "wikipedia")
  )
  res <- collection_items(key, query = list(format = format), ...)

  # all formats other than "wikipedia" are returned as raw vctrs
  if (format != "wikipedia") res <- rawToChar(res)

  cat(res, file = path)
}
