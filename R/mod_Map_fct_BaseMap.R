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
  
  map <- leaflet::leaflet(options = leaflet::leafletOptions(
    minZoom = NULL,
    maxZoom = NULL)
  ) %>%
    leaflet::addTiles(group = "OpenStreetMap",
                      options = list(minZoom = 4.5)) %>%
    leaflet::addTiles(urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                      group = "Satellite",
                      options = list(minZoom = 4.5)) %>%
    leaflet::addTiles(group = "GreyCanvas",
                      urlTemplate = "https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}",
                      options = list(minZoom = 4.5)) %>%
    # Defines the view of the map when the app is launched
    leaflet::setView(lng = -1.4657, lat = 52.5648, 
                     zoom = 7, 
                     options = list(maxZoom = 25)) %>%
    # Add a pane for each category of layers that can be displayed.
    # These are placeholders for layers to be inserted later
    leaflet::addMapPane("underlay", zIndex = 405) %>%
    leaflet::addMapPane("rasters",  zIndex = 410) %>%
    leaflet::addMapPane("polygons", zIndex = 420) %>%
    leaflet::addMapPane("lines",    zIndex = 430) %>%
    leaflet::addMapPane("points",   zIndex = 440) %>%
    leaflet::addMapPane("overlay",  zIndex = 490) %>%
    # Switch between basemap options
    leaflet::addLayersControl(baseGroups = c("OpenStreetMap", "GreyCanvas", "Satellite")) %>%
    # Set maximum map extent (~25km buffer around England)
    leaflet::setMaxBounds(
      lng1 = -7.2,
      lat1 = 49.68,
      lng2 = 2.12, 
      lat2 = 56.04
    )
  
  return(map)
}
