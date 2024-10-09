#' Add layers to base map
#'
#' @description
#' Add layers onto the basic base map, including optional data layers
#'
#'
#' @param bm Basic basemap created with the BaseMap() function. Calls `BaseMap()` by default, though this not the ideal implementation when the function is used in production
#' @param add_layers A list of file paths to the layers to add
#'
#' @return A character string that contains the plotting command to be evaluated by `eval(parse(text = cmd))` to add the correct data layer to the base map
#' 
#'
#' @examples
#' 
#' \dontrun{
#' print(ggiraph::girafe(ggobj = AddLayers(bm)))
#'
#' # Complete plot
#' p <- BaseMap()
#' p1 <- AddLayers(bm = p)
#' p2 <- ggiraph::girafe(ggobj = p1)
#' print(p2)
#' }
#' 
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
#' @param name Name of the database table containing the spatial data
#' @param db.connection RSQLite database connection object
#'
#' @return
#' @export
#'
#' @examples
#'

LoadLayer <- function(name, db.connection = atlas_env$con){
  lyr <- tbl(db.connection,
             name) %>%
    collect() %>%
    mutate(geometry = sf::st_as_sfc(geom)) %>%
    select(-c(geom)) %>%
    sf::st_as_sf() %>%
    sf::st_set_crs(4326)
  
  return(lyr)
}