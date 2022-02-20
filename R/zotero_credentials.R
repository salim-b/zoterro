#' Get Zotero user ID and API key
#'
#' @description
#' - `zotero_usr()`: Return Zotero user ID
#' - `zotero_key()`: Return Zotero key
#'
#' @details These functions look for Zotero user ID and [Web API
#'   key](https://www.zotero.org/support/dev/web_api/v3/basics#authentication)
#'   by looking at the following places and returning as soon as a value is
#'   found:
#'
#'   - Options `zotero.user` and `zotero.key` respectively
#'   - Environment variables `ZOTERO_USER` and `ZOTERO_KEY` respectively.
#'
#' Best practice is to store both the user ID and the API key in read-protected
#' `~/.Renviron` as environment variables.
#'
#' A new API key can be created on [this
#' page](https://www.zotero.org/settings/keys/new). The own user ID can be
#' looked up on [this page](https://www.zotero.org/settings/keys). The group
#' ID is the integer coming after `/groups/` in the respective Zotero URL,
#' e.g. `197065` in case of the URL `.../zotero.org/groups/197065/...`).
#'
#' @name zotero_credentials
#'
#' @export

zotero_usr <- function() {
  id <- if(!is.null(getOption("zotero.user"))) {
    getOption("zotero.user")
  } else {
    if(Sys.getenv("ZOTERO_USER") != "") {
      Sys.getenv("ZOTERO_USER")
    } else {
      stop(paste0("No Zotero user ID found, see `?zoterro::zotero_credentials` ",
                  "for different ways to provide it."))
    }
  }
  zotero_user_id(id)
}




#' @rdname zotero_credentials
#'
#' @export
zotero_key <- function() {
  if(!is.null(getOption("zotero.key"))) return(getOption("zotero.key"))
  if(Sys.getenv("ZOTERO_KEY") != "") return(Sys.getenv("ZOTERO_KEY"))
  NULL
}







# Processing IDs ----------------------------------------------------------



#' @rdname zotero_credentials
#'
#' @description
#' - `zotero_user_id()`, `zotero_group_id()`: supply user/group ID
#'   to other functions
#'
#' @param id user or group iD
#'
#' @details Functions `zotero_user_id()` and `zotero_group_id()` are used to
#'   supply user or group ID to other functions in the package, primarly
#'   [zotero_api()].
#'
#' @return Functions `zotero_user_id()` and `zotero_group_id()` return objects
#'   of class `"zotero_user_id"` and `"zotero_group_id"`, both inheriting from class
#'   `"zotero_id"`.
#'
#' @export
zotero_user_id <- function(id) {
  stopifnot(length(id) == 1)
  structure(as.numeric(id), class = c("zotero_user_id", "zotero_id"))
}

#' @rdname zotero_credentials
#' @export
zotero_group_id <- function(id) {
  stopifnot(length(id) == 1)
  structure(id, class = c("zotero_group_id", "zotero_id"))
}

#' Print Zotero user/group ID
#'
#' @param x Zotero user/group ID
#' @param ... other arguments
#'
#' @keywords internal
print.zotero_id <- function(x, ...) {
  cat("Zotero ID:", x, "\n")
}






# URL prefix with user/group ID -------------------------------------------

url_prefix <- function(x, ...) UseMethod("url_prefix")

url_prefix.zotero_user_id <- function(x, ...) {
  paste0("users/", x)
}

url_prefix.zotero_group_id <- function(x, ...) {
  paste0("groups/", x)
}

url_prefix.default <- function(x, ...) {
  stop("don't know how to handle class ", sQuote(data.class(x)))
}
