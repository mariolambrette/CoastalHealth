## Functions for retireving layers to add to map. Each additional data layer
## has its own retrieval function that access the correct API in the correct way
## Some data layers are cropped to the user defined spatial extent, others cannot
## be and are left as full layer extents. Where appropriate, layers are retrieved
## and stored as sf-compatible objects. In cases where WMS products are available
## these are used (these are added directly, the retrieval function simply returns
## the correct URL). For larger layers the Get_*() function creates and stores
## the URL where the data is stored but no data is downloaded until the user
## activates the plotting functions.



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
#' @importFrom dplyr filter bind_rows
 
Get_opcats <- function(){
  
  # Read the geoJSON file containing all opcats and filter for user selection
  opcats.spatial <- sf::st_read(
    system.file("extdata", "OperationalCatchmentsSpatial.gpkg", package = "CoastalHealth"),
    quiet = TRUE
  ) %>%
    dplyr::filter(opcat_id %in% atlas_env$opcats()$opcat_id)
  
  # Generate the download URLS for selected catchments
  atlas_env$layer_urls <- dplyr::bind_rows(
    atlas_env$layer_urls,
    data.frame(
      layer_name    = paste0("Operational catchment ", atlas_env$opcats()$opcat_id, " (includes water body data)"),
      shapefile_url = paste0("https://environment.data.gov.uk/catchment-planning/OperationalCatchment/", atlas_env$opcats()$opcat_id, "/shapefile.zip"),
      geojson_url   = paste0("https://environment.data.gov.uk/catchment-planning/OperationalCatchment/", atlas_env$opcats()$opcat_id, ".geojson")
    )
  )
  
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
 
  ## These layers are found within the opcat layer download
  
}


#' Calculate marine area based on selected opcats
#'
#' @return NULL - stores an sf object describing the marine area to 
#'  atlas_env$marinearea
#'
#' @importFrom sf st_as_sf
#' @importFrom dplyr filter

Get_marinearea <- function() {
  atlas_env$ices <- ices_selection %>%
    dplyr::filter(mncat_id %in% unique(isolate(atlas_env$opcats_spatial())$mncat_id)) %>%
      sf::st_as_sf(crs = 4326)
  
  atlas_env$trac <- trac_selection %>%
    dplyr::filter(parent_mncat_id %in% unique(isolate(atlas_env$opcats_spatial())$mncat_id)) %>%
    sf::st_as_sf(crs = 4326)
}




Get_seasubstrate <- function(){
  
  ## Requires emodnet package fix
}


