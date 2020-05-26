
<!-- README.md is generated from README.Rmd. Please edit that file -->

# zoterro <img src="man/figures/logo.png" align="right" width="20%"/>

<!-- badges: start -->

[![R build
status](https://github.com/mbojan/zoterro/workflows/R-CMD-check/badge.svg)](https://github.com/mbojan/zoterro/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/zoterro)](https://CRAN.R-project.org/package=zoterro)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
<!-- badges: end -->

[Zotero](https://www.zotero.org/) is a free tool for collecting,
organizing, and citing research developed by [Corporation for Digital
Scholarship](https://digitalscholar.org/). Zoterro (with double “r”) is
a simple R client to Zotero web API (ver. 3) with which you can access
the data associated with your account or groups you are a member of.

See [Zotero API
documentation](https://www.zotero.org/support/dev/web_api/v3) for what
is available.

## Installation

Install development version from
[GitHub](https://github.com/mbojan/zoterro) with:

``` r
# install.packages("remotes")
remotes::install_github("mbojan/zoterro")
```

## Examples

  - Fetch all items from collection with (fictious) key `aabbcc` and
    save to BibTeX file `references.bib`.
    
    ``` r
    save_collection("aabbcc", path = "references.bib")
    ```

  - `zotero_api()` is a low-level function. It will make multiple
    requests if the results do not fit a single response. The following
    will fetch all collection names and their keys associated with a
    (fictious) user ID 666:
    
    ``` r
    zotero_api(path="collections")
    ```
