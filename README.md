
<!-- README.md is generated from README.Rmd. Please edit that file -->

<div style="display: flex; align-items: center;">

<img src="app/www/logo.svg" width="80" style="margin-right: 10px;"/>
<h1>
Coastal Health Data Explorer
</h1>

</div>

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of `{ExeAtlas}` like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Run

You can launch the application by running:

``` r
ExeAtlas::run_app()
```

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-02-10 11:52:20 GMT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading ExeAtlas
#> ── R CMD check results ──────────────────────────────── ExeAtlas 0.0.0.9000 ────
#> Duration: 1m 38.1s
#> 
#> ❯ checking for missing documentation entries ... WARNING
#>   Undocumented code objects:
#>     'app_server' 'app_ui'
#>   All user-level objects in a package should have documentation entries.
#>   See chapter 'Writing R documentation files' in the 'Writing R
#>   Extensions' manual.
#> 
#> ❯ checking Rd \usage sections ... WARNING
#>   Undocumented arguments in documentation object 'recentre_map'
#>     'map_proxy'
#>   
#>   Functions with \usage entries need to have the appropriate \alias
#>   entries, and all their arguments documented.
#>   The \usage entries must correspond to syntactically valid R code.
#>   See chapter 'Writing R documentation files' in the 'Writing R
#>   Extensions' manual.
#> 
#> ❯ checking package dependencies ... NOTE
#>   Imports includes 25 non-default packages.
#>   Importing from so many packages makes the package vulnerable to any of
#>   them becoming unavailable.  Move as many as possible to Suggests and
#>   use conditionally.
#> 
#> ❯ checking installed package size ... NOTE
#>     installed size is 89.8Mb
#>     sub-directories of 1Mb or more:
#>       extdata  88.8Mb
#> 
#> ❯ checking for future file timestamps ... NOTE
#>   unable to verify current time
#> 
#> ❯ checking top-level files ... NOTE
#>   Non-standard file/directory found at top level:
#>     'notebook'
#> 
#> ❯ checking package subdirectories ... NOTE
#>   Problems with news in 'NEWS.md':
#>   No news entries found.
#> 
#> ❯ checking dependencies in R code ... NOTE
#>   Namespaces in Imports field not imported from:
#>     'htmlwidgets' 'plotly' 'reactablefmtr' 'tibble' 'tidyr'
#>     All declared Imports should be used.
#> 
#> ❯ checking R code for possible problems ... [13s] NOTE
#>   Get_marinearea: no visible binding for global variable '.'
#>   Get_opcats: no visible binding for global variable 'opcat_id'
#>   Get_wbs: no visible binding for global variable 'opcat_id'
#>   Get_wbs: no visible binding for global variable '.'
#>   Get_wbs: no visible binding for global variable 'uri'
#>   Get_wbs: no visible binding for global variable 'geometry.type'
#>   Get_wbs: no visible binding for global variable 'geometry'
#>   Get_wbs: no visible binding for global variable 'type'
#>   Get_wbs: no visible binding for global variable 'water.body.type'
#>   Plot_opcats: no visible binding for global variable '.'
#>   mod_area_server : <anonymous>: no visible binding for global variable
#>     'mncat_name'
#>   mod_layerpopup_server : <anonymous>: no visible binding for global
#>     variable 'name'
#>   Undefined global functions or variables:
#>     . geometry geometry.type mncat_name name opcat_id type uri
#>     water.body.type
#>   
#>   Found the following assignments to the global environment:
#>   File 'ExeAtlas/R/mod_layerpopup_fct_sf_handling.R':
#>     assign(x = id, value = sf::st_read(url), envir = .GlobalEnv)
#> 
#> 0 errors ✔ | 2 warnings ✖ | 7 notes ✖
#> Error: R CMD check found WARNINGs
```

``` r
covr::package_coverage()
#> ExeAtlas Coverage: 43.00%
#> R/env_setup.R: 0.00%
#> R/mod_layerpopup_fct_createtable.R: 0.00%
#> R/mod_layerpopup_fct_sf_handling.R: 0.00%
#> R/mod_map_fct_GetLayers.R: 0.00%
#> R/on_load.R: 0.00%
#> R/run_app.R: 0.00%
#> R/mod_layerpopup.R: 6.10%
#> R/mod_map_fct_PlotLayers.R: 15.00%
#> R/mod_layerselect.R: 21.43%
#> R/mod_area.R: 28.26%
#> R/utils.R: 40.00%
#> R/app_server.R: 48.57%
#> R/mod_wbview.R: 75.00%
#> R/mod_Map.R: 82.86%
#> R/app_config.R: 100.00%
#> R/app_ui.R: 100.00%
#> R/golem_utils_server.R: 100.00%
#> R/golem_utils_ui.R: 100.00%
#> R/mod_Map_fct_BaseMap.R: 100.00%
```

## Data availability
