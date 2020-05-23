
<!-- README.md is generated from README.Rmd. Please edit that file -->

# zoterro <img src="man/figures/logo.png" align="right" width="20%" />

<!-- badges: start -->

<!-- badges: end -->

Zoterro is a simple R client to Zotero web API (ver. 3).

Primary motivation was a need to fetch bibliographical information
managed by Zotero to local RMarkdown project.

## Installation

Development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("mbojan/zoterro")
```

## Examples

Fetch all items from collection with key `aabbcc` and save to BibTeX
file `references.bib`.

``` r
collection_items("aabbcc", path = "references.bib")
```
