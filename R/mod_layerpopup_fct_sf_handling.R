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
#' @importFrom sf read_sf st_crop st_as_sfc
#' @importFrom arcgislayers arc_open arc_select
#' 
#' @noRd

load_sf <- function(url, id) {

  tryCatch(
    {
      suppressWarnings(
        assign(
          x     = id,
          value = sf::read_sf(url) %>%
            sf::st_crop(., sf::st_as_sfc(atlas_env$bounds)),
          envir = .GlobalEnv
        )
      )
    },
    error = function(e) {
      message("Cannot load layer: ", id)
    }
  )

}

load_sf2 <- function(url, id) {
  tryCatch(
    {
      suppressWarnings({
        if (grepl("FeatureServer|MapServer", url)) {
          
          # Ensure url points to a specific layer
          if (!grepl("\\d+$", url)) {
            url <- paste0(url, "/0")
          }
          
          layer <- arcgislayers::arc_open(url)
          
          # Use server-side spatial filtering where possible
          if (!is.null(atlas_env$bounds)) {
            bbox_sf <- sf::st_as_sfc(atlas_env$bounds)
            sf_obj <- arcgislayers::arc_select(layer, filter_geom = bbox_sf)
          } else {
            sf_obj <- arcgislayers::arc_select(layer)
          }
          
        } else {
          sf_obj <- sf::read_sf(url)
          
          if (!is.null(atlas_env$bounds)) {
            sf_obj <- sf::st_crop(sf_obj, sf::st_as_sfc(atlas_env$bounds))
          }
        }
        
        assign(x = id, value = sf_obj, envir = .GlobalEnv)
      })
    },
    error = function(e) {
      message("Cannot load layer: ", id, " - ", e$message)
    }
  )
}