## Function for plotting additional layers. Each additional data layer has its
## own plotting function (though these may be grouped where appropiate).
## Selectoing the additional layer first triggers the retrieval function and then
## the plotting function which displays the layer on the main leaflet map. Layer
## symbology is left as simple as possible to enable multiple layers to be
## plotted. These plots are not designed for data analysis - they simply show 
## data coverage and enable users to rapidly locate and download the source
## data for subsequent analyses.
## Where possible generic point, polygon, line, raster and WMS functions should
## be used.


#' Plot selected operational catchments
#'
#' @return NULL - updates the existing leaflet map
#' 
#'
#' @examples
#' \dontrun{
#' Plot_opcats()
#' }
#' 
#' @importFrom leaflet clearGroup addPolygons fitBounds
#' @importFrom sf st_bbox

Plot_opcats <- function(map_proxy){
  
  # Ensure the spatial data table is populated
  req(nrow(atlas_env$opcats_spatial()) > 0)
  
  # Get the bounds of the opcat layer
  atlas_env$bounds <- sf::st_bbox(atlas_env$opcats_spatial()) # Get bounding box of the spatial data
  
  map_proxy %>%
    leaflet::clearGroup("opcats") %>%
    leaflet::addPolygons(
      data = atlas_env$opcats_spatial(),
      group = "opcats",
      color = "black",
      opacity = 1,
      weight = 2,
      fillOpacity = 0.03,
      options = pathOptions(pane = "overlay")
    ) %>%
    leaflet::fitBounds(
      lng1 = atlas_env$bounds[1] %>% as.numeric(),
      lat1 = atlas_env$bounds[2] %>% as.numeric(),
      lng2 = atlas_env$bounds[3] %>% as.numeric(),
      lat2 = atlas_env$bounds[4] %>% as.numeric()
    )
  
  return(NULL)
}


#' Family of functions to plot waterbody sptial data
#' 
#' @description
#' The below functions display the various spatial ekements of waterbodies (rivers,
#' lakes and the actual water body boundaries). These functions are triggered
#' by user inputs to checkboxes in the main app sidepanel
#'
#' @param map_proxy 
#'
#' @return NULL - updates the existing map
#'

Plot_wbs_rivers <- function(map_proxy){
  
  # Update view of waterbody rivers based on user input
  if (atlas_env$wb_triggers$rivers) {
    map_proxy %>%
      leaflet::addPolylines(
        data = atlas_env$wb_spatial$rivers %>%
          sf::st_as_sf(),
        color = "#2674c5",
        weight = 2,
        opacity = 1,
        fill = F,
        group = "rivers",
        options = pathOptions(pane = "overlay")
      )
  } else {
    map_proxy %>%
      leaflet::clearGroup("rivers")
  }
}

Plot_wbs_outlines <- function(map_proxy){
  
  # Update view of waterbody outlines based on user input
  if (atlas_env$wb_triggers$outlines) {
    map_proxy %>%
      leaflet::addPolygons(
        data = atlas_env$wb_spatial$outlines %>%
          sf::st_as_sf(),
        color = "black",
        weight = 1,
        opacity = 1,
        dashArray = "4,4",
        fill = T,
        fillOpacity = 0,
        group = "outlines",
        options = pathOptions(pane = "overlay")
      )
  } else {
    map_proxy %>%
      leaflet::clearGroup("outlines")
  }
}

Plot_wbs_lakes <- function(map_proxy){
  
  # Update view of waterbody lakes based on user input
  if (atlas_env$wb_triggers$lakes) {
    map_proxy %>%
      leaflet::addPolygons(
        data = atlas_env$wb_spatial$lakes %>%
          sf::st_as_sf(),
        color = "#2674c5",
        weight = 1,
        opacity = 1,
        fill = T,
        fillOpacity = 1,
        group = "lakes",
        options = pathOptions(pane = "overlay")
      )
  } else {
    map_proxy %>%
      leaflet::clearGroup("lakes")
  }
}


#' Plot marine area
#' 
#' @description
#' This function plots the marine area onto the existing leaflet basemap. It is 
#' seperate to the waterbody family functions as the data displayed is calculated 
#' rather than sourced from the EA but in is executed in the same way from the 
#' wbview module following the user ticking the marinearea box.
#' 
#'
#' @return NULL - plots marine area directly onto leaflet map given by map_proxy
#'

Plot_marinearea <- function(map_proxy){
  if (atlas_env$wb_triggers$marine) {
    map_proxy %>%
      leaflet::addPolygons(
        data = atlas_env$marinearea,
        color = "#2674c5",
        weight = 2,
        opacity = 1,
        fill = TRUE,
        fillOpacity = 0.03,
        group = "marinearea",
        options = pathOptions(pane = "overlay")
      )
  } else {
    map_proxy %>%
      leaflet::clearGroup("marinearea")
  }
}


