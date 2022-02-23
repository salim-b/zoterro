#' Fetch all items in a collection
#'
#' @param key [Collection
#'   key](https://www.zotero.org/support/dev/web_api/v3/basics#collections),
#'   see [collections()].
#' @param as_tibble Whether or not to convert the resulting list to a tibble
#'   (with nested list columns). If `FALSE`, a bare list is returned instead
#'   which also retains all additional API metadata fields besides the actual
#'   items data. See [as_item_tibble()] for details.
#' @param ... Other arguments passed to [zotero_api()]
#'
#' @export
#' @return A [tibble][tibble::tbl_df] if `as_tibble = TRUE`, otherwise a list.
#' @family items
#' @examples
#' # items from public collections can be fetched without an API key
#' collection_items(key = "MSNU4A4F", user = zotero_group_id(id = 197065))

collection_items <- function(key,
                             as_tibble = TRUE,
                             ...) {
  res <- zotero_api(
    path = paste("collections", key, "items", sep = "/"),
    ...
  )

  if (as_tibble) res <- as_item_tibble(res)

  res
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
  res <- collection_items(
    key = key,
    as_tibble = FALSE,
    query = list(format = format),
    ...
  )

  # all formats other than "wikipedia" are returned as raw vctrs
  if (format != "wikipedia") res <- rawToChar(res)

  cat(res, file = path)
}

#' Convert items list to a tibble
#'
#' Converts an items list as returned by
#' [`collection_items(as_tibble = FALSE)`][collection_items] to a
#' [tibble][tibble::tbl_df] (with nested list columns), dropping API metadata
#' fields that are not part of the items data.
#'
#' Note that [collection_items()] by default already calls this function
#' internally (`as_tibble = TRUE`).
#'
#' @param items A list of Zotero library items as returned by
#'   [collection_items()].
#'
#' @return A [tibble][tibble::tbl_df].
#' @family items
#' @export
#'
#' @examples
#' # fetch raw result (2 items)
#' r <- zotero_api(
#'   path = "items",
#'   user = zotero_group_id(197065),
#'   query = list(limit = 2),
#'   fetch_subsequent = FALSE
#' )
#'
#' str(r)
#'
#' # convert to tibble
#' as_item_tibble(r)
as_item_tibble <- function(items) {

  # dataframe/tibble already
  if (is.data.frame(items)) {
    res <- items

    # multiple items list
  } else if (is.null(names(items))) {
    res <- purrr::map_dfr(items, as_item_tibble_helper)

    # single item list
  } else {
    res <- as_item_tibble_helper(items)
  }

  res
}

as_item_tibble_helper <- function(item) {
  item %>%
    purrr::pluck("data") %>%
    purrr::compact() %>%
    purrr::map(~ {
      if (length(.x) > 1L) list(.x) else .x
    }) %>%
    tibble::as_tibble_row()
}


#' Add archive URLs from "Robust Link" attachments
#'
#' Adds a top-level column `archiveUrl` with archive links extracted from item
#' attachments created by the [Zotero Robust
#' Links](https://robustlinks.mementoweb.org/zotero/) add-on.
#'
#' An example of a "Robust Link" attachment can be viewed via [this
#' link](https://www.zotero.org/groups/4603023/zoterro_testing/items/KC6WFG78/attachment/EE7ZQ6PD/library).
#'
#' @param items A list or data frame of Zotero library items as returned by
#'   [collection_items()]. Must include all of the fields/columns `parentItem`,
#'   `itemType` and `title`.
#'
#' @inherit as_item_tibble return
#' @family items
#' @export
#'
#' @examples
#' library(magrittr)
#'
#' # fetch some demo entry
#' collection_items(key = "AZBJE3R8",
#'                  user = zotero_group_id(4603023)) %>%
#'   # add archive link
#'   add_archive_url() %>%
#'   # drop "Robust Link" attachment
#'   dplyr::filter(!(itemType == "attachment" & title == "Robust Link")) %>%
#'   # show columns
#'   dplyr::select(key, url, archiveUrl)
add_archive_url <- function(items) {

  if (!is.data.frame(items)) items <- as_item_tibble(items)

  if (!all(c("parentItem", "itemType", "title") %in% colnames(items))) {
    stop(paste0(
      "`items` must contain all of the fields ",
      "`parentItem`, `itemType` and `title`.")
    )
  }

  # "Robust Link" attachments are children of top-level items
  dplyr::left_join(
    x = items,
    y = items %>%
      dplyr::filter(
        !is.na(parentItem)
        & itemType == "attachment"
        & title == "Robust Link"
      ) %>%
      dplyr::transmute(
        key = parentItem,
        archiveUrl = stringi::stri_extract(
          str = note,
          regex = '(?<=Memento URL: <a href=").*?(?=")'
        )
      ),
    by = "key"
  )
}
