#' Fetch Zotero library items
#'
#' Retrieves items belonging to a Zotero user or group library, optionally
#' limited to a specific collection. Trashed items are never included.
#'
#' @param collection_key [Collection
#'   key](https://www.zotero.org/support/dev/web_api/v3/basics#collections),
#'   see [collections()]. If `NULL`, all items in the library are returned.
#' @param incl_children Whether or not to include child items from
#'   sub-collections beneath the `collection_key`'s or the library's (if
#'   `collection_key = NULL`) top level.
#' @param as_tibble Whether or not to convert the resulting list to a tibble
#'   (with nested list columns). If `FALSE`, a bare list is returned instead
#'   which also retains all additional API metadata fields besides the actual
#'   items data. See [as_item_tibble()] for details.
#' @param ... Other arguments passed to [zotero_api()]
#'
#' @return
#' A [tibble][tibble::tbl_df] if `as_tibble = TRUE`, otherwise a list.
#'
#' Note that the returned object `r snippet_version_attr`
#'
#' @export
#' @family items
#' @examples
#' # items from public libraries can be fetched without an API key
#' items(collection_key = "MSNU4A4F", user = zotero_group_id(id = 197065))
#'
#' # when no collection key is supplied, the whole library is fetched
#' items(user = zotero_group_id(id = 197065))
#'
#' # optionally, the retrieval ca be limited to top-level items only
#' items(incl_children = FALSE, user = zotero_group_id(id = 197065))

items <- function(collection_key = NULL,
                  incl_children = TRUE,
                  as_tibble = TRUE,
                  ...) {
  res <- zotero_api(
    path = paste0(
      paste0("collections/", collection_key, "/")[!is.null(collection_key)], "items", "/top"[!incl_children]
    ),
    ...
  )

  if (as_tibble) res <- as_item_tibble(res)

  res
}

#' Export Zotero library items to bibliography file
#'
#' Writes a file of the chosen bibliography `format` to `path` with items
#' belonging to a Zotero user or group library, optionally limited to a
#' specific collection.
#'
#' @inheritParams items
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
#' @param modified_since Optional [Zotero library version
#'   number](https://www.zotero.org/support/dev/web_api/v3/syncing). If the
#'   Zotero library's content hasn't changed since the specified version
#'   number, nothing will be written to `path` (and the performed API request
#'   will be significantly faster). See section *Caching* in [zotero_api()] for
#'   further details.
#'
#' @return
#' A character scalar of the Zotero Library items in the specified `format`,
#' invisibly.
#'
#' Note that it `r snippet_version_attr`
#'
#' @family items
#' @export
write_bib <- function(collection_key = NULL,
                      incl_children = TRUE,
                      path,
                      format = "bibtex",
                      modified_since = NULL,
                      ...) {
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
  response <- items(
    collection_key = collection_key,
    incl_children = incl_children,
    as_tibble = FALSE,
    query = list(format = format),
    modified_since = modified_since,
    ...
  )
  version <- attr(response, which = "version")
  result <- response

  # convert from raw to character if necessary
  # (affects all formats other than "wikipedia")
  if (is.raw(result)) result <- rawToChar(result)

  if (!is.null(version)) {

    cat(result, file = path)

  } else {
    result <- character()
  }

  attr(result, which = "version") <- version
  invisible(result)
}

#' Convert Zotero library items list to a tibble
#'
#' Converts an items list as returned by
#' [`items(as_tibble = FALSE)`][items] to a [tibble][tibble::tbl_df] (with
#' nested list columns), dropping API metadata fields that are not part of the
#' items data.
#'
#' Note that [items()] by default already calls this function
#' internally (`as_tibble = TRUE`).
#'
#' @param items A list of Zotero library items as returned by
#'   [items()].
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

  attr(res, which = "version") <- attr(items, "version")
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
#' Adds a top-level column `archiveUrl` extracted from the item's corresponding
#' [Zotero Robust
#' Links](https://robustlinks.mementoweb.org/zotero/) attachment.
#'
#' An example of a "Robust Link" attachment can be viewed via [this
#' link](https://www.zotero.org/groups/4603023/zoterro_testing/items/KC6WFG78/attachment/EE7ZQ6PD/library).
#'
#' @param items A list or data frame of Zotero library items as returned by
#'   [items()]. Must include all of the fields/columns `parentItem`, `itemType`
#'   and `title`.
#'
#' @inherit as_item_tibble return
#' @family items
#' @export
#'
#' @examples
#' library(magrittr)
#'
#' # fetch some demo entry
#' items(key = "AZBJE3R8", user = zotero_group_id(4603023)) %>%
#'   # add archive link
#'   add_archive_url() %>%
#'   # drop "Robust Link" attachment
#'   dplyr::filter(!(itemType == "attachment" & title == "Robust Link")) %>%
#'   # show columns
#'   dplyr::select(key, url, archiveUrl)
add_archive_url <- function(items) {

  items <- as_item_tibble(items)

  if (!all(c("parentItem", "itemType", "title") %in% colnames(items))) {
    stop(paste0(
      "`items` must contain all of the fields ",
      "`parentItem`, `itemType` and `title`.")
    )
  }

  # "Robust Link" attachments are children of top-level items
  items %>%
    dplyr::filter(
      !is.na(parentItem)
      & itemType == "attachment"
      & title == "Robust Link"
    ) %>%
    # reduce to single attachment per parent item
    dplyr::filter(!duplicated(parentItem)) %>%
    # extract archive url
    dplyr::transmute(
      key = parentItem,
      archiveUrl = stringi::stri_extract(
        str = note,
        regex = '(?<=Memento URL: <a href=").*?(?=")'
      )
    ) %>%
    dplyr::left_join(
      x = items,
      by = "key"
    )
}
