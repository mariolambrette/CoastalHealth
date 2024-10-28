#' Add layers to base map
#'
#' @description
#' Add layers onto the basic base map, including optional data layers
#'
#' @param add_layers A list of names of layers to add
#' @param db.connection Connection to ExeAtlas database
#'
#' @return A character string that contains the plotting command to be evaluated by `eval(parse(text = cmd))` to add the correct data layer to the base map
#' 
#' @importFrom magrittr `%>%`
#' @importFrom dplyr tbl filter select collect pull

AddLayers <- function(add_layers = 'none',
                      db.connection = atlas_env$con){
  
  if (add_layers == 'none') {
    return()
  }
  
  # Extract the plotting command for the selected layer from the database
  plot_cmd <- dplyr::tbl(db.connection, "SHP_lookup") %>%
    dplyr::filter(SHP_name == add_layers) %>%
    dplyr::select(aes) %>%
    dplyr::collect() %>%
    dplyr::pull(aes)
  
  return(plot_cmd)
  
}

#' Load spatial layers from database
#'
#' @description
#' Uses the table name, supplied to the parameter `name` and a database connection
#' to load spatial layers stored in the database, returning an sf object ready for
#' plotting. Relies on spatial data having been loaded into the database as an
#' sf object, projected in wgs84 (epsg: 4326) with the geometry converted to WKT
#' format in a column called 'geom'
#' 
#' Used within the plotting commands that are created for each layer and stored
#' in the ExeAtlas database.
#'
#' @param name Name of the database table containing the spatial data
#' @param db.connection RSQLite database connection object
#'
#' @return sf object containing data layer
#'
#' @importFrom magrittr `%>%`
#' @importFrom dplyr tbl collect mutate select
#' @importFrom sf st_as_sf st_set_crs

LoadLayer <- function(name, db.connection = atlas_env$con){
  lyr <- dplyr::tbl(db.connection,
                    name) %>%
    dplyr::collect() %>%
    dplyr::mutate(geometry = sf::st_as_sfc(geom)) %>%
    dplyr::select(-c(geom)) %>%
    sf::st_as_sf() %>%
    sf::st_set_crs(4326)
  
  return(lyr)
}