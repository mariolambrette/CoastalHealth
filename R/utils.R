## Utility functions


#' Quit app
#' 
#' @description
#' Function to clean up database connection and quit app
#' 
#' @return None
#' 
#' @importFrom RSQLite dbDisconnect
#' @importFrom shiny stopApp
#' @importFrom shinyjs runjs
#' 

QuitApp <- function(){
  # Quit app
  shiny::stopApp()
  
  # Close the browser window
  shinyjs::runjs("window.close();")
}


#' Recetnre map view
#' 
#' @description
#' Function to recentre map view to the correct extent. Correct extent should be
#' stored as an st_bbox object at atlas_env$bounds
#' 
#' 
#' @return NULL - updates the view of an existing map
#' 
#'
#' @examples
#' \dontrun{
#'  output$map <- BaseMap()
#'  
#'  recentre_map(leaflet::leafletProxy("map", session), atlas_env$map_bounds)
#' }
#' 
#' @importFrom leaflet fitBounds
recentre_map <- function(map_proxy){
  
  map_proxy %>%
    leaflet::fitBounds(
      lng1 = atlas_env$bounds[1] %>% as.numeric(),
      lat1 = atlas_env$bounds[2] %>% as.numeric(),
      lng2 = atlas_env$bounds[3] %>% as.numeric(),
      lat2 = atlas_env$bounds[4] %>% as.numeric()
    )
  
  return(NULL)
}



#' Erase overlapping feature geometries
#' 
#' @description
#' An extension of sf::st_difference that erases all parts of x that overlap with y
#' 
#'
#' @param x 
#' @param y 
#'
#' @return sf object containing all geometries in x that do not overlap with y
#' 
#' @importFrom sf st_difference st_union st_combine

st_erase <- function(x, y){
  sf::st_difference(x, sf::st_union(sf::st_combine(y)))
} 
