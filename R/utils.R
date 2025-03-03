## Utility functions

#' Quit app
#' 
#' @description
#' Function to clean up database connection and quit app
#' 
#' @return None
#' 
#' @importFrom shiny stopApp
#' @importFrom shinyjs runjs
#' 
#' @noRd

QuitApp <- function(){
  
  # # Reset environment
  # env_setup(reset = TRUE)
  
  # Close the browser window
  shinyjs::runjs("window.close();")
  
  # Quit app
  shiny::stopApp()
}


#' Recentre map view
#' 
#' @description
#' Function to recentre map view to the correct extent. Correct extent should be
#' stored as an st_bbox object at atlas_env$bounds
#' 
#' @param map_proxy leaflet map proxy to be recentred
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
#' @importFrom leaflet flyToBounds
#' @import magrittr
#' 
#' @noRd

recentre_map <- function(map_proxy){
  
  map_proxy %>%
    leaflet::flyToBounds(
      lng1 = atlas_env$bounds[1] %>% as.numeric() - 0.4,
      lat1 = atlas_env$bounds[2] %>% as.numeric() - 0.4,
      lng2 = atlas_env$bounds[3] %>% as.numeric() + 0.4,
      lat2 = atlas_env$bounds[4] %>% as.numeric() + 0.4,
    )
  
  return(NULL)
}


#' Erase overlapping feature geometries
#' 
#' @description
#' An extension of sf::st_difference that erases all parts of x that overlap with y
#' 
#'
#' @param x an sf object
#' @param y an sf object
#'
#' @return sf object containing all geometries in x that do not overlap with y
#' 
#' @importFrom sf st_difference st_union st_combine
#' 
#' @noRd

st_erase <- function(x, y){
  sf::st_difference(x, sf::st_union(sf::st_combine(y)))
}


#' Assign node attributes
#' 
#' @description
#' Assigns nodes in atlas_env$layer_options tree such that icons can be rendered 
#' correctly when layer selection tree is renderes in app sidebar
#' 
#' 
#' @param tree Layer tree loaded from data_structure.yaml
#'
#' @return Nested list with assigned attributes for leafs and nodes
#' 
#' @noRd

assign_node_attrs <- function(tree) {
  for (name in names(tree)) {
    # If the node has children, treat it as a folder
    if (is.list(tree[[name]]) && length(tree[[name]]) > 0) {
      attr(tree[[name]], "sttype") <- "folder"
      # Recursively assign attributes to children
      tree[[name]] <- assign_node_attrs(tree[[name]])
    
    } else {
      # If the node has no children, treat it as a file
      attr(tree[[name]], "sttype") <- "file"
      
      # If no data is available assign the correct attribute to the node
      if (name == "None available") {
        attr(tree[[name]], "sttype") <- "none"
      }
    }
  }
  return(tree)
}



#' Open urls in web browser
#' 
#' @description
#' Takes a single url, or a list of urls, and passes each one to the machine's
#' default web browser for openining. Used to bulk download layers.
#' 
#' @param urls list of urls (or a single url) as character strings
#' @return NULL
#' @noRd

openURLs <- function(urls) {
  for (i in seq_along(urls)) {
    browseURL(urls[i])
  }
}
