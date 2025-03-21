Coastal Health Data Explorer Architecture (For Developers)
================

The Coastal Health Data Explorer is an open source package and the
authors welcome any suggestions/developments. In order to support future
development, here we provide an overview of the package architecture to
help potential developers navigate the package.

## Shiny modules

The app is divided into the following shiny modules, each serving a
specific purpose

- mod_area - Management catchment area selection
- mod_layerpopup - Manages the popup table that shows the user selected
  data layers and provides links for viewing/downloading them
- mod_layerselect - Displays and manages the layer selection tree in the
  app sidebar
- mod_map - Displays the basemap and any additional layers.
- mod_wbview - Displays toggles in the app sidebar for showing/hiding
  additional layers.

## Package environment

The passing of internal data between modules, and other internal package
varibales are stored in a package enviornment. This environment is
created by `env_setup()` and initally contains placeholders for all
internal variables. The `env_setup()` function is also used to reset the
package environent to the default state when required.
