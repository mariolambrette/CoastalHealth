## Functions to handle sf objects when the layer popup is displayed.
# i.e. to load single or multiple sf objects into users global environment

#' Load sf object to global environment
#'
#' @param id String denoting the varibale name to assign the sf object to
#' @param url String denoting the url to provide to sf for loading
#'
#' @return NULL - assigns result to global environment
#'
#' @examples
#' \dontrun{
#'  load_sf("example_layer", "https://ows.emodnet-humanactivities.eu/wfs?request
#'    =GetFeature&service=WFS&version=1.1.0&outputFormat=application%2Fjson&type
#'    Name=emodnet:shellfish")
#' }
#' 
#' @importFrom sf read_sf
#' 
#' @noRd

load_sf <- function(url, id) {
  
  assign(
    x     = id, 
    value = sf::read_sf(url), 
    envir = .GlobalEnv
  )
  
}




