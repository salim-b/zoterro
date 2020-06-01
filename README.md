
<!-- README.md is generated from README.Rmd. Please edit that file -->

# zoterro <img src="man/figures/logo.png" align="right" width="20%"/>

<!-- badges: start -->

[![R build
status](https://github.com/mbojan/zoterro/workflows/R-CMD-check/badge.svg)](https://github.com/mbojan/zoterro/actions)
[![CRAN
status](https://www.r-pkg.org/badges/version/zoterro)](https://CRAN.R-project.org/package=zoterro)
[![Lifecycle:
maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Project Status: WIP – Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<!-- badges: end -->

[Zotero](https://www.zotero.org/) is a free tool for collecting,
organizing, and citing research developed by [Corporation for Digital
Scholarship](https://digitalscholar.org/). Zoterro (with double “r”) is
a simple R client to Zotero web API (ver. 3) with which you can access
the data associated with your account or groups you are a member of.

See [Zotero API
documentation](https://www.zotero.org/support/dev/web_api/v3/start) for
what is available.

## Installation

Install development version from
[GitHub](https://github.com/mbojan/zoterro) with:

``` r
# install.packages("remotes")
remotes::install_github("mbojan/zoterro")
```

## Examples

  - Fetch a complete collection hierarchy as a data frame. By default it
    will fetch for the default user, but here we fetch the collections
    associated with a public Zotero group “Computational Social Science”
    that has an ID `269768`:
    
    ``` r
    collections(user = zotero_group_id(269768))
    #>         key                          name parent
    #> 1  37L2NKQS                 Audit Culture   <NA>
    #> 2  FV8VSU96                  Supply Chain   <NA>
    #> 3  7YP6NY6Y                   Informatics   <NA>
    #> 4  JSUQ2CAP  Online political information   <NA>
    #> 5  TQ2T8I4S   Anticipatory Infrastructure   <NA>
    #> 6  VZKMHAKU       Prosopography & History   <NA>
    #> 7  95U78BNI               Behavior change   <NA>
    #> 8  UBT2C48F              Online community   <NA>
    #> 9  FWIPZMZB        Organizational ecology   <NA>
    #> 10 PJHH85S9                     Genealogy   <NA>
    #> 11 C6FFPZNS      Bots & Field Experiments   <NA>
    #> 12 HKKTBDTF              Social Computing   <NA>
    #> 13 I8F6BFTC                        Ethics   <NA>
    #> 14 F2HZII59 Moral Panics and Risk Society   <NA>
    #> 15 CRNZIRNE            Policy experiments   <NA>
    #> 16 IWPTPITN                   Foundations   <NA>
    #> 17 FZ74NFEN       Social Network Analysis   <NA>
    #> 18 EH5ZX8SB                     Critiques   <NA>
    #> 19 FC6AK8VG        Abduction/Retroduction   <NA>
    #> 20 JAXD7H8S                 Paradigm wars   <NA>
    ```
    
    Collections are identifed with unique `key`s. If any of the
    collections would be nested within some other collection, the key of
    the parent collection would appear in the column `parent`.

  - Fetch all items from a collection. By default the format returned is
    a JSON parsed to a list:
    
    ``` r
    items <- collection_items(key="PJHH85S9", user = zotero_group_id(269768))
    str(items[[1]])
    #> List of 6
    #>  $ key    : chr "4DMJB285"
    #>  $ version: int 2469
    #>  $ library:List of 4
    #>   ..$ type : chr "group"
    #>   ..$ id   : int 269768
    #>   ..$ name : chr "Computational Social Science"
    #>   ..$ links:List of 1
    #>   .. ..$ alternate:List of 2
    #>   .. .. ..$ href: chr "https://www.zotero.org/groups/computational_social_science"
    #>   .. .. ..$ type: chr "text/html"
    #>  $ links  :List of 3
    #>   ..$ self     :List of 2
    #>   .. ..$ href: chr "https://api.zotero.org/groups/269768/items/4DMJB285"
    #>   .. ..$ type: chr "application/json"
    #>   ..$ alternate:List of 2
    #>   .. ..$ href: chr "https://www.zotero.org/groups/computational_social_science/items/4DMJB285"
    #>   .. ..$ type: chr "text/html"
    #>   ..$ up       :List of 2
    #>   .. ..$ href: chr "https://api.zotero.org/groups/269768/items/ZAIHXBUJ"
    #>   .. ..$ type: chr "application/json"
    #>  $ meta   :List of 1
    #>   ..$ createdByUser:List of 4
    #>   .. ..$ id      : int 1284030
    #>   .. ..$ username: chr "brianckeegan"
    #>   .. ..$ name    : chr "Brian Keegan"
    #>   .. ..$ links   :List of 1
    #>   .. .. ..$ alternate:List of 2
    #>   .. .. .. ..$ href: chr "https://www.zotero.org/brianckeegan"
    #>   .. .. .. ..$ type: chr "text/html"
    #>  $ data   :List of 18
    #>   ..$ key         : chr "4DMJB285"
    #>   ..$ version     : int 2469
    #>   ..$ parentItem  : chr "ZAIHXBUJ"
    #>   ..$ itemType    : chr "attachment"
    #>   ..$ linkMode    : chr "imported_url"
    #>   ..$ title       : chr "Snapshot"
    #>   ..$ accessDate  : chr "2017-10-18T22:34:48Z"
    #>   ..$ url         : chr "http://onlinelibrary.wiley.com.colorado.idm.oclc.org/doi/10.1111/j.1083-6101.2005.tb00273.x/abstract"
    #>   ..$ note        : chr ""
    #>   ..$ contentType : chr "text/html"
    #>   ..$ charset     : chr "utf-8"
    #>   ..$ filename    : chr "abstract.html"
    #>   ..$ md5         : chr "dcfa02c0ad9fd84ac17e1d7560b987b0"
    #>   ..$ mtime       : num 1.51e+12
    #>   ..$ tags        : list()
    #>   ..$ relations   : Named list()
    #>   ..$ dateAdded   : chr "2017-10-18T22:34:48Z"
    #>   ..$ dateModified: chr "2019-12-16T17:32:29Z"
    ```
    
    The output format can be changed to e.g. BibTeX:
    
    ``` r
        items_bibtex <- collection_items(
          key="PJHH85S9", 
          user = zotero_group_id(269768), 
          query = list(format="bibtex")
        )
        # This will print all the entries...
        # cat(rawToChar(items_bibtex))
    
        # ... but to save space we show just the first three:
        entries <- head(strsplit(
          rawToChar(items_bibtex), 
          "\n\n"
        )[[1]], 3 )
        cat(entries, sep="\n\n")
    #> 
    #> @article{ling_using_2005,
    #>  title = {Using {Social} {Psychology} to {Motivate} {Contributions} to {Online} {Communities}},
    #>  volume = {10},
    #>  issn = {1083-6101},
    #>  url = {http://onlinelibrary.wiley.com.colorado.idm.oclc.org/doi/10.1111/j.1083-6101.2005.tb00273.x/abstract},
    #>  doi = {10.1111/j.1083-6101.2005.tb00273.x},
    #>  abstract = {Under-contribution is a problem for many online communities. Social psychology theories of social loafing and goal-setting can lead to mid-level design goals to address this problem. We tested design principles derived from these theories in four field experiments involving members of an online movie recommender community. In each of the experiments participated were given different explanations for the value of their contributions. As predicted by theory, individuals contributed when they were reminded of their uniqueness and when they were given specific and challenging goals. However, other predictions were disconfirmed. For example, in one experiment, participants given group goals contributed more than those given individual goals. The article ends with suggestions and challenges for mining design implications from social science theories.},
    #>  language = {en},
    #>  number = {4},
    #>  journal = {Journal of Computer-Mediated Communication},
    #>  author = {Ling, Kimberly and Beenen, Gerard and Ludford, Pamela and Wang, Xiaoqing and Chang, Klarissa and Li, Xin and Cosley, Dan and Frankowski, Dan and Terveen, Loren and Rashid, Al Mamunur and Resnick, Paul and Kraut, Robert},
    #>  month = jul,
    #>  year = {2005},
    #>  note = {Citation Key Alias: LingUsingSocialPsychology2005a},
    #>  pages = {00--00}
    #> }
    #> 
    #> @article{choi_coevolution_2007,
    #>  title = {The {Coevolution} of {Parochial} {Altruism} and {War}},
    #>  volume = {318},
    #>  copyright = {American Association for the Advancement of Science},
    #>  issn = {0036-8075, 1095-9203},
    #>  url = {http://science.sciencemag.org/content/318/5850/636},
    #>  doi = {10.1126/science.1144237},
    #>  abstract = {Altruism—benefiting fellow group members at a cost to oneself—and parochialism—hostility toward individuals not of one's own ethnic, racial, or other group—are common human behaviors. The intersection of the two—which we term “parochial altruism”—is puzzling from an evolutionary perspective because altruistic or parochial behavior reduces one's payoffs by comparison to what one would gain by eschewing these behaviors. But parochial altruism could have evolved if parochialism promoted intergroup hostilities and the combination of altruism and parochialism contributed to success in these conflicts. Our game-theoretic analysis and agent-based simulations show that under conditions likely to have been experienced by late Pleistocene and early Holocene humans, neither parochialism nor altruism would have been viable singly, but by promoting group conflict, they could have evolved jointly.
    #> Simulations show that altruism and parochialism may have coevolved, despite the negative costs of each, by yielding combined benefits through success in intergroup conflict.
    #> Simulations show that altruism and parochialism may have coevolved, despite the negative costs of each, by yielding combined benefits through success in intergroup conflict.},
    #>  language = {en},
    #>  number = {5850},
    #>  urldate = {2017-10-24},
    #>  journal = {Science},
    #>  author = {Choi, Jung-Kyoo and Bowles, Samuel},
    #>  month = oct,
    #>  year = {2007},
    #>  pmid = {17962562},
    #>  pages = {636--640}
    #> }
    #> 
    #> @article{bourke_colony_1999,
    #>  title = {Colony size, social complexity and reproductive conflict in social insects},
    #>  volume = {12},
    #>  issn = {1420-9101},
    #>  url = {http://onlinelibrary.wiley.com.colorado.idm.oclc.org/doi/10.1046/j.1420-9101.1999.00028.x/abstract},
    #>  doi = {10.1046/j.1420-9101.1999.00028.x},
    #>  abstract = {The broad limits of mature colony size in social insect species are likely to be set by ecological factors. However, any change in colony size has a number of important social consequences. The most fundamental is a change in the expected reproductive potential of workers. If colony size rises, workers experience a fall in their chances of becoming replacement reproductives and, it is shown, increasing selection for mutual inhibition of one another's reproduction (worker policing). As workers’ reproductive potential falls, the degree of dimorphism between reproductive and worker castes (morphological skew) can rise. This helps explain why small societies have low morphological skew and tend to be simple in organization, whereas large societies have high morphological skew and tend to be complex. The social consequences of change in colony size may also alter colony size itself in a process of positive feedback. For these reasons, small societies should be characterized by intense, direct conflict over reproduction and caste determination. By contrast, conflict in large societies should predominantly be over brood composition, and members of these societies should be relatively compliant to manipulation of their caste. Colony size therefore deserves fuller recognition as a key determinant, along with kin structure, of social complexity, the reproductive potential of helpers, the degree of caste differentiation, and the nature of within-group conflict.},
    #>  language = {en},
    #>  number = {2},
    #>  journal = {Journal of Evolutionary Biology},
    #>  author = {{Bourke}},
    #>  month = mar,
    #>  year = {1999},
    #>  keywords = {complexity, reproductive conflict, social evolution, social insect, worker policing},
    #>  pages = {245--257}
    #> }
    ```

  - Fetch all items from a collection and save to BibTeX file
    `references.bib`. Basically a conveniece wrapper for the example
    above.
    
    ``` r
    save_collection(
      key="PJHH85S9", 
      path = "references.bib",
      user = zotero_group_id(269768)
    )
    ```

  - `zotero_api()` is a low-level function. It will make multiple
    requests if the results do not fit a single response. The following
    will fetch all items in the “My Publications” collection of the
    default user:
    
    ``` r
    zotero_api(path="publications/items")
    ```

## Code of Conduct

Please note that the zoterro project is released with a [Contributor
Code of
Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
