
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
Explorer in R/RStudio like so:

``` r

devtools::install_github("mariolambrette/CoastalHealth", build_vignettes = TRUE)
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
3.  You can use the button in the top left corner of the screen to
    select one or more Environment Agency (EA) management catchment
    areas of interest.
4.  The outline of the selected management catchments will be shown to
    you and you can optionally use the sidebar to also render the
    rivers, lakes, waterbody outlines and the relevant marine area on
    the map.
5.  You can use the ‘Select Data Layers’ tab in the sidebar to select
    data layers that you are interested in by navigating the menu and
    highlighting layers of interest.
6.  Some layers contain temporal data. You can use the date range
    selection in the sidebar to select a time period of interest. Where
    possible, data will be filtered to this time period.
7.  Once you are happy with your selection you can click the confirm
    button and you will be shown a table containing all the selected
    layers.
8.  You can use the available buttons/hyperlinks to (1) navigate to the
    data layer’s home webpage, (2) load the layer into your active R
    session, (3) download the layer directly to your computer, (4)
    perform the above actions in bulk for all selected layers and/or (5)
    download the table of layer names and urls.
9.  When you have finished you can close the app and return to your R
    session by either (1) closing the browser tab running the app or (2)
    pressing the ‘Quit’ button in the top left of the screen. If the app
    crashes or closes in some other way, you can still relaunch it but
    may find some odd behaviour on start up. If this happens, close the
    app ‘properly’ and relaunch it.

Where possible (i.e. where the data provider allows) data will be
spatially cropped to the management catchment area(s) and time period
selected.

## Bug reports

If you find any bugs/problems with the Coastal Health Data explorer
please submit an issue
[here](https://github.com/mariolambrette/CoastalHealth/issues). You can
also use issues to suggest datasets to be added to the tool.
Alternatively, if you have ideas for developments/improvements you can
contact the authors directly or submit a pull request. Specific
instructions for adding additional data to the explorer are detailed
below.

## For Developers

This repository is publicly available and we are always open to
suggestions for improvement. If you have any suggestions, you can submit
an issue or a pull request.

For more information on the architecture of the data explorer please see
[here](https://github.com/mariolambrette/CoastalHealth/blob/main/data-raw/github_documentation/app-structure-github.md)

If you wish to add additional data to the explorer, you can do so via a
pull request by following [these
intructions](https://github.com/mariolambrette/CoastalHealth/blob/main/data-raw/github_documentation/add-data-github.md)

## Attribution/Copyright

The Coastal Health Data Explorer is made available under the MIT open
license. The data made available via the tool is subject to the data
holder’s licence restrictions. The majority of data is availbel under an
Open Government License but users should should check any license
retrictions upon individual datasets (via the probvided web links)
before using/distributing them.
