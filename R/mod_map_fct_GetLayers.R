## Functions for retireving layers to add to map. Each additional data layer
## has its own retrieval function that access the correct API in the correct way
## Some data layers are cropped to the user defined spatial extent, others cannot
## be and are left as full layer extents. Where appropriate, layers are retrieved
## and stored as sf-compatible objects. In cases where WMS products are available
## these are used (these are added directly, the retrieval function simply returns
## the correct URL)



#' Get selected operational catchment outlines as sf polygons for adding to map
#'
#' @return sf object with selected operational catchments represented as polygons
#'
#' @examples
#' \dontrun{
#' opcat.polygons <- Get_opcats()
#' }
#' 
#' @importFrom sf st_read
#' @importFrom dplyr filter
 
Get_opcats <- function(){
  
  # Read the geoJSON file containing all opcats and filter for user selection
  opcats.spatial <- sf::st_read(
    system.file("extdata", "OperationalCatchmentsSpatial.gpkg", package = "ExeAtlas"),
    quiet = TRUE
  ) %>%
    dplyr::filter(opcat_id %in% atlas_env$opcats()$opcat_id)
  
  return(opcats.spatial)
}

#' Get selected water body data as sf lines and polygons
#'
#' @return NULL - atlas_env level reactive values containing river, lake and 
#'  boundary data are modified within the function to trigger plotting functions 
#'  in the map server function.
#'

Get_wbs <- function(){
  
  # Use opcat information to download and format relevant water body data
  wbs <- atlas_env$opcats() %>%
    dplyr::pull(opcat_id) %>%
    plyr::ldply(
      .,
      function(id){
        wb_url <- sprintf("https://environment.data.gov.uk/catchment-planning/OperationalCatchment/%s.geojson", id)
        wb_data <- sf::st_read(wb_url, quiet = TRUE)
        return(wb_data)
      }
    ) %>%
    dplyr::select(-uri, -geometry.type) %>%
    dplyr::mutate(type = sf::st_geometry_type(geometry))
  
  # Split the water body data into lakes, river and wb outlines and store each
  # element in the relevant place in the atlas_env
  atlas_env$wb_spatial$rivers <- wbs %>%
    dplyr::filter(type == "MULTILINESTRING", grepl("River", water.body.type))
  atlas_env$wb_spatial$lakes <- wbs %>%
    dplyr::filter(type == "POLYGON", grepl("Lake", water.body.type))
  atlas_env$wb_spatial$outlines <- wbs %>%
    dplyr::filter(type == "POLYGON", grepl("River", water.body.type))
 
}


#' Calculate marine area based on selected opcats
#'
#' @return NULL - stores an sf object describing the marine area to 
#'  atlas_env$marinearea
#'
#' @importFrom sf st_as_sf st_transform st_union st_buffer st_difference

Get_marinearea <- function(){
  
  atlas_env$marinearea <- isolate(atlas_env$opcats_spatial()) %>%
    sf::st_as_sf() %>%
    sf::st_simplify(preserveTopology = TRUE, dTolerance = 10) %>%
    sf::st_set_precision(1e5) %>%
    sf::st_transform(., crs = 27700) %>%
    sf::st_union(., by_feature = FALSE) %>%
    sf::st_cast(., "MULTILINESTRING") %>%
    sf::st_buffer(., dist = 100) %>%
    sf::st_intersection(., atlas_env$land %>%
                          sf::st_set_precision(1e5) %>%
                          sf::st_cast(., "MULTILINESTRING")) %>%
    sf::st_buffer(., dist = 22224) %>%
    sf::st_union() %>%
    st_erase(., atlas_env$land) %>%
    sf::st_transform(crs = 4326)
  
}




Get_seasubstrate <- function(){
  
}