
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
7.  You can use the available buttons/hyperlinks to (1) navigate to the
    data layer’s home webpage, (2) Load the layer into your active R
    session, (3) Download the layer directly to your computer, (4)
    perform the above actions in bulk for all selected layers and/or (5)
    download the table of layer names and urls.

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
[here](https://github.com/mariolambrette/CoastalHealth/tree/main.vignettes/app-structure.html)

If you wish to add additional data to the explorer, you can do so via a
pull request by following [these
intructions](https://github.com/mariolambrette/CoastalHealth/tree/main.vignettes/add-data.html)

## Attribution/Copyright

The Coastal Health Data Explorer is made available under the MIT open
license. The data made available via the tool is subject to the data
holder’s licence restrictions. The majority of data is availbel under an
Open Government License but users should should check any license
retrictions upon individual datasets (via the probvided web links)
before using/distributing them.
