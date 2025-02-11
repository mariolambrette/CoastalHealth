
<!-- README.md is generated from README.Rmd. Please edit that file -->
<table style="border-collapse: collapse; border: none; border-color: transparent;">
<tr style="border: none; border-color: transparent;">
<td style="border: none; padding-right: 10px; vertical-align: middle;">
<img src="inst/app/www/logo.png" width="90"/>
</td>
<td style="border: none; vertical-align: middle; border-color: transparent;">
<h1 style="margin: 0;">
Coastal Health Data Explorer
</h1>
</td>
</tr>
</table>
<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

## Installation

You can install the development version of the Coastal Health Data
Explorer like so:

``` r

devtools::install_github("mariolambrette/CoastalHealth")
```

## Run

You can launch the application by running:

``` r
library(CoastalHealth)
run_app()
```

## Instructions

1.  After running `run_app()` the Data Explorer will launch in a new tab
    in your browser
2.  You will be presented with a map of England and Wales.
3.  You can use the button in the bottom right corner of the screen to
    select one or more EA management catchment areas of inteest.
4.  The outline of the selected management catchments will be shown ot
    you and you can optionally use the sidebar to also render the
    rivers, lakes, waterbody outlines and the relevant marine area on
    the map.
5.  You can use the ‘Select Data Layers’ tab in the sidebar to select
    data layers that you are interested in by navigating the menu and
    highlighting layers of interest.
6.  Once you are happy with your selection you can click the confirm
    button and you will be shown a table containing all the selected
    layers.
7.  You can use the available buttons/hyperlinks to (i) navigate to the
    data layer’s home webpage, (2) Load the layer into your active R
    session, (3) Download the layer directly to your computer, (4)
    perform the above actions in bulk for all selected layers and/or (5)
    download the table of layer names and urls.

Where possible (i.e. where the data provider allows) data will be
spatially cropped to the management catchment area(s) and time period
selected.

## About

You are reading the doc about version : 0.0.0.9000

This README has been compiled on the

``` r
Sys.time()
#> [1] "2025-02-11 12:03:17 GMT"
```

Here are the tests results and package coverage:

``` r
devtools::check(quiet = TRUE)
#> ℹ Loading CoastalHealth
#> ── R CMD check results ─────────────────────────── CoastalHealth 0.0.0.9000 ────
#> Duration: 1m 18.4s
#> 
#> ❯ checking tests ...
#>   See below...
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
#>     installed size is 90.0Mb
#>     sub-directories of 1Mb or more:
#>       app       1.1Mb
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
#> ❯ checking R code for possible problems ... [11s] NOTE
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
#>   createtable: no visible binding for global variable 'name'
#>   createtable: no visible binding for global variable 'source_list'
#>   createtable: no visible binding for global variable 'url_list'
#>   createtable: no visible binding for global variable 'sf_compatible'
#>   createtable: no visible binding for global variable 'id'
#>   createtable: no visible binding for global variable
#>     'browser_compatible'
#>   createtable: no visible binding for global variable 'spatial_filtering'
#>   createtable: no visible binding for global variable
#>     'temporal_filtering'
#>   mod_area_server : <anonymous>: no visible binding for global variable
#>     'rbd_name'
#>   mod_area_server : <anonymous>: no visible binding for global variable
#>     'mncat_name'
#>   mod_layerpopup_server : <anonymous>: no visible binding for global
#>     variable 'name'
#>   Undefined global functions or variables:
#>     . browser_compatible geometry geometry.type id mncat_name name
#>     opcat_id rbd_name sf_compatible source_list spatial_filtering
#>     temporal_filtering type uri url_list water.body.type
#>   
#>   Found the following assignments to the global environment:
#>   File 'CoastalHealth/R/mod_layerpopup_fct_sf_handling.R':
#>     assign(x = id, value = sf::st_read(url), envir = .GlobalEnv)
#> 
#> ── Test failures ───────────────────────────────────────────────── testthat ────
#> 
#> > # This file is part of the standard setup for testthat.
#> > # It is recommended that you do not modify it.
#> > #
#> > # Where should you do additional test configuration?
#> > # Learn more about the roles of various files in:
#> > # * https://r-pkgs.org/testing-design.html#sec-tests-files-overview
#> > # * https://testthat.r-lib.org/articles/special-files.html
#> > 
#> > library(testthat)
#> Warning message:
#> package 'testthat' was built under R version 4.4.0 
#> > library(ExeAtlas)
#> Error in library(ExeAtlas) : there is no package called 'ExeAtlas'
#> Execution halted
#> 
#> 1 error ✖ | 2 warnings ✖ | 7 notes ✖
#> Error: R CMD check found ERRORs
```

``` r
covr::package_coverage()
#> CoastalHealth Coverage: 0.00%
#> R/app_config.R: 0.00%
#> R/app_server.R: 0.00%
#> R/app_ui.R: 0.00%
#> R/env_setup.R: 0.00%
#> R/golem_utils_server.R: 0.00%
#> R/golem_utils_ui.R: 0.00%
#> R/mod_area.R: 0.00%
#> R/mod_layerpopup.R: 0.00%
#> R/mod_layerpopup_fct_createtable.R: 0.00%
#> R/mod_layerpopup_fct_sf_handling.R: 0.00%
#> R/mod_layerselect.R: 0.00%
#> R/mod_Map.R: 0.00%
#> R/mod_Map_fct_BaseMap.R: 0.00%
#> R/mod_map_fct_GetLayers.R: 0.00%
#> R/mod_map_fct_PlotLayers.R: 0.00%
#> R/mod_wbview.R: 0.00%
#> R/on_load.R: 0.00%
#> R/run_app.R: 0.00%
#> R/utils.R: 0.00%
```

## Data availability
