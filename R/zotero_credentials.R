#' Acess Zotero username and key from environment variables.
#'
#' @description - `zotero_usr()` - return Zotero user ID
#'
#' @description - `zotero_key()` - return Zotero key
#'
#' @details Best practice is to store both the user ID and the key in
#'   read-protected `~/.Renviron` as environment variables. The two functions
#'   look at `ZOTERO_USER` and `ZOTERO_KEY` respectively.
#'
#' @name zotero_credentials
#'
#' @export

zotero_usr <- function() as.numeric(Sys.getenv("ZOTERO_USER"))




#' @rdname zotero_credentials
#'
#' @export
zotero_key <- function() Sys.getenv("ZOTERO_KEY")
