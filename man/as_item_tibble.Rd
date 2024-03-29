% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/items.R
\name{as_item_tibble}
\alias{as_item_tibble}
\title{Convert Zotero library items list to a tibble}
\usage{
as_item_tibble(items)
}
\arguments{
\item{items}{A list of Zotero library items as returned by
\code{\link[=items]{items()}}.}
}
\value{
A \link[tibble:tbl_df-class]{tibble}.
}
\description{
Converts an items list as returned by
\code{\link[=items]{items(as_tibble = FALSE)}} to a \link[tibble:tbl_df-class]{tibble} (with
nested list columns), dropping API metadata fields that are not part of the
items data.
}
\details{
Note that \code{\link[=items]{items()}} by default already calls this function
internally (\code{as_tibble = TRUE}).
}
\examples{
# fetch raw result (2 items)
r <- zotero_api(
  path = "items",
  user = zotero_group_id(197065),
  query = list(limit = 2),
  fetch_subsequent = FALSE
)

str(r)

# convert to tibble
as_item_tibble(r)
}
\seealso{
Other Zotero items functions:
\code{\link{add_archive_url}()},
\code{\link{items}()},
\code{\link{write_bib}()}
}
\concept{items}
