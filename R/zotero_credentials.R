#' Get Zotero username and key
#'
#' @description - `zotero_usr()` - return Zotero user ID
#'
#' @description - `zotero_key()` - return Zotero key
#'
#' @details These functions look for Zotero user ID and key by looking into the
#'   following places and returning as soon as a value found:
#'
#'   - Options `zotero.user` and `zotero.key` respectively
#'   - Environment variables `ZOTERO_USER` and `ZOTERO_KEY` respectively.
#'
#' Best practice is to store both the user ID and the key in read-protected
#' `~/.Renviron` as environment variables.
#'
#' @name zotero_credentials
#'
#' @export

zotero_usr <- function() {
  if(!is.null(getOption("zotero.user"))) return(getOption("zotero.user"))
  if(Sys.getenv("ZOTERO_USER") != "") return(Sys.getenv("ZOTERO_USER"))
  stop("no Zotero user ID found, see ?zoterro::zotero_credentials")
}




#' @rdname zotero_credentials
#'
#' @export
zotero_key <- function() {
  if(!is.null(getOption("zotero.key"))) return(getOption("zotero.key"))
  if(Sys.getenv("ZOTERO_KEY") != "") return(Sys.getenv("ZOTERO_KEY"))
  stop("no Zotero key found, see ?zoterro::zotero_credentials")
}







# Processing IDs ----------------------------------------------------------

zotero_user_id <- function(id) {
  stopifnot(length(id) == 1)
  structure(id, class=c("zotero_user_id", "zotero_id"))
}

zotero_group_id <- function(id) {
  stopifnot(length(id) == 1)
  structure(id, class=c("zotero_group_id", "zotero_id"))
}

#' @rdname zotero_credentials
#' @export
format.zotero_user_id <- function(x, ...) {
  paste0("users/", x)
}

#' @rdname zotero_credentials
#' @export
format.zotero_group_id <- function(x, ...) {
  paste0("groups/", x)
}

#' @rdname zotero_credentials
#' @export
print.zotero_id <- function(x, ...) {
  cat("Zotero ID:", x, "\n")
}
