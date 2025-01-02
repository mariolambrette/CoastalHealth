#' Leaflet basemap for Coastal Health data explorer
#' 
#' @description
#' `BaseMap` returns a leaflet map that contains a basemap of england (either as
#' OpenStreetMap, the ESRI grey canvas, or a plain outline of the UK mainland) 
#' with placeholders for other data layers to be displayed. The function has no 
#' arguments but the returned map can be modified by using `leafletProxy`
#'   
#' @return A leaflet base map to be modified using `leafletProxy`
#' @export
#' 
#' @examples
#' map <- BaseMap()
#' 
#' @importFrom leaflet leaflet addTiles setView addMapPane addLayersControl 
#'  setMaxBounds pathOptions leafletOptions
#' 
#' 

BaseMap <- function(){
  
  ## Mapbox basemap
  bm <- NULL ## ADD A PLAIN BASEMAP FROM MAPBOX
  
  map <- leaflet::leaflet(options = leaflet::leafletOptions(
    minZoom = NULL,
    maxZoom = NULL)
  ) %>%
    # leaflet::addTiles(urlTemplate = bm,
    #                   group = "BaseMap",
    #                   options = list(minZoom = 7)) %>%
    leaflet::addTiles(group = "OpenStreetMap",
                      options = list(minZoom = 3)) %>%
    leaflet::addTiles(group = "GreyCanvas",
                      urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
                      options = list(minZoom = 3)) %>%
    # Defines the view of the map when the app is launched
    leaflet::setView(lng = -3.3, lat = 50.8, 
                     zoom = 10, 
                     options = list(maxZoom = 25)) %>%
    # Add a pane for each category of layers that can be displayed.
    # These are placeholders for layers to be inserted later
    leaflet::addMapPane("rasters",  zIndex = 410) %>%
    leaflet::addMapPane("polygons", zIndex = 420) %>%
    leaflet::addMapPane("lines",    zIndex = 430) %>%
    leaflet::addMapPane("points",   zIndex = 440) %>%
    leaflet::addMapPane("overlay",  zIndex = 490) %>%
    # Switch between basemap options
    leaflet::addLayersControl(baseGroups = c("OpenStreetMap", "GreyCanvas", "BaseMap")) %>%
    # Set maximum map extent (~25km buffer around England)
    leaflet::setMaxBounds(
      lng1 = -6.13,
      lat1 = 49.68,
      lng2 = 2.12, 
      lat2 = 56.04
    )
  
  return(map)
}
