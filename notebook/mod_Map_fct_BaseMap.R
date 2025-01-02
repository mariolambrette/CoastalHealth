#' Import spatial shapefiles from database
#'
#' @description
#' Imports all the 'spatial' (`SPA`) category shapefiles from the SQL database and returns them in a named list.
#' These are the basic files that make up the outline of the map (e.g. background layers and catchment outlines)
#'
#'
#' @param db.connection SQLite Connection to ExeAtlas database
#'
#' @return Named list of sf objects relating to the `SPA` category data in the specified database
#' 
#' @examples
#' \dontrun{
#'  shps <- ImportSPA(con)
#' }
#' 
#' @importFrom magrittr `%>%`
#' @importFrom dplyr tbl filter select collect mutate
#' @importFrom plyr llply
#' @importFrom sf st_as_sf st_as_sfc
#' 

ImportSPA <- function(db.connection){
  
  # Extract the spatial shapefile table names from the SHP_lookup table
  tbls <- dplyr::tbl(db.connection, 'SHP_lookup') %>%
    dplyr::filter(sql('SUBSTR(SHP_name, INSTR(SHP_name, "SPA"), 3) COLLATE BINARY = "SPA"')) %>%
    dplyr::select(SHP_name) %>%
    dplyr::collect() %>%
    as.list() %>%
    .[[1]]
  
  shps <- plyr::llply(
    tbls,
    function(x){
      shp <- dplyr::tbl(db.connection, x) %>%
        dplyr::collect() %>%
        dplyr::mutate(geometry = sf::st_as_sfc(geom)) %>%
        dplyr::select(-c(geom)) %>%
        sf::st_as_sf()
      
      return(shp)
    }
  )
  
  names(shps) <- tbls
  
  return(shps)
}


#' Study site base map
#'
#' @description
#' `BaseMap` returns a leaflet map that contains the outline and spatial elements
#'  of the ExeAtlas study area including site outlines and subcatchments
#'
#' @details
#' The function has no arguments but it loads data from the SQL database using
#'  the connection established by `CreateConnection()` when the app is first launched,
#'  or, ideally, relies on `SPA` shapefiles having been loaded into the parent environment already
#'  using the `ImportSPA()` function.
#' 
#' @param shps A named list of spatial files for the study area created with `ImportSPA`
#' 
#' @return A leaflet map containing the outline and spatial elements of the ExeAtlas
#'  study site, including subcatchment outlines.
#'
#' @examples
#' \dontrun{
#'  p <- BaseMap()
#' }
#' 
#' @importFrom leaflet leaflet leafletOptions addTiles setView addMapPane 
#'  pathOptions highlightOptions addLayersControl setMaxBounds addPolylines 
#'  addPolygons
#' @importFrom magrittr `%>%`

BaseMap <- function(shps = ImportSPA(db.connection = atlas_env$con)){
  
  # Mapbox basemap
  bm <- "https://api.mapbox.com/styles/v1/mariolambrette/clw9fkmew001t01pn78nha4h7/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1IjoibWFyaW9sYW1icmV0dGUiLCJhIjoiY2x3OWVndWM3MDJucjJpb2V4aDVhaG9hZiJ9.aMkkVmXb1K_9KQEUB-fm9Q"
  
  map <- leaflet::leaflet(options = leaflet::leafletOptions(
    minZoom = NULL,
    maxZoom = NULL)
  ) %>%
    leaflet::addTiles(urlTemplate = bm,
                      group = "BaseMap",
                      options = list(minZoom = 7)) %>%
    leaflet::addTiles(group = "OpenStreetMap",
                      options = list(minZoom = 10)) %>%
    # Defines the view of the map when the app is launched
    leaflet::setView(lng = -3.3, lat = 50.8, zoom = 10, options = list(maxZoom = 25)) %>%
    # Add a pane for each category of layer that can be displayed
    # These are placeholders for layers to be inserted later
    leaflet::addMapPane("mng_layers",      zIndex = 410) %>%
    leaflet::addMapPane("highlight_polys", zIndex = 420) %>%
    leaflet::addMapPane('lc_layers',       zIndex = 430) %>%
    leaflet::addMapPane("overlay_spatial", zIndex = 490) %>%
    leaflet::addMapPane("outline",         zIndex = 495) %>%
    leaflet::addMapPane("dat_points",      zIndex = 496) %>%
    leaflet::addPolylines(data = shps$SHP_SPA_ri,
                          color = '#2674c5',
                          weight = 2,
                          opacity = 1,
                          fill = F,
                          group = 'ri',
                          options = pathOptions(pane = "overlay_spatial")) %>%
    leaflet::addPolygons(data = shps$SHP_SPA_sc,
                         color = 'black',
                         weight = 1,
                         opacity = 1,
                         dashArray = "4,4",
                         fill = T,
                         fillOpacity = 0,
                         layerId = shps$SHP_SPA_sc$ID,
                         highlightOptions = highlightOptions(color = 'darkgrey',
                                                             dashArray = "1",
                                                             weight = 1.5,
                                                             bringToFront = F,
                                                             sendToBack = F),
                         group = 'sc',
                         options = pathOptions(pane = "overlay_spatial",
                                               clickable = T)) %>%
    leaflet::addPolygons(data = shps$SHP_SPA_ss,
                         color = '#EF1777',
                         weight = 2,
                         opacity = 1,
                         fill = F,
                         group = 'ss',
                         options = pathOptions(pane = "outline")) %>%
    leaflet::addPolygons(data = shps$SHP_SPA_cs,
                         color = '#EF1777',
                         weight = 2,
                         opacity = 1,
                         fill = F,
                         group = 'cs',
                         options = pathOptions(pane = "outline")) %>%
    leaflet::addLayersControl(baseGroups = c("Basemap", "OpenStreetMap")) %>%
    leaflet::setMaxBounds(lng1 = -4.28,
                          lat1 = 50.13,
                          lng2 = -2.39,
                          lat2 = 51.35)
  
  return(map)
}
